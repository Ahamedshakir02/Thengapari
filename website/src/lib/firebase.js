// Firebase: the ONLY dynamic piece of this otherwise-static site.
// Writes waitlist signups to Firestore /leads/{id}. To keep the initial bundle
// lean (fast first paint), the Firebase SDK is dynamically imported only on the
// first form submit — not at page load. Config comes from Vite env vars
// (VITE_FB_*); if they're absent we skip Firestore and fall back to localStorage
// so the page still works locally / before config is set.
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

let dbPromise = null;
async function getDb() {
  if (!dbPromise) {
    dbPromise = (async () => {
      const [{ initializeApp }, { getFirestore }] = await Promise.all([
        import('firebase/app'),
        import('firebase/firestore'),
      ]);
      return getFirestore(initializeApp(firebaseConfig));
    })();
  }
  return dbPromise;
}

function storeLocally(payload) {
  try {
    const prior = JSON.parse(localStorage.getItem('tp_waitlist') || '[]');
    prior.push({ ...payload, createdAt: new Date().toISOString() });
    localStorage.setItem('tp_waitlist', JSON.stringify(prior));
  } catch (_) {
    /* ignore quota / private-mode errors */
  }
}

/**
 * Persist a lead. Matches the agreed schema exactly:
 *   /leads/{id} -> { email, type: 'homeowner'|'business'|'general', createdAt }
 * @returns {Promise<{ ok: boolean, stored: 'firestore'|'local' }>}
 */
export async function submitLead({ email, type }) {
  const payload = { email, type };
  if (!isFirebaseConfigured) {
    // eslint-disable-next-line no-console
    console.warn(
      '[ThengaPari] Firebase not configured — waitlist stored in localStorage only. ' +
        'Copy .env.example to .env.local with the thengapari-dev web config to enable Firestore.',
    );
    storeLocally(payload);
    return { ok: true, stored: 'local' };
  }
  const db = await getDb();
  const { collection, addDoc, serverTimestamp } = await import('firebase/firestore');
  await addDoc(collection(db, 'leads'), { ...payload, createdAt: serverTimestamp() });
  return { ok: true, stored: 'firestore' };
}
