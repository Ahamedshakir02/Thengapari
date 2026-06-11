/** Pre-booking yield estimate + worker reliability scoring. */
import {FieldValue} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {db} from "./lib";

// Rough per-tree yield (kg) and ₹/kg by crop, used for the booking preview.
const CROP_KG_PER_TREE: Record<string, number> = {
  coconut: 60,
  mango: 80,
  jackfruit: 120,
  pepper: 3,
  banana: 25,
};
const CROP_RATE_PER_KG: Record<string, number> = {
  coconut: 22,
  mango: 95,
  jackfruit: 18,
  pepper: 480,
  banana: 40,
};

/** Pre-booking price preview from a homeowner's tree counts. */
export const calculateYieldEstimate = onCall(async (request) => {
  const treeCounts = (request.data.treeCounts ?? {}) as Record<string, number>;
  const ripeOnly = request.data.ripeOnly === true;
  const factor = ripeOnly ? 0.6 : 1.0;

  let kg = 0;
  let earning = 0;
  for (const [crop, count] of Object.entries(treeCounts)) {
    const cropKg = (count ?? 0) * (CROP_KG_PER_TREE[crop] ?? 30) * factor;
    kg += cropKg;
    earning += cropKg * (CROP_RATE_PER_KG[crop] ?? 25);
  }
  return {
    estimatedKg: Math.round(kg),
    estimatedEarning: Math.round(earning),
    marketRate: kg === 0 ? 0 : Math.round((earning / kg) * 10) / 10,
  };
});

/**
 * Recompute a worker's reliability score after a job outcome. A no-show is
 * penalised heavily; on-time completion nudges the score back up.
 */
export const updateWorkerReliabilityScore = onCall(async (request) => {
  const workerId = request.data.workerId as string;
  const event = request.data.event as string; // 'completed' | 'no_show' | 'late'
  if (!workerId) throw new HttpsError("invalid-argument", "workerId required.");

  const ref = db.collection("workers").doc(workerId);
  const score = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError("not-found", "Worker not found.");
    const w = snap.data()!;
    let onTime = (w.jobsOnTime as number) ?? 0;
    let noShows = (w.noShows as number) ?? 0;
    if (event === "no_show") noShows += 1;
    else if (event === "completed") onTime += 1;

    const total = onTime + noShows;
    const next = total === 0 ? 100 : Math.round((onTime / (onTime + noShows * 2)) * 100);
    tx.update(ref, {
      jobsOnTime: onTime,
      noShows,
      reliabilityScore: next,
      reliabilityUpdatedAt: FieldValue.serverTimestamp(),
    });
    return next;
  });
  return {reliabilityScore: score};
});
