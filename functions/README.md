# Cloud Functions (Node.js / TypeScript)

The ThengaPari backend. Implemented against `docs/00_shared_architecture.md`.
**Not yet deployed** — the Firebase project is on the Spark plan; deploying
requires Blaze.

## Modules (`src/`)
| File | Functions |
|---|---|
| `jobs.ts` | `onJobCreate` (assign nearest site manager), `markJobComplete` (payouts + records + homeowner FCM) |
| `pings.ts` | `broadcastWorkerPing`, `broadcastProcessorPing`, `acceptPing` (atomic, cancels siblings) |
| `payments.ts` | `createRazorpayOrder`, `razorpayWebhook` (HMAC-verified) |
| `b2b.ts` | `createB2BOrder` (atomic inventory decrement), `confirmDelivery` (savings record + invoice) |
| `inventory.ts` | `updateInventoryOnHarvest` (job complete → `/inventory` listing + buyer FCM) |
| `reports.ts` | `generateHarvestReport`, `generateInvoice` (PDFKit → Storage) |
| `crons.ts` | `processStandingOrders` (daily 06:00 IST), `scheduleAMCDispatches` (Mon 05:00 IST) |
| `misc.ts` | `calculateYieldEstimate`, `updateWorkerReliabilityScore` |
| `lib.ts` | Admin SDK handles, geo (haversine), Razorpay client, FCM helpers, **secrets** |

## Atomicity
`acceptPing`, `createB2BOrder` (+ inventory decrement), `markJobComplete`, and
`processStandingOrders`' booking all use Firestore `runTransaction` so two
clients can never grab the same job or over-order the same lot.

## Razorpay secrets (never on the client)
Keys are declared with `defineSecret` in `lib.ts` and bound to the functions
that need them. The client only ever receives the **public** `keyId` + an
`orderId`. Set the secrets before deploying:
```bash
firebase functions:secrets:set RAZORPAY_KEY_ID
firebase functions:secrets:set RAZORPAY_KEY_SECRET
firebase functions:secrets:set RAZORPAY_WEBHOOK_SECRET
```

## Build / deploy (after Blaze upgrade)
```bash
cd functions
npm install
npm run build          # tsc → lib/
firebase deploy --only functions
firebase deploy --only firestore:rules,firestore:indexes
```

Security rules live in `../firestore.rules`; composite indexes in
`../firestore.indexes.json`; both are wired in `../firebase.json`.
