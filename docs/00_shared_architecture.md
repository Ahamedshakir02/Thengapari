# Shared Architecture — All 4 Apps
## Agri-Tech Marketplace · Cross-App Connections & Shared Infrastructure

---

## The Four Apps at a Glance

```
┌─────────────────────────────────────────────────────────────────┐
│                   SINGLE FLUTTER CODEBASE                        │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  ┌────────┐ │
│  │  Homeowner   │  │    Worker    │  │  Site Mgr  │  │  B2B   │ │
│  │     App      │  │     App      │  │    App     │  │ Portal │ │
│  │              │  │              │  │            │  │        │ │
│  │ Book harvest │  │ Accept pings │  │ Run ops    │  │ Buy    │ │
│  │ Track jobs   │  │ Navigate     │  │ Weigh crop │  │ fresh  │ │
│  │ Pay & report │  │ Earn money   │  │ File rpt   │  │ crops  │ │
│  └──────────────┘  └──────────────┘  └────────────┘  └────────┘ │
│                                                                   │
│  Role assigned at first login → GoRouter serves correct app      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Shared Firebase Project Structure

```
Firebase Project: agri-marketplace-prod
│
├── Authentication
│   └── Phone number OTP (all 4 roles use same auth)
│
├── Cloud Firestore
│   ├── /users/{uid}                    Shared user document (all roles)
│   ├── /homeowners/{uid}/              Homeowner-specific subcollections
│   ├── /workers/{uid}/                 Worker-specific subcollections
│   ├── /site_managers/{uid}/           Site Manager subcollections
│   ├── /b2b_buyers/{uid}/              B2B buyer subcollections
│   ├── /jobs/{jobId}/                  Central job record (all roles read/write)
│   │   ├── /statusUpdates/             Checklist events (Site Manager writes)
│   │   ├── /yieldData/                 Yield logging (Site Manager writes)
│   │   └── /workerInstructions/        Notes (Site Manager → Worker)
│   ├── /job_pings/{pingId}/            Worker ping documents (TTL: 45s)
│   ├── /inventory/{listingId}/         B2B live crop listings
│   ├── /b2b_orders/{orderId}/          Purchase orders
│   │   └── /tracking/                  Delivery events
│   ├── /byproduct_routes/{routeId}/    Byproduct buyer assignments
│   ├── /amc_contracts/{uid}/           Annual maintenance subscriptions
│   ├── /standing_orders/{orderId}/     B2B recurring orders
│   ├── /market_prices/{cropType}/      Daily wholesale prices (ops-managed)
│   ├── /byproduct_buyers/{uid}/        Coir factories, dairy farms
│   └── /training_modules/{moduleId}/   Site Manager training content
│
├── Cloud Storage
│   ├── /job_photos/{jobId}/            On-site harvest photos
│   ├── /invoices/{orderId}.pdf         B2B GST invoices
│   ├── /harvest_reports/{jobId}.pdf    Homeowner yield reports
│   ├── /profile_photos/{uid}/          User profile images
│   └── /id_documents/{uid}/           College ID, business docs (admin only)
│
├── Cloud Functions (Node.js / TypeScript)
│   ├── onJobCreate                     Assign nearest Site Manager
│   ├── broadcastWorkerPing             FCM fan-out to nearby workers
│   ├── acceptPing                      Atomic worker assignment
│   ├── broadcastProcessorPing          FCM to nearby processors
│   ├── markJobComplete                 Trigger payouts + homeowner report
│   ├── generateHarvestReport           PDF for homeowner
│   ├── calculateYieldEstimate          Pre-booking price preview
│   ├── createRazorpayOrder             Server-side order creation
│   ├── razorpayWebhook                 Payment confirmation handler
│   ├── createB2BOrder                  Inventory reservation + order creation
│   ├── confirmDelivery                 Mark delivered, write savings record
│   ├── generateInvoice                 GST-compliant invoice PDF
│   ├── updateInventoryOnHarvest        Create listing after job completes
│   ├── processStandingOrders           Daily cron: auto-create B2B orders
│   ├── scheduleAMCDispatches           Seasonal cron: auto-create homeowner jobs
│   └── updateWorkerReliabilityScore    After each job or no-show
│
├── Cloud Messaging (FCM)
│   └── All 4 apps receive topic-based and direct FCM messages
│
└── Analytics + Crashlytics
    └── Shared project — all 4 apps report to same dashboard
```

---

## The Central Job Document

Every harvest event creates one `/jobs/{jobId}` document. All four apps read from and write to it at different stages. This is the single source of truth for a harvest.

```
/jobs/{jobId}
{
  // Who
  homeownerId:      string,
  siteManagerId:    string,     (assigned by onJobCreate function)
  workerIds:        string[],   (added as workers accept pings)

  // What
  cropTypes:        string[],   ['coconut', 'mango']
  estimatedYieldKg: number,
  actualYieldKg:    number?,
  gradeA:           number?,
  gradeB:           number?,
  tender:           number?,

  // Where
  location:         GeoPoint,
  address:          string,
  district:         string,

  // When
  scheduledAt:      Timestamp,
  checkInAt:        Timestamp?,
  completedAt:      Timestamp?,

  // Status (drives all 4 apps' UI)
  status: 'pending' | 'site_manager_assigned' | 'worker_assigned'
        | 'in_progress' | 'harvesting' | 'processing'
        | 'byproducts_routed' | 'complete' | 'cancelled',

  // Money
  earningsAmount:   number?,
  feeAmount:        number?,
  workerPayout:     number?,
  siteManagerPayout:number?,
  paymentStatus:    'unpaid' | 'paid',

  // Outputs
  reportUrl:        string?,
  photos:           string[],

  // Notes
  notes:            string,
  createdAt:        Timestamp
}
```

**Who reads/writes what on this document:**

| Field | Written by | Read by |
|---|---|---|
| `status` | Site Manager app, Cloud Functions | All 4 apps |
| `siteManagerId` | Cloud Function (onJobCreate) | Homeowner, Worker |
| `workerIds` | Cloud Function (acceptPing) | Site Manager |
| `location` | Homeowner app (at booking) | Worker, Site Manager |
| `actualYieldKg`, `gradeA/B/tender` | Site Manager app | Homeowner, B2B (inventory) |
| `reportUrl` | Cloud Function (generateReport) | Homeowner app |
| `paymentStatus` | Cloud Function (razorpayWebhook) | Homeowner app |

**`/jobs/{jobId}/statusUpdates` field contract (cross-app):** the Site Manager
app writes each checklist event with `type` + `step` (the step id, e.g.
`arrived`), `siteManagerId`, `timestamp`, and optional `note` / `location` /
`photoUrl`. It ALSO writes `title` (the human label) and `createdAt`, because
the Homeowner live tracker reads `title`/`step` + `createdAt`.

**Single source of truth (centralized):** these field names are now owned by the
shared core models — do NOT hand-roll the maps in services:
- `/jobs` creation → `HarvestJob.createData(...)`
- `/jobs/{id}/statusUpdates` → `JobStatusUpdate.writeData(...)` (writer) +
  `JobStatusUpdate.fromFirestore(...)` (reader), in the same file
- `/jobs/{id}/yieldData/current` + the parent-job summary mirror →
  `YieldData.writeData(...)` + `YieldData.jobSummary(...)`
- `/inventory/{id}` → `InventoryListing.toFirestore()` for Dart; the live
  production writer is the `updateInventoryOnHarvest` Cloud Function
  (`functions/inventory.ts`) — keep those two in sync.

This is what lets the four apps become separately-compiled packages without the
field names drifting silently between writer and reader.

---

## Cross-App Event Flow: One Complete Harvest

```
1.  Homeowner books harvest
        → /jobs/{id} created with status: 'pending'
        → Cloud Function: onJobCreate fires
        → Assigns nearest available Site Manager
        → /jobs/{id}.status → 'site_manager_assigned'
        → FCM to Site Manager: "New job assigned"

2.  Site Manager accepts and navigates to site
        → /jobs/{id}.status → 'in_progress' (on check-in)
        → /jobs/{id}.siteManagerLocation updated every 30s
        → FCM to Homeowner: "Site Manager has arrived"
        → Homeowner app: shows live location on map

3.  Harvest happens
        → /jobs/{id}/statusUpdates documents written per checklist step
        → Homeowner app: job progress stepper advances in real-time

4.  Yield weighed by Site Manager
        → /jobs/{id}/yieldData/current written
        → /jobs/{id} actualYieldKg, gradeA, gradeB updated
        → Homeowner app: LiveWeightCard updates
        → Cloud Function: updateInventoryOnHarvest creates /inventory/{id}
        → B2B buyers: FCM "New coconuts available — ₹18/pc"

5.  Site Manager broadcasts processor ping
        → Cloud Function: broadcastProcessorPing
        → FCM data message to all online workers within 5km (skill: husker)
        → Worker app: JobPingScreen full-screen takeover

6.  Worker accepts ping
        → Cloud Function: acceptPing (atomic transaction)
        → /job_pings/{id}.status → 'accepted'
        → /jobs/{id}.workerIds.push(workerId)
        → Other pending pings for this job cancelled
        → FCM to Site Manager: "Processor accepted — ETA X mins"

7.  Processing complete, yard cleaned
        → Site Manager routes byproducts
        → /byproduct_routes/{id} written
        → Site Manager generates harvest report

8.  Job marked complete
        → Cloud Function: markJobComplete fires
        → /jobs/{id}.status → 'complete'
        → Razorpay Payout to worker's UPI
        → Razorpay Payout to Site Manager's UPI
        → FCM to Homeowner: "Harvest complete — view report"
        → /homeowners/{uid}/transactions record created
        → /workers/{uid}/earnings record created
        → /workers/{uid}.reliabilityScore updated

9.  Homeowner views report + pays service fee
        → YieldReportScreen shows yield, grades, byproducts
        → Razorpay service fee payment
        → Report shared via WhatsApp

10. B2B buyer sees listing, pre-books
        → createB2BOrder Cloud Function: inventory reserved
        → Order dispatched, tracked, delivered
        → Invoice generated, savings record written
```

---

## Firestore Security Rules (shared)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can read/write only their own profile
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }

    // Jobs: homeowner, assigned site manager, and assigned workers can read
    // Only site manager and cloud functions can write status updates
    match /jobs/{jobId} {
      allow read: if request.auth.uid in [
        resource.data.homeownerId,
        resource.data.siteManagerId
      ] || request.auth.uid in resource.data.workerIds;

      allow create: if request.auth.uid == request.resource.data.homeownerId;

      allow update: if request.auth.uid == resource.data.siteManagerId
                    || request.auth.uid == resource.data.homeownerId;

      match /statusUpdates/{updateId} {
        allow read: if request.auth.uid in [
          get(/databases/$(database)/documents/jobs/$(jobId)).data.homeownerId,
          get(/databases/$(database)/documents/jobs/$(jobId)).data.siteManagerId
        ];
        allow create: if request.auth.uid ==
          get(/databases/$(database)/documents/jobs/$(jobId)).data.siteManagerId;
      }
    }

    // Inventory: all authenticated users can read, only admins can write
    match /inventory/{listingId} {
      allow read: if request.auth != null;
      allow write: if false; // Cloud Functions only
    }

    // B2B orders: only the buyer can read their own orders
    match /b2b_orders/{orderId} {
      allow read: if request.auth.uid == resource.data.buyerId;
      allow create: if request.auth.uid == request.resource.data.buyerId;
      allow update: if false; // Cloud Functions only
    }

    // Workers: workers can read/update their own profile
    match /workers/{uid} {
      allow read, update: if request.auth.uid == uid;
      allow create: if request.auth.uid == uid;
    }

    // Job pings: only target worker can read and respond
    match /job_pings/{pingId} {
      allow read: if request.auth.uid == resource.data.workerId;
      allow update: if request.auth.uid == resource.data.workerId
                    && request.resource.data.status in ['accepted', 'declined'];
    }
  }
}
```

---

## Shared Packages (all 4 apps)

```yaml
# All installed in root pubspec.yaml
# Each app role's feature folder uses only what it needs

firebase_core, firebase_auth, cloud_firestore,
firebase_storage, firebase_messaging, firebase_crashlytics,
firebase_analytics, go_router, flutter_riverpod,
riverpod_annotation, freezed_annotation, json_annotation,
hive, hive_flutter, intl, flutter_localizations,
flutter_dotenv, cached_network_image, url_launcher,
share_plus, image_picker, lottie, shimmer,
flutter_animate, auto_size_text
```

---

## Firebase Environments

```
agri-marketplace-dev     ← local development, test data
agri-marketplace-staging ← pre-launch testing with real devices
agri-marketplace-prod    ← live users

Flutter flavor config:
  --flavor dev    → uses google-services-dev.json
  --flavor prod   → uses google-services-prod.json
```

---

## Build Order Across All 4 Apps

```
Weeks 1–3:   Shared foundation (auth, routing, theme, widget library, painters)
Weeks 4–6:   Homeowner App
Weeks 7–9:   Worker App
Weeks 10–11: Site Manager App
Weeks 12–13: B2B Portal
Weeks 14–15: Integration testing (all 4 apps talking to each other)
Week 16:     Play Store release prep + beta rollout
```

---

## Integration Test: All 4 Apps End-to-End

The final test before launch runs all 4 apps simultaneously on 4 physical devices:

```
Device 1 (Homeowner): Book a coconut harvest for today
        ↓
Device 3 (Site Manager): Receive job assignment FCM, navigate to "property"
        ↓
Device 3 (Site Manager): Check in, work through checklist, log yield
        ↓
Device 2 (Worker):    Receive processor ping, accept, "complete" the job
        ↓
Device 3 (Site Manager): Generate report, mark complete
        ↓
Device 1 (Homeowner): See yield report, make payment
        ↓
Device 4 (B2B):       See new inventory listing appear, pre-book
        ↓
Verify: All Firestore documents in expected state
        All Razorpay payouts triggered
        All FCM notifications received at right moments
        PDF report and invoice generated correctly
```
