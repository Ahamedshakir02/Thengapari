# Site Manager App — Full Implementation Plan
## Agri-Tech Marketplace · Role: Student Operations Supervisor
> Flutter · Firebase · Google Maps · Camera · PDF Generation

---

## App Purpose

The Site Manager App is the **operational nerve centre** of every harvest. A trained college student arrives at the homeowner's property, supervises all workers, accurately weighs and grades the yield, broadcasts a ping to processors the moment harvest ends (solving the weight-loss revenue leak), routes byproducts to buyers, and generates the post-harvest report for the homeowner.

This is the most **feature-dense** app. It is used live, on-site, often in bright outdoor light. UI must be high contrast, large tap targets, and operable with one hand.

---

## Connection Map

```
Site Manager App
│
├── Firebase Auth ──────────────── Phone OTP login
│
├── Cloud Firestore
│   ├── /users/{uid}                   Profile, student details, college
│   ├── /site_managers/{uid}           Rating, jobs completed, currentJobId
│   ├── /jobs/{jobId}                  Assigned job details
│   ├── /jobs/{jobId}/statusUpdates    Step-by-step checklist events (written here)
│   ├── /jobs/{jobId}/yieldData        Grade A/B/tender counts, total kg (live)
│   ├── /jobs/{jobId}/workerInstructions  Notes sent to worker
│   ├── /job_pings/{newPingId}         Broadcast processor ping document
│   └── /byproduct_routes/{routeId}    Byproduct buyer assignment log
│
├── Firebase Storage
│   └── /job_photos/{jobId}/           Photos taken on-site (uploaded here)
│
├── Firebase Cloud Messaging
│   ├── Sends: processor_ping (broadcast to nearby huskers)
│   └── Receives: worker_accepted (processor responded), job_assigned (new job)
│
├── Firebase Cloud Functions
│   ├── broadcastProcessorPing()       Fan-out FCM to nearby processors
│   ├── generateHarvestReport()        PDF generation from job data
│   ├── routeByproducts()              Matches byproduct to nearest buyer
│   └── markJobComplete()              Triggers homeowner notification + payout
│
├── Geolocator
│   └── Continuous location → /jobs/{jobId}.siteManagerLocation (homeowner tracks this)
│
├── Camera (image_picker)
│   └── On-site photos → Firebase Storage → homeowner live feed
│
└── Google Maps Flutter
    └── Navigation to homeowner property + byproduct buyer map
```

---

## Screen Map & Navigation Flow

```
SplashScreen
    └── AuthGate
            ├── LoginScreen
            │       └── OtpVerifyScreen
            │               └── SiteManagerProfileSetupScreen
            │                       └── CollegeVerificationScreen
            │                               └── DailyQueueScreen ←──────┐
            └── DailyQueueScreen ───────────────────────────────────────┘
                    │
                    ├── NavigationToSiteScreen  (pre-arrival)
                    │       └── OnSiteScreen  (main ops screen) ←──────┐
                    │               ├── YieldWeighScreen                │
                    │               │       └── OnSiteScreen ───────────┘
                    │               ├── BroadcastPingScreen
                    │               │       └── ProcessorResponseScreen
                    │               │               └── OnSiteScreen
                    │               ├── ByproductRoutingScreen
                    │               │       └── OnSiteScreen
                    │               └── HarvestReportScreen
                    │                       └── DailyQueueScreen
                    │
                    ├── EarningsScreen
                    ├── TrainingScreen
                    └── ProfileScreen
```

---

## Screens — Full Specification

---

### 1. SiteManagerProfileSetupScreen + CollegeVerificationScreen

**Purpose:** Collect student details, verify college enrollment, set operating zone.

**Widgets:**
- `AppTextField` — name, college name, roll number
- `CollegeBranchDropdown` — engineering / agriculture / science / commerce
- `YearOfStudySelector` — 1st to 4th year
- `DistrictSelector` — operating zone
- `DocumentUploadButton` — college ID photo (goes to Firebase Storage for admin review)
- `AppButton` — "Submit for verification"

**Account approval flow:**
- Profile status: `pending_verification` → admin reviews college ID → sets `verified: true`
- Until verified, app shows "Verification pending" screen, no jobs assigned

**Connections — Firestore writes:**
```dart
// /users/{uid}
{ name, phone, role: 'site_manager', district, createdAt }

// /site_managers/{uid}
{
  collegeName, rollNumber, yearOfStudy,
  verified: false,          // admin sets this to true
  rating: 0.0,
  jobsCompleted: 0,
  currentJobId: null,
  operatingZone: GeoPoint,  // set from device GPS at setup
  fcmToken: await FirebaseMessaging.instance.getToken(),
}
```

---

### 2. DailyQueueScreen

**Purpose:** Morning overview. All jobs assigned for today, sorted by time. Shows map view and list view.

**Widgets:**
```
DailyQueueScreen
├── DateHeader                   "Today, 25 May — 3 jobs assigned"
├── ToggleViewButton             List / Map toggle
├── [List view]
│   ├── QueueJobCard × n
│   │   ├── TimeChip             "9:00 AM"
│   │   ├── HomeownerName        "Ravi Nair's property"
│   │   ├── CropChips            [Coconut ×24] [Mango ×8]
│   │   ├── DistanceChip         "2.1 km"
│   │   └── NavigateButton       → NavigationToSiteScreen
│   └── EmptyStateWidget         (if no jobs — "No jobs assigned today")
├── [Map view]
│   └── GoogleMap                all job pins for today
└── SiteManagerBottomNav
```

**Connections:**
- `todayJobsProvider(uid)` — Firestore query:
```dart
FirebaseFirestore.instance
    .collection('jobs')
    .where('siteManagerId', isEqualTo: uid)
    .where('scheduledAt', isGreaterThan: todayStart)
    .where('scheduledAt', isLessThan: todayEnd)
    .orderBy('scheduledAt')
    .snapshots()
```

---

### 3. NavigationToSiteScreen

**Purpose:** Navigate from current location to homeowner's property before job starts.

**Widgets:**
- `GoogleMap` — route polyline, destination pin
- `ETABanner` — "Arrive in ~12 mins"
- `HomeownerCallButton` — tap-to-call homeowner
- `JobBriefCard` — crop type, count, any special notes from homeowner
- `CheckInButton` — "I've arrived" — enables only when within 100m of destination (Geolocator distance check)

**Connections:**
- Check-in writes to Firestore:
```dart
await FirebaseFirestore.instance
    .collection('jobs/$jobId/statusUpdates')
    .add({
  'type': 'site_manager_arrived',
  'siteManagerId': uid,
  'location': GeoPoint(pos.latitude, pos.longitude),
  'timestamp': FieldValue.serverTimestamp(),
});
// Also update job root document
await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
  'status': 'in_progress',
  'checkInAt': FieldValue.serverTimestamp(),
});
```
- Sends FCM to homeowner: "Your Site Manager has arrived"

---

### 4. OnSiteScreen *(primary operational screen)*

**Purpose:** Live checklist dashboard for the entire harvest operation. The Site Manager works through this checklist from arrival to job completion.

**Widgets:**
```
OnSiteScreen
├── SiteHeader                   "Ravi Nair · Coconut harvest · 9:16 AM"
├── ElapsedTimerWidget           live HH:MM:SS since check-in
├── OnSiteChecklistWidget        (Firestore-driven, see below)
├── YieldSummaryWidget
│   └── CustomPaint → YieldDonutPainter  (updates live as yield is logged)
├── QuickActionsRow
│   ├── PhotoCaptureButton
│   ├── SendNoteToWorkerButton
│   └── EmergencyContactButton
└── SiteManagerBottomNav
```

**Checklist steps (written to `/jobs/{jobId}/statusUpdates`):**

| Step ID | Label | Unlock condition |
|---|---|---|
| `arrived` | Arrived & verified workers | GPS within 100m |
| `harvest_started` | Harvest started | Manual tap |
| `harvest_complete` | Yield harvested | Manual tap |
| `yield_weighed` | Weigh & grade yield | → opens YieldWeighScreen |
| `ping_sent` | Processor ping broadcast | → opens BroadcastPingScreen |
| `byproducts_routed` | Byproducts routed | → opens ByproductRoutingScreen |
| `yard_clean` | Yard cleaned | Manual tap |
| `report_submitted` | Report generated | → opens HarvestReportScreen |

**OnSiteChecklistWidget connection:**
```dart
class OnSiteChecklistWidget extends ConsumerWidget {
  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = ref.watch(jobStepsProvider(jobId));
    return Column(
      children: steps.map((step) => ChecklistItemTile(
        icon: step.icon,
        label: step.label,
        timestamp: step.completedAt,
        status: step.status,
        onTap: step.status == StepStatus.active
            ? () => _handleStepTap(context, step, jobId)
            : null,
      )).toList(),
    );
  }

  void _handleStepTap(BuildContext context, JobStep step, String jobId) {
    switch (step.id) {
      case 'yield_weighed':
        context.push('/manager/weigh/$jobId');
      case 'ping_sent':
        context.push('/manager/broadcast/$jobId');
      case 'byproducts_routed':
        context.push('/manager/byproduct/$jobId');
      case 'report_submitted':
        context.push('/manager/report/$jobId');
      default:
        _completeStep(step.id, jobId);
    }
  }
}
```

---

### 5. YieldWeighScreen

**Purpose:** Log the harvest yield with accurate weight and grade breakdown. This data goes to the homeowner's yield report and triggers the earnings calculation.

**Widgets:**
```
YieldWeighScreen
├── WeightEntryField             Large numeric input (kg, one decimal)
├── ScalePhotoButton             Camera → upload photo of weighing scale
├── CropGradeSelector
│   ├── GradeCounter "Grade A"   +/- stepper, integer count
│   ├── GradeCounter "Grade B"   +/- stepper
│   └── GradeCounter "Tender"    +/- stepper (coconuts only)
├── EstimatedValueCard           Live calc: grade × market rate
├── CustomPaint → YieldDonutPainter  live preview of grade split
├── WeightLossWarning            shows if current kg < expected estimate (orange banner)
└── ConfirmYieldButton           "Save yield data"
```

**Connections:**
```dart
// Writes to /jobs/{jobId}/yieldData (merge, not set — can update multiple times)
await FirebaseFirestore.instance
    .collection('jobs')
    .doc(jobId)
    .collection('yieldData')
    .doc('current')
    .set({
  'totalKg': totalKg,
  'gradeA': gradeA,
  'gradeB': gradeB,
  'tender': tender,
  'estimatedValue': estimatedValue,
  'scalePhotoUrl': scalePhotoUrl,
  'loggedAt': FieldValue.serverTimestamp(),
  'loggedBy': uid,
}, SetOptions(merge: true));

// Also updates /jobs/{jobId} summary fields for homeowner live view
await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
  'currentYieldKg': totalKg,
  'gradeA': gradeA,
  'gradeB': gradeB,
});
```

---

### 6. BroadcastPingScreen

**Purpose:** One-tap broadcast to all nearby processors. Shows real-time incoming Accept responses. The core fix for the weight-loss gap — this must happen immediately after yield is weighed.

**Widgets:**
```
BroadcastPingScreen
├── UrgencyBanner                "Broadcast now — every minute costs weight"
├── NearbyWorkerCount            "8 huskers within 5 km"
├── RadarMapWidget               shows nearby worker dots
├── BroadcastPingButton          animated → triggers Cloud Function
│
├── [After broadcast]
├── LiveResponseList             incoming Accept responses as stream
│   └── WorkerResponseTile × n
│       ├── WorkerName + rating
│       ├── DistanceBadge
│       └── AssignButton         (first to accept auto-assigned, manual override available)
│
└── AssignedConfirmCard          once processor is assigned — shows name, ETA
```

**Connections:**
```dart
// Triggers Cloud Function which fans out FCM to all online workers
// with matching skills within 5km radius
final result = await FirebaseFunctions.instance
    .httpsCallable('broadcastProcessorPing')
    .call({
  'jobId': jobId,
  'cropType': cropType,
  'yieldKg': yieldKg,
  'location': {'lat': lat, 'lng': lng},
  'radiusKm': 5,
  'requiredSkill': 'husker',
});

// Listen for worker Accept responses (real-time)
final responsesStream = FirebaseFirestore.instance
    .collection('job_pings')
    .where('jobId', isEqualTo: jobId)
    .where('status', isEqualTo: 'accepted')
    .snapshots();
```

---

### 7. ByproductRoutingScreen

**Purpose:** Log byproduct types generated and assign them to registered industrial buyers. Turns disposal cost into revenue.

**Widgets:**
```
ByproductRoutingScreen
├── ByproductTypeGrid
│   ├── ByproductCard "Coconut husks"    weight entry + toggle
│   ├── ByproductCard "Coconut shells"   weight entry + toggle
│   ├── ByproductCard "Jackfruit rags"   weight entry + toggle (if applicable)
│   └── ByproductCard "Areca waste"      weight entry + toggle (if applicable)
│
├── NearestBuyerMap              GoogleMap showing registered buyers
├── BuyerMatchList               auto-suggested nearest buyer per byproduct type
│   └── BuyerTile × n
│       ├── BuyerName + type     "Ravi Coir Factory — husks"
│       ├── DistanceChip
│       └── AssignButton
│
└── ConfirmRoutingButton         "Route all byproducts"
```

**Connections:**
```dart
// Query nearest byproduct buyers by type + location
final buyersSnap = await FirebaseFirestore.instance
    .collection('byproduct_buyers')
    .where('acceptsTypes', arrayContains: 'coconut_husk')
    .get();

// Find closest using GeoPoint distance calculation
final sorted = buyersSnap.docs
    .map((d) => ByproductBuyer.fromJson(d.data()))
    .toList()
  ..sort((a, b) =>
      _distance(jobLocation, a.location)
          .compareTo(_distance(jobLocation, b.location)));

// Write routing record
await FirebaseFirestore.instance
    .collection('byproduct_routes')
    .add({
  'jobId': jobId,
  'byproductType': 'coconut_husk',
  'weightKg': huskKg,
  'buyerId': nearestBuyer.id,
  'buyerName': nearestBuyer.name,
  'routedAt': FieldValue.serverTimestamp(),
  'status': 'scheduled_pickup',
});
```

---

### 8. HarvestReportScreen

**Purpose:** Generate and share the final harvest report. This is what the homeowner receives. Marks the job complete.

**Widgets:**
- `ReportPreviewCard` — collapsible summary of all yield data, grade breakdown, byproduct routing
- `SignatureOrOtpWidget` — homeowner confirms via OTP or digital signature
- `GenerateReportButton` — calls Cloud Function → returns PDF Storage URL
- `ShareButtons` — WhatsApp (`share_plus`), Email, Download
- `MarkJobCompleteButton` — triggers final Firestore update + payouts

**PDF report contents (generated by Cloud Function):**
```
1. Property details + harvest date
2. Crop types and counts harvested
3. Yield breakdown: Grade A / B / Tender, total kg
4. Estimated earnings at market rate
5. Weight saved vs average (platform value prop)
6. Byproducts routed + buyers
7. Site Manager signature and ID
8. QR code linking to digital record
```

**Connections:**
```dart
// Generate report
final result = await FirebaseFunctions.instance
    .httpsCallable('generateHarvestReport')
    .call({'jobId': jobId});
final pdfUrl = result.data['pdfUrl'];

// Mark complete
await FirebaseFunctions.instance
    .httpsCallable('markJobComplete')
    .call({'jobId': jobId, 'reportUrl': pdfUrl});

// This Cloud Function:
// 1. Sets /jobs/{jobId} status: 'complete'
// 2. Triggers Razorpay Payout to worker's UPI
// 3. Triggers Razorpay Payout to site manager's UPI
// 4. Sends FCM to homeowner: "Harvest complete — view report"
// 5. Updates /homeowners/{uid}/transactions with earnings
// 6. Updates /workers/{uid} totalJobsCompleted, totalEarned
// 7. Updates /site_managers/{uid} jobsCompleted, rating
```

---

### 9. TrainingScreen

**Purpose:** In-app training modules for new Site Managers. Covers crop grading standards, weighing procedure, safety checklist, how to handle worker disputes.

**Widgets:**
- `TrainingModuleList` — 6 modules with completion badges
- `VideoPlayerWidget` — short explainer videos (hosted on Firebase Storage)
- `QuizWidget` — short multiple-choice quiz per module
- `CertificateBadge` — shown after all modules completed

**Connections:**
- Training content from Firestore `/training_modules` collection (admin-managed)
- Completion state written to `/site_managers/{uid}/trainingProgress`
- Job dispatch blocked until all modules completed (`training_complete: true`)

---

## Data Models

```dart
// Site Manager profile
/site_managers/{uid} {
  collegeName, rollNumber, yearOfStudy,
  verified: bool,
  rating: double,
  jobsCompleted: int,
  currentJobId: String?,
  operatingZone: GeoPoint,
  trainingComplete: bool,
  fcmToken: String
}

// Job step (checklist item)
/jobs/{jobId}/statusUpdates/{updateId} {
  type: String,              // 'arrived' | 'harvest_started' | etc.
  siteManagerId: String,
  timestamp: Timestamp,
  note: String?,
  photoUrl: String?,
  location: GeoPoint?
}

// Yield data
/jobs/{jobId}/yieldData/current {
  totalKg: double,
  gradeA: int, gradeB: int, tender: int,
  estimatedValue: double,
  scalePhotoUrl: String,
  loggedAt: Timestamp,
  loggedBy: String
}

// Byproduct route
/byproduct_routes/{routeId} {
  jobId, byproductType, weightKg,
  buyerId, buyerName, buyerLocation: GeoPoint,
  routedAt, status: 'scheduled_pickup'|'collected'
}
```

---

## State Management

```
todayJobsProvider(uid)          StreamProvider<List<HarvestJob>>
activeJobProvider(uid)          StreamProvider<HarvestJob?>
jobStepsProvider(jobId)         StreamProvider<List<JobStep>>
yieldDataProvider(jobId)        StreamProvider<YieldData?>
nearbyProcessorsProvider(loc)   FutureProvider<List<Worker>>
nearbyBuyersProvider(type, loc) FutureProvider<List<ByproductBuyer>>
pingResponsesProvider(jobId)    StreamProvider<List<JobPing>>
siteManagerProfileProvider(uid) StreamProvider<SiteManagerProfile>
```

---

## Build Order (Week 10–11)

```
Week 10
├── Day 1:   Auth + profile setup + college verification flow
├── Day 2:   DailyQueueScreen + NavigationToSiteScreen
├── Day 3:   OnSiteScreen + checklist widget + step routing
└── Day 4–5: YieldWeighScreen + YieldDonutPainter integration

Week 11
├── Day 1–2: BroadcastPingScreen + Cloud Function + live responses
├── Day 3:   ByproductRoutingScreen + nearest buyer logic
├── Day 4:   HarvestReportScreen + PDF generation + share
└── Day 5:   End-to-end flow test + TrainingScreen
```

---

## Test Checklist

- [ ] College verification flow: upload ID, admin approves, job dispatch unlocks
- [ ] GPS check-in only enables within 100m of job address
- [ ] Checklist steps unlock sequentially — cannot skip ahead
- [ ] Yield data writes update homeowner's live job tracker in real-time
- [ ] Broadcast ping FCM fan-out reaches all online workers within 5km
- [ ] Byproduct routing assigns correct buyer type (husks → coir, rags → dairy)
- [ ] PDF report generates with all correct data and QR code
- [ ] Mark complete triggers payouts for both worker and site manager
- [ ] Photos upload and appear in homeowner's live feed within 5 seconds
- [ ] App works offline for checklist taps — syncs statusUpdates when reconnected

---

## Implementation Status — Flutter build (complete)

All nine screens are implemented in `lib/features/site_manager/` against the
locked theme tokens (`lib/app/design_tokens.dart`) and the `Designs/ThengaPari
Site Manager App/` reference. The Site Manager app uses the light "paper"
palette with a deep brand-ink (`greenForest900`) header.

### Files
```
lib/core/models/
  site_manager_profile.dart   SiteManagerProfile + CollegeBranch + YearOfStudy
  job_step.dart               ManagerStepKind (8 canonical steps) + buildJobSteps()
  yield_data.dart             YieldData + CropGrade (label/price/colour)
  byproduct.dart              ByproductType + ByproductBuyer (haversine) + ByproductRoute
  processor_response.dart     ProcessorResponse (broadcast accept)
lib/core/services/site_manager_service.dart   all Firestore/Functions I/O
lib/core/providers/site_manager_providers.dart
  siteManagerServiceProvider, managerTabProvider, siteManagerProfileProvider,
  todayJobsProvider, jobStepsProvider, yieldDataProvider, pingResponsesProvider,
  nearbyBuyersProvider
lib/features/site_manager/widgets/sm_widgets.dart   shared ".kera" widget kit
lib/features/site_manager/screens/
  sm_profile_setup_screen.dart      (1) profile + college details + ID upload
  college_verification_screen.dart  (1) admin-approval pending gate
  home_screen.dart                  shell: Today / On-site / Earnings / Profile
  daily_queue_screen.dart           (2) list + map toggle
  navigation_to_site_screen.dart    (3) 100 m GPS check-in gate (Geolocator)
  on_site_screen.dart               (4) checklist (jobStepsProvider) + yield donut
  yield_weigh_screen.dart           (5) keypad + grade counters + live donut
  broadcast_ping_screen.dart        (6) broadcast → live response stream → assign
  byproduct_routing_screen.dart     (7) nearest-buyer matching by type + distance
  harvest_report_screen.dart        (8) preview, sign-off, generate PDF, complete
  training_screen.dart              (9) modules + badges + certificate
lib/main_manager_dev.dart           dev harness (in-memory demo service)
```

### Run the dev harness
```
flutter run --flavor dev -t lib/main_manager_dev.dart
```
The harness signs in anonymously and overrides `siteManagerServiceProvider` with
an in-memory demo service, so the full flow (checklist → weigh → broadcast →
byproducts → report) is interactive without live Firestore. The real app uses
the unmodified `SiteManagerService` and the role-based router gate
(`siteManager && !isProfileComplete` → profile setup; verification gate is
reachable during onboarding and from the Profile tab).

### Cross-app contract verified
Checklist steps write to `/jobs/{jobId}/statusUpdates` with **both** the spec
fields (`type`, `timestamp`, `siteManagerId`, `location`) **and** the fields the
Homeowner live tracker reads (`title`, `createdAt`) — see
`SiteManagerService.completeStep`. `saveYield` writes
`/jobs/{jobId}/yieldData/current` and mirrors `actualYieldKg` / `gradeA` /
`gradeB` / `tender` onto the parent job for the Homeowner LiveWeightCard.

### Deferred to Cloud Functions / later (needs Blaze)
`broadcastProcessorPing`, `generateHarvestReport`, `markJobComplete` are wired as
`cloud_functions` callables but not deployed (project is on Spark). Photo upload
to Firebase Storage and Google Maps tiles are stubbed with painted placeholders
for review. The 100 m check-in includes a dev "simulate arrival" affordance.
