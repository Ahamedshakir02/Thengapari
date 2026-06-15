// Firebase: the ONLY dynamic piece of this otherwise-static site.
// Writes waitlist signups to Firestore /leads/{id}. Config comes from Vite env
// vars (VITE_FB_*). If they're absent, we DON'T initialize Firebase and fall
// back to localStorage so the page still works locally / before config is set.
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, addDoc, serverTimestamp } from 'firebase/firestore';

const env = import.meta.env;

const firebaseConfig = {
  apiKey: env.VITE_FB_API_KEY,
  authDomain: env.VITE_FB_AUTH_DOMAIN,
  projectId: env.VITE_FB_PROJECT_ID,
  storageBucket: env.VITE_FB_STORAGE_BUCKET,
  messagingSenderId: env.VITE_FB_MESSAGING_SENDER_ID,
  appId: env.VITE_FB_APP_ID,
};

export const isFirebaseConfigured = Boolean(firebaseConfig.apiKey && firebaseConfig.projectId);

let db = null;
if (isFirebaseConfigured) {
  const app = initializeApp(firebaseConfig);
  db = getFirestore(app);
} else {
  // eslint-disable-next-line no-console
  console.warn(
    '[ThengaPari] Firebase not configured — waitlist will be stored in localStorage only. ' +
      'Copy .env.example to .env.local and paste the thengapari-dev web config to enable Firestore.',
  );
}

/**
 * Persist a lead. Matches the agreed schema exactly:
 *   /leads/{id} -> { email, type: 'homeowner'|'business'|'general', createdAt }
 * @returns {Promise<{ ok: boolean, stored: 'firestore'|'local' }>}
 */
export async function submitLead({ email, type }) {
  const payload = { email, type };
  if (db) {
    await addDoc(collection(db, 'leads'), { ...payload, createdAt: serverTimestamp() });
    return { ok: true, stored: 'firestore' };
  }
  // Fallback: never block the user. Keep the most recent value locally.
  try {
    const prior = JSON.parse(localStorage.getItem('tp_waitlist') || '[]');
    prior.push({ ...payload, createdAt: new Date().toISOString() });
    localStorage.setItem('tp_waitlist', JSON.stringify(prior));
  } catch (_) {
    /* ignore quota / private-mode errors */
  }
  return { ok: true, stored: 'local' };
}
