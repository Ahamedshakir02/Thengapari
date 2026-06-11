/**
 * ThengaPari Cloud Functions — entrypoint.
 *
 * Functions are grouped by domain in sibling modules and re-exported here so
 * the Firebase CLI discovers them. See docs/00_shared_architecture.md.
 *
 * Razorpay key/secret are bound as runtime secrets (see lib.ts) and never
 * reach any client. Set them once with:
 *   firebase functions:secrets:set RAZORPAY_KEY_ID
 *   firebase functions:secrets:set RAZORPAY_KEY_SECRET
 *   firebase functions:secrets:set RAZORPAY_WEBHOOK_SECRET
 */

// Job lifecycle
export {onJobCreate, markJobComplete} from "./jobs";

// Worker / processor matching
export {broadcastWorkerPing, broadcastProcessorPing, acceptPing} from "./pings";

// Payments
export {createRazorpayOrder, razorpayWebhook} from "./payments";

// B2B commerce
export {createB2BOrder, confirmDelivery} from "./b2b";
export {updateInventoryOnHarvest} from "./inventory";

// PDFs
export {generateHarvestReport, generateInvoice} from "./reports";

// Scheduled
export {processStandingOrders, scheduleAMCDispatches} from "./crons";

// Misc
export {calculateYieldEstimate, updateWorkerReliabilityScore} from "./misc";
