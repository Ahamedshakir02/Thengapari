/** Create B2B inventory when a harvest completes, and notify matching buyers. */
import {FieldValue} from "firebase-admin/firestore";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {logger} from "firebase-functions/v2";
import {db, sendToTokens} from "./lib";

const PLATFORM_DISCOUNT = 0.12; // listed at 12% under wholesale by default

/**
 * Fires when a job flips to `complete`. Reads the logged yield + the daily
 * market price and creates a live `/inventory` listing the B2B portal shows in
 * real-time, then notifies buyers whose preferences match the crop.
 */
export const updateInventoryOnHarvest = onDocumentUpdated(
  "jobs/{jobId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    if (before.status === "complete" || after.status !== "complete") return;

    const jobId = event.params.jobId;
    const yieldSnap = await db.doc(`jobs/${jobId}/yieldData/current`).get();
    const y = yieldSnap.data();
    if (!y) {
      logger.warn("No yieldData for completed job; skipping listing", {jobId});
      return;
    }

    const cropType = (after.cropTypes?.[0] as string) ?? "coconut";
    const quantity =
      ((y.gradeA as number) ?? 0) +
      ((y.gradeB as number) ?? 0) +
      ((y.tender as number) ?? 0);

    // Daily wholesale reference price (ops-managed).
    const priceDoc = await db.collection("market_prices").doc(cropType).get();
    const wholesale = (priceDoc.data()?.wholesalePrice as number) ?? 0;
    const unitPrice = Math.round(wholesale * (1 - PLATFORM_DISCOUNT) * 10) / 10;
    const savingsPercent = wholesale > 0
      ? Math.round(((wholesale - unitPrice) / wholesale) * 100)
      : 0;

    const listingRef = db.collection("inventory").doc();
    await listingRef.set({
      cropType,
      grade: "Grade A",
      quantity,
      quantityRemaining: quantity,
      unitPrice,
      wholesaleMarketPrice: wholesale,
      savingsPercent,
      harvestedAt: after.completedAt ?? FieldValue.serverTimestamp(),
      location: after.location ?? null,
      ward: after.district ?? "",
      available: quantity > 0,
      jobId,
      createdAt: FieldValue.serverTimestamp(),
    });

    // Notify buyers who want this crop.
    const buyers = await db
      .collection("b2b_buyers")
      .where("cropPreferences", "array-contains", cropType)
      .get();
    const tokens = buyers.docs
      .map((b) => b.data().fcmToken as string | undefined)
      .filter((t): t is string => !!t);
    await sendToTokens(
      tokens,
      {title: "New stock available", body: `Fresh ${cropType} — ₹${unitPrice}/unit`},
      {type: "new_stock_available", cropType, listingId: listingRef.id}
    );
  }
);
