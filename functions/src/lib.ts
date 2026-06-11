/**
 * Shared infrastructure: Admin SDK handles, geo helpers, Razorpay client, and
 * small utilities used across all functions.
 */
import {initializeApp} from "firebase-admin/app";
import {getFirestore, GeoPoint} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {getStorage} from "firebase-admin/storage";
import {defineSecret} from "firebase-functions/params";
import {logger} from "firebase-functions/v2";
import Razorpay from "razorpay";

initializeApp();

export const db = getFirestore();
export const messaging = getMessaging();
export const storage = getStorage();

/**
 * Razorpay credentials — declared as secrets so the key+secret live only in
 * the function runtime, NEVER on the client. Bind to a function with
 * `{secrets: [RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET]}`.
 */
export const RAZORPAY_KEY_ID = defineSecret("RAZORPAY_KEY_ID");
export const RAZORPAY_KEY_SECRET = defineSecret("RAZORPAY_KEY_SECRET");
export const RAZORPAY_WEBHOOK_SECRET = defineSecret("RAZORPAY_WEBHOOK_SECRET");

/** Lazily build a Razorpay client from the runtime secrets. */
export function razorpayClient(): Razorpay {
  return new Razorpay({
    key_id: RAZORPAY_KEY_ID.value(),
    key_secret: RAZORPAY_KEY_SECRET.value(),
  });
}

/** Great-circle distance in kilometres between two GeoPoints. */
export function distanceKm(a: GeoPoint, b: GeoPoint): number {
  const R = 6371;
  const dLat = rad(b.latitude - a.latitude);
  const dLon = rad(b.longitude - a.longitude);
  const lat1 = rad(a.latitude);
  const lat2 = rad(b.latitude);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
}

function rad(deg: number): number {
  return (deg * Math.PI) / 180;
}

/** Send a data+notification FCM message to a single token (best-effort). */
export async function sendToToken(
  token: string | undefined,
  notification: {title: string; body: string},
  data: Record<string, string> = {}
): Promise<void> {
  if (!token) return;
  try {
    await messaging.send({token, notification, data});
  } catch (err) {
    logger.warn("FCM send failed", {err});
  }
}

/** Fan a data message out to many tokens at once (best-effort). */
export async function sendToTokens(
  tokens: string[],
  notification: {title: string; body: string},
  data: Record<string, string> = {}
): Promise<void> {
  const valid = tokens.filter((t) => !!t);
  if (valid.length === 0) return;
  try {
    await messaging.sendEachForMulticast({tokens: valid, notification, data});
  } catch (err) {
    logger.warn("FCM multicast failed", {err});
  }
}

export {GeoPoint};
