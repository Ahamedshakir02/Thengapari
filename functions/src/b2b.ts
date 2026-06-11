/** B2B order placement (atomic inventory decrement) + delivery confirmation. */
import {FieldValue} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {logger} from "firebase-functions/v2";
import {
  db,
  razorpayClient,
  RAZORPAY_KEY_ID,
  RAZORPAY_KEY_SECRET,
  sendToToken,
} from "./lib";
import {buildInvoicePdf} from "./reports";

/**
 * Place a B2B order. The inventory check + decrement + order creation all run
 * in ONE transaction, so two buyers can never over-order the same lot.
 */
export const createB2BOrder = onCall(
  {secrets: [RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET]},
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
    const buyerId = request.data.buyerId as string;
    if (buyerId !== uid) {
      throw new HttpsError("permission-denied", "buyerId mismatch.");
    }
    const listingId = request.data.listingId as string;
    const quantity = Number(request.data.quantity);
    const paymentMethod = (request.data.paymentMethod as string) ?? "pay_on_delivery";
    const deliveryDate = request.data.deliveryDate as string;
    if (!listingId || !quantity || quantity <= 0) {
      throw new HttpsError("invalid-argument", "listingId and quantity required.");
    }

    // Buyers must be verified to place orders.
    const buyer = await db.collection("b2b_buyers").doc(uid).get();
    if (!buyer.exists || buyer.data()?.verified !== true) {
      throw new HttpsError("permission-denied", "Business not verified yet.");
    }
    if (paymentMethod === "pay_on_delivery" && buyer.data()?.tier === undefined) {
      // Pay-on-delivery is allowed for verified buyers; tiering is optional.
    }

    const listingRef = db.collection("inventory").doc(listingId);
    const orderRef = db.collection("b2b_orders").doc();

    const order = await db.runTransaction(async (tx) => {
      const lSnap = await tx.get(listingRef);
      if (!lSnap.exists) throw new HttpsError("not-found", "Listing not found.");
      const l = lSnap.data()!;
      const remaining = (l.quantityRemaining as number) ?? 0;
      if (l.available !== true || remaining < quantity) {
        throw new HttpsError(
          "failed-precondition",
          `Only ${remaining} ${l.unit ?? "units"} left.`
        );
      }
      const unitPrice = l.unitPrice as number;
      const wholesale = (l.wholesaleMarketPrice as number) ?? unitPrice;
      const totalAmount = unitPrice * quantity;
      const savingsAmount = Math.round((wholesale - unitPrice) * quantity);
      const newRemaining = remaining - quantity;

      tx.update(listingRef, {
        quantityRemaining: newRemaining,
        available: newRemaining > 0,
      });
      tx.set(orderRef, {
        buyerId: uid,
        listingId,
        cropType: l.cropType,
        grade: l.grade ?? "Grade A",
        quantity,
        unitPrice,
        totalAmount,
        savingsAmount,
        deliveryDate: deliveryDate ? new Date(deliveryDate) : null,
        deliveryAddress: buyer.data()?.address ?? "",
        paymentMethod,
        paymentStatus: "pending",
        status: "confirmed",
        createdAt: FieldValue.serverTimestamp(),
      });
      // Seed the tracking timeline.
      tx.set(orderRef.collection("tracking").doc(), {
        type: "confirmed",
        timestamp: FieldValue.serverTimestamp(),
        note: "Order confirmed",
      });
      return {totalAmount};
    });

    // Optional pay-now Razorpay order (created after the atomic reservation).
    let razorpay: {keyId: string; orderId: string; amountPaise: number} | null = null;
    if (paymentMethod === "pay_now") {
      try {
        const amountPaise = Math.round(order.totalAmount * 100);
        const rp = await razorpayClient().orders.create({
          amount: amountPaise,
          currency: "INR",
          receipt: orderRef.id,
          notes: {refId: orderRef.id, uid},
        });
        razorpay = {keyId: RAZORPAY_KEY_ID.value(), orderId: rp.id, amountPaise};
      } catch (err) {
        logger.error("Razorpay order failed for B2B order", {err});
      }
    }

    await sendToToken(
      buyer.data()?.fcmToken,
      {title: "Order confirmed", body: "Your pre-book is reserved from source."},
      {type: "order_confirmed", orderId: orderRef.id}
    );

    return {orderId: orderRef.id, totalAmount: order.totalAmount, ...razorpay};
  }
);

/**
 * Buyer confirms receipt: marks delivered, writes the savings record, bumps
 * buyer totals, and generates the GST invoice PDF.
 */
export const confirmDelivery = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
  const orderId = request.data.orderId as string;
  if (!orderId) throw new HttpsError("invalid-argument", "orderId required.");

  const orderRef = db.collection("b2b_orders").doc(orderId);

  const order = await db.runTransaction(async (tx) => {
    const snap = await tx.get(orderRef);
    if (!snap.exists) throw new HttpsError("not-found", "Order not found.");
    const o = snap.data()!;
    if (o.buyerId !== uid) {
      throw new HttpsError("permission-denied", "Not your order.");
    }
    if (o.status === "delivered") {
      throw new HttpsError("failed-precondition", "Already delivered.");
    }
    tx.update(orderRef, {
      status: "delivered",
      deliveredAt: FieldValue.serverTimestamp(),
    });
    tx.set(orderRef.collection("tracking").doc(), {
      type: "delivered",
      timestamp: FieldValue.serverTimestamp(),
      note: "Delivered and received",
    });
    return o;
  });

  // Savings record + buyer totals.
  const platformPrice = (order.unitPrice as number) * (order.quantity as number);
  await Promise.allSettled([
    db.collection(`b2b_buyers/${uid}/savings`).doc(orderId).set({
      orderId,
      cropType: order.cropType,
      quantity: order.quantity,
      platformPrice,
      savingsAmount: order.savingsAmount ?? 0,
      savingsPercent:
        platformPrice > 0
          ? ((order.savingsAmount ?? 0) / (platformPrice + (order.savingsAmount ?? 0))) * 100
          : 0,
      createdAt: FieldValue.serverTimestamp(),
    }),
    db.collection("b2b_buyers").doc(uid).update({
      totalOrdersPlaced: FieldValue.increment(1),
      totalSpent: FieldValue.increment(order.totalAmount ?? 0),
      totalSaved: FieldValue.increment(order.savingsAmount ?? 0),
    }),
    buildInvoicePdf(orderId).then((url) =>
      orderRef.update({invoiceUrl: url})
    ),
  ]);

  return {ok: true};
});
