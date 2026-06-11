/** Scheduled jobs: standing-order auto-booking + seasonal AMC dispatch. */
import {FieldValue, Timestamp} from "firebase-admin/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {logger} from "firebase-functions/v2";
import {db, sendToToken} from "./lib";

/** Advance a due date by the standing-order frequency. */
function nextDate(from: Date, frequency: string): Date {
  const d = new Date(from);
  const days = frequency === "monthly" ? 30 : frequency === "biweekly" ? 14 : 7;
  d.setDate(d.getDate() + days);
  return d;
}

function gradeMatches(want: string, have: string): boolean {
  if (want === "Any") return true;
  if (want === "Grade A + B") return have === "Grade A" || have === "Grade B";
  return have === want;
}

/**
 * Every morning, auto-book due standing orders against fresh stock. Books a
 * matching lot (atomic decrement) or notifies the buyer that none was found,
 * then rolls the next due date forward.
 */
export const processStandingOrders = onSchedule(
  {schedule: "every day 06:00", timeZone: "Asia/Kolkata"},
  async () => {
    const now = new Date();
    const due = await db
      .collection("standing_orders")
      .where("active", "==", true)
      .where("nextDue", "<=", Timestamp.fromDate(now))
      .get();

    for (const so of due.docs) {
      const s = so.data();
      const buyer = (await db.collection("b2b_buyers").doc(s.buyerId).get()).data();
      let booked = false;
      try {
        // Candidate lots for the crop, freshest acceptable first.
        const lots = await db
          .collection("inventory")
          .where("cropType", "==", s.cropType)
          .where("available", "==", true)
          .get();
        const match = lots.docs.find((d) => {
          const l = d.data();
          return (
            gradeMatches(s.grade, l.grade ?? "Grade A") &&
            (l.quantityRemaining ?? 0) >= s.quantityPerOrder &&
            (s.maxPricePer == null || (l.unitPrice ?? 0) <= s.maxPricePer)
          );
        });

        if (match) {
          await bookFromLot(match.ref, s, so.id);
          booked = true;
          await sendToToken(
            buyer?.fcmToken,
            {title: "Standing order placed", body: `${s.quantityPerOrder} ${s.cropType} confirmed.`},
            {type: "standing_order_placed", standingId: so.id}
          );
        } else {
          await sendToToken(
            buyer?.fcmToken,
            {title: "Standing order skipped", body: `No matching ${s.cropType} stock today.`},
            {type: "standing_order_skipped", standingId: so.id}
          );
        }
      } catch (err) {
        logger.error("Standing order processing failed", {id: so.id, err});
      }
      await so.ref.update({
        nextDue: Timestamp.fromDate(nextDate(now, s.frequency)),
        lastFulfilled: booked ? FieldValue.serverTimestamp() : s.lastFulfilled ?? null,
      });
    }
    logger.info(`Processed ${due.size} standing orders`);
  }
);

/** Reserve a lot for a standing order in a single transaction. */
async function bookFromLot(
  lotRef: FirebaseFirestore.DocumentReference,
  s: FirebaseFirestore.DocumentData,
  standingId: string
): Promise<void> {
  const orderRef = db.collection("b2b_orders").doc();
  await db.runTransaction(async (tx) => {
    const lot = await tx.get(lotRef);
    const l = lot.data()!;
    const remaining = (l.quantityRemaining as number) ?? 0;
    if (remaining < s.quantityPerOrder) throw new Error("Stock taken");
    const unitPrice = l.unitPrice as number;
    const wholesale = (l.wholesaleMarketPrice as number) ?? unitPrice;
    const newRemaining = remaining - s.quantityPerOrder;
    tx.update(lotRef, {quantityRemaining: newRemaining, available: newRemaining > 0});
    tx.set(orderRef, {
      buyerId: s.buyerId,
      listingId: lotRef.id,
      cropType: l.cropType,
      grade: l.grade ?? "Grade A",
      quantity: s.quantityPerOrder,
      unitPrice,
      totalAmount: unitPrice * s.quantityPerOrder,
      savingsAmount: Math.round((wholesale - unitPrice) * s.quantityPerOrder),
      paymentMethod: "pay_on_delivery",
      paymentStatus: "pending",
      status: "confirmed",
      standingOrderId: standingId,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
}

/**
 * Seasonal cron: auto-create homeowner harvest jobs from active AMC contracts
 * whose next dispatch is due.
 */
export const scheduleAMCDispatches = onSchedule(
  {schedule: "every monday 05:00", timeZone: "Asia/Kolkata"},
  async () => {
    const now = new Date();
    const due = await db
      .collection("amc_contracts")
      .where("active", "==", true)
      .where("nextDispatch", "<=", Timestamp.fromDate(now))
      .get();

    for (const c of due.docs) {
      const amc = c.data();
      await db.collection("jobs").add({
        homeownerId: amc.homeownerId ?? c.id,
        cropTypes: amc.cropTypes ?? ["coconut"],
        status: "pending",
        location: amc.location ?? null,
        district: amc.district ?? "",
        estimatedYieldKg: amc.estimatedYieldKg ?? 0,
        scheduledAt: Timestamp.fromDate(now),
        source: "amc",
        createdAt: FieldValue.serverTimestamp(),
      });
      // Roughly quarterly dispatch cadence.
      const next = new Date(now);
      next.setMonth(next.getMonth() + 3);
      await c.ref.update({nextDispatch: Timestamp.fromDate(next)});
    }
    logger.info(`Scheduled ${due.size} AMC dispatches`);
  }
);
