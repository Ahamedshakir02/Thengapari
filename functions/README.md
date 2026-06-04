# Cloud Functions (Node.js / TypeScript)

Placeholder for the Firebase Cloud Functions backend. Not implemented in the
foundation phase.

Planned functions (see `docs/00_shared_architecture.md`):

- `onJobCreate` — assign nearest Site Manager
- `broadcastWorkerPing` / `acceptPing` — worker job matching (FCM fan-out)
- `broadcastProcessorPing`
- `markJobComplete` — trigger payouts + homeowner report
- `generateHarvestReport` / `generateInvoice` — PDF generation
- `createRazorpayOrder` / `razorpayWebhook` — payments
- `createB2BOrder` / `confirmDelivery` / `updateInventoryOnHarvest`
- `processStandingOrders` / `scheduleAMCDispatches` — scheduled crons
- `updateWorkerReliabilityScore`

To scaffold later:

```bash
npm install -g firebase-tools
firebase init functions   # choose TypeScript
```
