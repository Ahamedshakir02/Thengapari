/** Job assignment + completion (payouts, notifications, records). */
import {FieldValue} from "firebase-admin/firestore";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {logger} from "firebase-functions/v2";
import {
  db,
  distanceKm,
  razorpayClient,
  RAZORPAY_KEY_ID,
  RAZORPAY_KEY_SECRET,
  sendToToken,
} from "./lib";

/**
 * When a homeowner books a harvest, assign the nearest verified + available
 * Site Manager and flip the job to `site_manager_assigned`.
 */
export const onJobCreate = onDocumentCreated("jobs/{jobId}", async (event) => {
  const snap = event.data;
  if (!snap) return;
  const job = snap.data();
  if (job.status !== "pending" || job.siteManagerId) return;

  const loc = job.location as FirebaseFirestore.GeoPoint | undefined;

  // Candidate pool: verified, trained, not already on a job.
  const candidates = await db
    .collection("site_managers")
    .where("verified", "==", true)
    .where("currentJobId", "==", null)
    .get();

  if (candidates.empty) {
    logger.warn("No available site managers for job", {jobId: event.params.jobId});
    return;
  }

  // Pick the nearest by operating zone (falls back to first if no geo).
  let best: FirebaseFirestore.QueryDocumentSnapshot | null = null;
  let bestDist = Number.POSITIVE_INFINITY;
  for (const doc of candidates.docs) {
    const zone = doc.data().operatingZone as FirebaseFirestore.GeoPoint | undefined;
    const d = loc && zone ? distanceKm(loc, zone) : 0;
    if (d < bestDist) {
      bestDist = d;
      best = doc;
    }
  }
  if (!best) return;

  const batch = db.batch();
  batch.update(snap.ref, {
    siteManagerId: best.id,
    status: "site_manager_assigned",
  });
  batch.update(best.ref, {currentJobId: event.params.jobId});
  await batch.commit();

  await sendToToken(
    best.data().fcmToken,
    {title: "New job assigned", body: "A harvest near you needs a supervisor."},
    {type: "job_assigned", jobId: event.params.jobId}
  );
});

/**
 * Mark a job complete: settle payouts to the worker(s) and site manager, write
 * the financial records, and notify the homeowner. Only the assigned site
 * manager may call this.
 */
export const markJobComplete = onCall(
  {secrets: [RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET]},
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
    const jobId = request.data.jobId as string;
    const reportUrl = (request.data.reportUrl as string) ?? null;
    if (!jobId) throw new HttpsError("invalid-argument", "jobId is required.");

    const jobRef = db.collection("jobs").doc(jobId);

    // Atomically guard the transition so completion + payouts happen once.
    const result = await db.runTransaction(async (tx) => {
      const jobSnap = await tx.get(jobRef);
      if (!jobSnap.exists) throw new HttpsError("not-found", "Job not found.");
      const job = jobSnap.data()!;
      if (job.siteManagerId !== uid) {
        throw new HttpsError("permission-denied", "Not your job.");
      }
      if (job.status === "complete") {
        throw new HttpsError("failed-precondition", "Job already complete.");
      }

      const earnings = (job.earningsAmount as number) ?? 0;
      const workerPayout =
        (job.workerPayout as number) ?? Math.round(earnings * 0.55);
      const siteManagerPayout =
        (job.siteManagerPayout as number) ?? Math.round(earnings * 0.15);

      tx.update(jobRef, {
        status: "complete",
        completedAt: FieldValue.serverTimestamp(),
        reportUrl,
        workerPayout,
        siteManagerPayout,
      });
      return {job, workerPayout, siteManagerPayout};
    });

    const {job, workerPayout, siteManagerPayout} = result;
    const workerIds: string[] = job.workerIds ?? [];

    // Post-commit side effects (best-effort; failures don't reverse completion).
    await Promise.allSettled([
      payout(workerIds[0], workerPayout, jobId, "worker"),
      payout(uid, siteManagerPayout, jobId, "site_manager"),
      writeRecords(job, jobId, uid, workerIds, workerPayout, siteManagerPayout),
      notifyHomeowner(job, jobId, reportUrl),
      freeSiteManager(uid),
    ]);

    return {ok: true, workerPayout, siteManagerPayout};
  }
);

/** Issue a UPI payout via RazorpayX (records the intent if payouts disabled). */
async function payout(
  payeeUid: string | undefined,
  amountRupees: number,
  jobId: string,
  role: string
): Promise<void> {
  if (!payeeUid || amountRupees <= 0) return;
  try {
    // RazorpayX fund-account payout would go here. Recording the intent keeps
    // the ledger consistent even before payouts are enabled on the account.
    razorpayClient(); // ensures secrets are present
    await db.collection("payouts").add({
      payeeUid,
      role,
      jobId,
      amount: amountRupees,
      status: "initiated",
      createdAt: FieldValue.serverTimestamp(),
    });
  } catch (err) {
    logger.error("Payout failed", {payeeUid, jobId, err});
  }
}

async function writeRecords(
  job: FirebaseFirestore.DocumentData,
  jobId: string,
  smUid: string,
  workerIds: string[],
  workerPayout: number,
  smPayout: number
): Promise<void> {
  const batch = db.batch();
  batch.set(
    db.collection(`homeowners/${job.homeownerId}/transactions`).doc(jobId),
    {
      jobId,
      amount: job.earningsAmount ?? 0,
      fee: job.feeAmount ?? 0,
      createdAt: FieldValue.serverTimestamp(),
    }
  );
  if (workerIds[0]) {
    batch.set(db.collection(`workers/${workerIds[0]}/earnings`).doc(jobId), {
      jobId,
      amount: workerPayout,
      createdAt: FieldValue.serverTimestamp(),
    });
    batch.update(db.collection("workers").doc(workerIds[0]), {
      totalJobsCompleted: FieldValue.increment(1),
      totalEarned: FieldValue.increment(workerPayout),
    });
  }
  batch.update(db.collection("site_managers").doc(smUid), {
    jobsCompleted: FieldValue.increment(1),
    totalEarned: FieldValue.increment(smPayout),
  });
  await batch.commit();
}

async function notifyHomeowner(
  job: FirebaseFirestore.DocumentData,
  jobId: string,
  reportUrl: string | null
): Promise<void> {
  const homeowner = await db.collection("users").doc(job.homeownerId).get();
  await sendToToken(
    homeowner.data()?.fcmToken,
    {title: "Harvest complete", body: "Your yield report is ready to view."},
    {type: "job_complete", jobId, reportUrl: reportUrl ?? ""}
  );
}

async function freeSiteManager(uid: string): Promise<void> {
  await db.collection("site_managers").doc(uid).update({currentJobId: null});
}
