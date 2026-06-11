/** Razorpay order creation + webhook. Secrets stay server-side only. */
import * as crypto from "crypto";
import {FieldValue} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {onRequest} from "firebase-functions/v2/https";
import {logger} from "firebase-functions/v2";
import {
  db,
  razorpayClient,
  RAZORPAY_KEY_ID,
  RAZORPAY_KEY_SECRET,
  RAZORPAY_WEBHOOK_SECRET,
} from "./lib";

/**
 * Create a Razorpay order server-side and return only the public fields the
 * client checkout needs. The key SECRET never leaves the function.
 */
export const createRazorpayOrder = onCall(
  {secrets: [RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET]},
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    const amount = Number(request.data.amount);
    const refId = (request.data.jobId ?? request.data.orderId) as string;
    if (!amount || amount <= 0) {
      throw new HttpsError("invalid-argument", "amount must be positive.");
    }
    const amountPaise = Math.round(amount * 100);
    try {
      const order = await razorpayClient().orders.create({
        amount: amountPaise,
        currency: "INR",
        receipt: refId ?? `rcpt_${Date.now()}`,
        notes: {refId: refId ?? "", uid: request.auth.uid},
      });
      return {
        keyId: RAZORPAY_KEY_ID.value(), // public key — safe to return
        orderId: order.id,
        amountPaise,
      };
    } catch (err) {
      logger.error("Razorpay order create failed", {err});
      throw new HttpsError("internal", "Could not create payment order.");
    }
  }
);

/**
 * Razorpay webhook: verifies the HMAC signature, then marks the referenced job
 * or B2B order paid. Configured as a raw HTTP endpoint in the Razorpay console.
 */
export const razorpayWebhook = onRequest(
  {secrets: [RAZORPAY_WEBHOOK_SECRET]},
  async (req, res) => {
    const signature = req.headers["x-razorpay-signature"] as string | undefined;
    const expected = crypto
      .createHmac("sha256", RAZORPAY_WEBHOOK_SECRET.value())
      .update(req.rawBody)
      .digest("hex");
    if (!signature || signature !== expected) {
      logger.warn("Razorpay webhook signature mismatch");
      res.status(400).send("invalid signature");
      return;
    }

    const event = req.body.event as string;
    const payment = req.body.payload?.payment?.entity;
    const refId = payment?.notes?.refId as string | undefined;

    if (event === "payment.captured" && refId) {
      // The refId is either a job id or a b2b order id.
      const jobRef = db.collection("jobs").doc(refId);
      const orderRef = db.collection("b2b_orders").doc(refId);
      const [job, order] = await Promise.all([jobRef.get(), orderRef.get()]);
      const update = {
        paymentStatus: "paid",
        paidAt: FieldValue.serverTimestamp(),
      };
      if (job.exists) await jobRef.update(update);
      if (order.exists) await orderRef.update(update);
    }
    res.status(200).send("ok");
  }
);
