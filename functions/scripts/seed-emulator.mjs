/**
 * Seed the LOCAL Firebase emulators with a coherent demo dataset so all four
 * apps can run "live" end-to-end without touching production.
 *
 * Field names follow docs/00_shared_architecture.md and the core Dart models
 * (the canonical readers). Run via `npm run seed:emulator` with the emulator
 * suite already running — the script refuses to run against production.
 */
import admin from "firebase-admin";

// Always target the local emulators — this script can never touch production.
process.env.FIRESTORE_EMULATOR_HOST ??= "127.0.0.1:8080";
process.env.FIREBASE_AUTH_EMULATOR_HOST ??= "127.0.0.1:9099";

admin.initializeApp({ projectId: "thengapari-dev" });
const db = admin.firestore();
const { GeoPoint, Timestamp, FieldValue } = admin.firestore;

const H = "seed-homeowner";
const W = "seed-worker";
const SM = "seed-manager";
const B = "seed-buyer";

const now = new Date();
const today = (h, m = 0) =>
  new Date(now.getFullYear(), now.getMonth(), now.getDate(), h, m);
const daysAgo = (n, h = 10) => {
  const d = new Date(now);
  d.setDate(d.getDate() - n);
  d.setHours(h, 0, 0, 0);
  return d;
};
const daysAhead = (n) => {
  const d = new Date(now);
  d.setDate(d.getDate() + n);
  return d;
};
const ts = (d) => Timestamp.fromDate(d);

// Ollur, Thrissur, Kerala.
const jobLoc = new GeoPoint(10.4936, 76.2317);
const workerLoc = new GeoPoint(10.4991, 76.2402); // ~1.2 km from job
const smZone = new GeoPoint(10.505, 76.225);

async function seedAuth() {
  const users = [
    { uid: H, phoneNumber: "+919000000001", displayName: "Suresh Nair" },
    { uid: W, phoneNumber: "+919000000002", displayName: "Ravi Menon" },
    { uid: SM, phoneNumber: "+919000000003", displayName: "Anjali Krishnan" },
    { uid: B, phoneNumber: "+919000000004", displayName: "Priya Thomas" },
  ];
  for (const u of users) {
    try {
      await admin.auth().createUser(u);
    } catch (e) {
      if (e.code !== "auth/uid-already-exists") throw e;
    }
  }
}

async function seedFirestore() {
  const batch = db.batch();

  // ── /users (shared profile) ──
  batch.set(db.doc(`users/${H}`), {
    firstName: "Suresh",
    lastName: "Nair",
    phoneNumber: "+919000000001",
    district: "Thrissur",
    role: "homeowner",
    createdAt: ts(daysAgo(120)),
  });
  batch.set(db.doc(`users/${W}`), {
    firstName: "Ravi",
    lastName: "Menon",
    phoneNumber: "+919000000002",
    district: "Thrissur",
    role: "worker",
    createdAt: ts(daysAgo(200)),
  });
  batch.set(db.doc(`users/${SM}`), {
    firstName: "Anjali",
    lastName: "Krishnan",
    phoneNumber: "+919000000003",
    district: "Thrissur",
    role: "site_manager",
    createdAt: ts(daysAgo(90)),
  });
  batch.set(db.doc(`users/${B}`), {
    firstName: "Priya",
    lastName: "Thomas",
    phoneNumber: "+919000000004",
    district: "Ernakulam",
    role: "b2b_buyer",
    createdAt: ts(daysAgo(60)),
  });

  // ── Homeowner: tree inventory + AMC ──
  const trees = [
    { id: "coconut", type: "coconut", count: 12, avgAgeYears: 14, lastHarvested: ts(daysAgo(48)) },
    { id: "jackfruit", type: "jackfruit", count: 3, avgAgeYears: 22, lastHarvested: ts(daysAgo(95)) },
    { id: "mango", type: "mango", count: 2, avgAgeYears: 18, lastHarvested: ts(daysAgo(140)) },
  ];
  for (const t of trees) {
    batch.set(db.doc(`homeowners/${H}/trees/${t.id}`), t);
  }
  batch.set(db.doc(`amc_contracts/${H}`), {
    plan: "standard",
    annualFee: 2999,
    crops: ["coconut", "jackfruit"],
    startDate: ts(daysAgo(48)),
    nextDispatch: ts(daysAhead(42)),
    autoRenew: true,
  });

  // ── Worker profile + earnings history ──
  batch.set(db.doc(`workers/${W}`), {
    skills: ["climber", "husker"],
    upiVpa: "ravi@okaxis",
    isOnline: true,
    reliabilityScore: 94,
    fcmToken: null,
    totalJobsCompleted: 312,
    totalEarned: 184500,
    location: workerLoc,
    name: "Ravi Menon",
    createdAt: ts(daysAgo(200)),
  });
  const earnings = [
    { d: 6, amount: 980, jobId: "hist-1" },
    { d: 5, amount: 1420, jobId: "hist-2" },
    { d: 4, amount: 760, jobId: "hist-3" },
    { d: 2, amount: 1680, jobId: "hist-4" },
    { d: 1, amount: 620, jobId: "hist-5" },
    { d: 0, amount: 380, jobId: "hist-6" },
  ];
  for (const e of earnings) {
    batch.set(db.doc(`workers/${W}/earnings/${e.jobId}`), {
      jobId: e.jobId,
      amount: e.amount,
      createdAt: ts(daysAgo(e.d, 9)),
    });
  }

  // ── Site manager profile ──
  batch.set(db.doc(`site_managers/${SM}`), {
    collegeName: "St. Thomas College, Thrissur",
    branch: "BSc Agriculture",
    yearOfStudy: 3,
    rollNumber: "STC-AG-2129",
    idDocUrl: null,
    verified: true,
    trainingComplete: true,
    rating: 4.8,
    jobsCompleted: 47,
    totalEarned: 30150,
    currentJobId: null,
    operatingZone: smZone,
    fcmToken: null,
    createdAt: ts(daysAgo(90)),
  });

  // ── B2B buyer profile ──
  batch.set(db.doc(`b2b_buyers/${B}`), {
    businessName: "Kochi Fresh Mart",
    businessType: "retailer",
    gstNumber: "32AAACK1234F1Z5",
    verified: true,
    district: "Ernakulam",
    address: "42 Market Road, Kaloor, Kochi",
    cropPreferences: ["coconut", "jackfruit"],
    totalOrdersPlaced: 18,
    totalSpent: 84200,
    totalSaved: 11540,
    createdAt: ts(daysAgo(60)),
  });

  // ── Jobs: one active (today, assigned to SM + worker), one complete ──
  batch.set(db.doc("jobs/job-active"), {
    homeownerId: H,
    siteManagerId: SM,
    workerIds: [W],
    cropTypes: ["coconut"],
    estimatedYieldKg: 180,
    actualYieldKg: null,
    gradeA: null,
    gradeB: null,
    tender: null,
    location: jobLoc,
    address: "Kizhakkumpattukara, Ollur",
    district: "Thrissur",
    scheduledAt: ts(today(14, 30)),
    checkInAt: null,
    completedAt: null,
    status: "worker_assigned",
    earningsAmount: 4250,
    feeAmount: 425,
    workerPayout: 620,
    siteManagerPayout: 640,
    paymentStatus: "unpaid",
    reportUrl: null,
    photos: [],
    notes: "Gate on the left; dog is friendly.",
    createdAt: ts(daysAgo(1, 18)),
  });
  batch.set(db.doc("jobs/job-active/statusUpdates/su-1"), {
    type: "arrived",
    step: "arrived",
    title: "Site Manager arrived",
    siteManagerId: SM,
    timestamp: ts(today(9, 5)),
    createdAt: ts(today(9, 5)),
  });

  batch.set(db.doc("jobs/job-complete"), {
    homeownerId: H,
    siteManagerId: SM,
    workerIds: [W],
    cropTypes: ["coconut"],
    estimatedYieldKg: 200,
    actualYieldKg: 212,
    gradeA: 148,
    gradeB: 43,
    tender: 21,
    location: jobLoc,
    address: "Kizhakkumpattukara, Ollur",
    district: "Thrissur",
    scheduledAt: ts(daysAgo(3, 10)),
    checkInAt: ts(daysAgo(3, 9)),
    completedAt: ts(daysAgo(3, 13)),
    status: "complete",
    earningsAmount: 4250,
    feeAmount: 425,
    workerPayout: 620,
    siteManagerPayout: 640,
    paymentStatus: "paid",
    reportUrl: null,
    photos: [],
    notes: "",
    createdAt: ts(daysAgo(4)),
  });
  batch.set(db.doc("jobs/job-complete/yieldData/current"), {
    totalKg: 212,
    gradeA: 148,
    gradeB: 43,
    tender: 21,
    estimatedValue: 4250,
    loggedAt: ts(daysAgo(3, 12)),
    loggedBy: SM,
  });
  const completeSteps = [
    ["arrived", "Site Manager arrived", 9],
    ["workers_confirmed", "Workers confirmed", 10],
    ["harvest_started", "Harvest started", 10],
    ["yield_weighed", "Yield weighed", 12],
    ["complete", "Job complete", 13],
  ];
  completeSteps.forEach(([step, title, hour], i) => {
    batch.set(db.doc(`jobs/job-complete/statusUpdates/su-${i + 1}`), {
      type: step,
      step,
      title,
      siteManagerId: SM,
      timestamp: ts(daysAgo(3, hour)),
      createdAt: ts(daysAgo(3, hour)),
    });
  });

  // ── Homeowner transaction for the completed job ──
  batch.set(db.doc(`homeowners/${H}/transactions/job-complete`), {
    jobId: "job-complete",
    amount: 4250,
    fee: 425,
    createdAt: ts(daysAgo(3, 13)),
  });

  // ── B2B inventory listings ──
  batch.set(db.doc("inventory/inv-1"), {
    jobId: "job-complete",
    cropType: "coconut",
    variety: "West Coast Tall",
    grade: "A",
    quantity: 148,
    quantityRemaining: 120,
    unitPrice: 16,
    wholesaleMarketPrice: 18.2,
    savingsPercent: 12,
    available: true,
    condition: "Fresh, de-husked",
    harvestedAt: ts(daysAgo(3, 13)),
    farmName: "Suresh's Grove",
    farmPlot: "Ollur ward 4",
    farmRating: 4.8,
    farmSince: 2019,
    farmHarvests: 12,
    ward: "Ollur",
    location: jobLoc,
    distanceKm: 3.2,
  });
  batch.set(db.doc("inventory/inv-2"), {
    jobId: "job-complete",
    cropType: "coconut",
    variety: "West Coast Tall",
    grade: "B",
    quantity: 43,
    quantityRemaining: 43,
    unitPrice: 12,
    wholesaleMarketPrice: 14,
    savingsPercent: 14,
    available: true,
    condition: "Fresh, with husk",
    harvestedAt: ts(daysAgo(3, 13)),
    farmName: "Suresh's Grove",
    farmPlot: "Ollur ward 4",
    farmRating: 4.8,
    farmSince: 2019,
    farmHarvests: 12,
    ward: "Ollur",
    location: jobLoc,
    distanceKm: 3.2,
  });
  batch.set(db.doc("inventory/inv-3"), {
    jobId: null,
    cropType: "jackfruit",
    variety: "Varikka",
    grade: "A",
    quantity: 60,
    quantityRemaining: 52,
    unitPrice: 35,
    wholesaleMarketPrice: 42,
    savingsPercent: 17,
    available: true,
    condition: "Tree-ripened",
    harvestedAt: ts(daysAgo(1, 11)),
    farmName: "Menon Orchard",
    farmPlot: "Puthur ward 2",
    farmRating: 4.6,
    farmSince: 2021,
    farmHarvests: 7,
    ward: "Puthur",
    location: new GeoPoint(10.51, 76.26),
    distanceKm: 6.8,
  });

  // ── Market prices (doc id = crop) ──
  batch.set(db.doc("market_prices/coconut"), { wholesalePrice: 18.2 });
  batch.set(db.doc("market_prices/jackfruit"), { wholesalePrice: 42 });
  batch.set(db.doc("market_prices/mango"), { wholesalePrice: 95 });

  // ── One delivered B2B order + tracking + savings record ──
  batch.set(db.doc("b2b_orders/ord-1"), {
    buyerId: B,
    listingId: "inv-1",
    cropType: "coconut",
    grade: "A",
    quantity: 28,
    unitPrice: 16,
    totalAmount: 448,
    savingsAmount: 62,
    deliveryDate: ts(daysAgo(1, 16)),
    deliveryAddress: "42 Market Road, Kaloor, Kochi",
    paymentMethod: "pay_later",
    paymentStatus: "paid",
    status: "delivered",
    invoiceUrl: null,
    createdAt: ts(daysAgo(2, 9)),
  });
  const trackingEvents = [
    ["confirmed", 2, 9, "Order confirmed"],
    ["out_for_delivery", 1, 12, "Out for delivery"],
    ["delivered", 1, 16, "Delivered"],
  ];
  trackingEvents.forEach(([type, d, h, note], i) => {
    batch.set(db.doc(`b2b_orders/ord-1/tracking/t-${i + 1}`), {
      type,
      note,
      timestamp: ts(daysAgo(d, h)),
      location: null,
    });
  });
  batch.set(db.doc(`b2b_buyers/${B}/savings/ord-1`), {
    orderId: "ord-1",
    cropType: "coconut",
    quantity: 28,
    platformPrice: 448,
    savingsAmount: 62,
    createdAt: ts(daysAgo(1, 16)),
  });

  // ── Standing order ──
  batch.set(db.doc("standing_orders/so-1"), {
    buyerId: B,
    cropType: "coconut",
    grade: "A",
    quantityPerOrder: 30,
    maxPricePer: 17,
    frequency: "weekly",
    active: true,
    startDate: ts(daysAgo(21)),
    lastFulfilled: ts(daysAgo(2, 9)),
    nextDue: ts(daysAhead(5)),
  });

  // ── Byproduct buyers ──
  batch.set(db.doc("byproduct_buyers/bp-1"), {
    name: "Kalady Coir Works",
    acceptsTypes: ["coconut_husk"],
    location: new GeoPoint(10.46, 76.27),
  });
  batch.set(db.doc("byproduct_buyers/bp-2"), {
    name: "Green Valley Dairy",
    acceptsTypes: ["jackfruit_rags"],
    location: new GeoPoint(10.52, 76.2),
  });
  batch.set(db.doc("byproduct_buyers/bp-3"), {
    name: "Carbon Craft Charcoal",
    acceptsTypes: ["coconut_shell"],
    location: new GeoPoint(10.48, 76.25),
  });

  await batch.commit();
}

await seedAuth();
await seedFirestore();
console.log("Emulator seeded: 4 auth users + Firestore demo dataset.");
console.log(`  homeowner    +919000000001  (${H})`);
console.log(`  worker       +919000000002  (${W})`);
console.log(`  site manager +919000000003  (${SM})`);
console.log(`  b2b buyer    +919000000004  (${B})`);
process.exit(0);
