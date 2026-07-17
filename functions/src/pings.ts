/** Worker/processor ping fan-out + atomic acceptance. */
import {FieldValue, GeoPoint} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {db, distanceKm, sendToTokens, sendToToken} from "./lib";

interface BroadcastInput {
  jobId: string;
  requiredSkill: string;
  location: {lat: number; lng: number};
  radiusKm?: number;
  cropType?: string;
  yieldKg?: number;
}

/** Fan a job ping out to nearby online workers with a matching skill. */
async function broadcast(input: BroadcastInput): Promise<{pinged: number}> {
  const {jobId, requiredSkill} = input;
  if (!jobId || !requiredSkill) {
    throw new HttpsError("invalid-argument", "jobId and requiredSkill required.");
  }
  const origin = new GeoPoint(input.location.lat, input.location.lng);
  const radius = input.radiusKm ?? 5;

  // Enrich pings with what the JobPingScreen shows (payout, place) so the
  // worker can decide without a job read (rules deny that pre-acceptance).
  const jobSnap = await db.collection("jobs").doc(jobId).get();
  const job = jobSnap.data() ?? {};
  const payout =
    (job.workerPayout as number | undefined) ??
    (job.earningsAmount ? Math.round((job.earningsAmount as number) * 0.55) : null);

  const workers = await db
    .collection("workers")
    .where("isOnline", "==", true)
    .where("skills", "array-contains", requiredSkill)
    .get();

  const expiresAt = new Date(Date.now() + 45_000); // 45s TTL
  const batch = db.batch();
  const tokens: string[] = [];
  let pinged = 0;

  for (const w of workers.docs) {
    const loc = w.data().location as GeoPoint | undefined;
    const d = loc ? distanceKm(origin, loc) : radius; // unknown loc → edge
    if (d > radius) continue;
    const ref = db.collection("job_pings").doc();
    batch.set(ref, {
      jobId,
      workerId: w.id,
      workerName: w.data().name ?? "",
      status: "pending",
      requiredSkill,
      cropType: input.cropType ?? (job.cropTypes?.[0] as string | undefined) ?? null,
      yieldKg: input.yieldKg ?? (job.estimatedYieldKg as number | undefined) ?? null,
      payout,
      place: (job.address as string | undefined) ?? null,
      distanceKm: Math.round(d * 10) / 10,
      etaMin: Math.max(3, Math.round(d * 3)),
      createdAt: FieldValue.serverTimestamp(),
      expiresAt,
    });
    if (w.data().fcmToken) tokens.push(w.data().fcmToken);
    pinged++;
  }
  await batch.commit();

  await sendToTokens(
    tokens,
    {title: "New job available", body: "Tap to view and accept within 45s."},
    {type: "job_ping", jobId}
  );
  return {pinged};
}

export const broadcastWorkerPing = onCall(async (request) => {
  return broadcast({
    jobId: request.data.jobId,
    requiredSkill: request.data.requiredSkill ?? "climber",
    location: request.data.location,
    radiusKm: request.data.radiusKm,
  });
});

export const broadcastProcessorPing = onCall(async (request) => {
  return broadcast({
    jobId: request.data.jobId,
    requiredSkill: request.data.requiredSkill ?? "husker",
    location: request.data.location,
    radiusKm: request.data.radiusKm,
    cropType: request.data.cropType,
    yieldKg: request.data.yieldKg,
  });
});

/**
 * Atomically assign a job to the first worker who accepts a ping. Guarantees a
 * single winner: the transaction rejects if the ping is no longer pending.
 */
export const acceptPing = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
  const pingId = request.data.pingId as string;
  if (!pingId) throw new HttpsError("invalid-argument", "pingId required.");

  const pingRef = db.collection("job_pings").doc(pingId);

  const jobId = await db.runTransaction(async (tx) => {
    const pingSnap = await tx.get(pingRef);
    if (!pingSnap.exists) throw new HttpsError("not-found", "Ping not found.");
    const ping = pingSnap.data()!;
    if (ping.workerId !== uid) {
      throw new HttpsError("permission-denied", "Not your ping.");
    }
    if (ping.status !== "pending") {
      throw new HttpsError("failed-precondition", "Ping already resolved.");
    }
    const jobRef = db.collection("jobs").doc(ping.jobId);
    const jobSnap = await tx.get(jobRef);
    if (!jobSnap.exists) throw new HttpsError("not-found", "Job not found.");

    tx.update(pingRef, {status: "accepted", acceptedAt: FieldValue.serverTimestamp()});
    tx.update(jobRef, {
      workerIds: FieldValue.arrayUnion(uid),
      status: "worker_assigned",
    });
    return ping.jobId as string;
  });

  // Cancel sibling pings for this job (outside the transaction).
  const siblings = await db
    .collection("job_pings")
    .where("jobId", "==", jobId)
    .where("status", "==", "pending")
    .get();
  const batch = db.batch();
  for (const s of siblings.docs) {
    if (s.id !== pingId) batch.update(s.ref, {status: "cancelled"});
  }
  await batch.commit();

  // Notify the site manager.
  const job = (await db.collection("jobs").doc(jobId).get()).data();
  if (job?.siteManagerId) {
    const sm = await db.collection("site_managers").doc(job.siteManagerId).get();
    await sendToToken(
      sm.data()?.fcmToken,
      {title: "Processor accepted", body: "A worker is on the way."},
      {type: "worker_accepted", jobId}
    );
  }
  return {ok: true, jobId};
});
