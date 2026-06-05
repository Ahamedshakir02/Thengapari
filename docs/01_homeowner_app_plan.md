# Homeowner App — Full Implementation Plan
## Agri-Tech Marketplace · Role: Property Owner
> Flutter · Firebase · Razorpay · Google Maps

---

## App Purpose

The Homeowner App is the **demand side** of the marketplace. A property owner who has fruit-bearing trees — coconut, mango, jackfruit, pepper, areca nut — uses this app to schedule harvests, track live job progress, receive yield reports, pay for the service, and optionally subscribe to an Annual Maintenance Contract (AMC) for automatic seasonal dispatches.

The homeowner never needs to call anyone, coordinate workers, or be present at the property. The app handles everything.

---

## Connection Map

```
Homeowner App
│
├── Firebase Auth ──────────────── Phone OTP login
│
├── Cloud Firestore
│   ├── /users/{uid}               Profile, role, district
│   ├── /homeowners/{uid}/trees    Tree inventory (type, count, age)
│   ├── /jobs/{jobId}              Active and past harvest jobs
│   ├── /jobs/{jobId}/statusUpdates  Real-time step events
│   └── /amc_contracts/{uid}       Subscription plan details
│
├── Firebase Storage
│   └── /job_photos/{jobId}/       Site photos uploaded by Site Manager
│
├── Firebase Cloud Messaging
│   └── Receives: job_started, job_complete, yield_report_ready, amc_reminder
│
├── Firebase Cloud Functions
│   ├── createJob()                Triggers Site Manager assignment
│   ├── calculateYieldEstimate()   Returns price preview before booking
│   └── generateHarvestReport()    Builds PDF report post-job
│
├── Razorpay SDK
│   └── Service fee payment on job completion
│
└── Google Maps Flutter
    └── Live map showing Site Manager + worker location during job
```

---

## Screen Map & Navigation Flow

```
SplashScreen
    └── AuthGate
            ├── LoginScreen (new user)
            │       └── OtpVerifyScreen
            │               └── ProfileSetupScreen
            │                       └── TreeInventorySetupScreen
            │                               └── HomeScreen ←─────────────┐
            └── HomeScreen (returning user) ─────────────────────────────┘
                    ├── BookHarvestScreen
                    │       └── HarvestConfirmScreen
                    │               └── HomeScreen (with active job)
                    ├── LiveJobTrackerScreen
                    │       └── SitePhotoViewerScreen
                    ├── YieldReportScreen
                    │       └── ReportShareSheet
                    ├── PaymentScreen
                    │       └── PaymentSuccessScreen
                    ├── AMCScreen
                    │       └── AMCPlanSelectScreen
                    │               └── AMCConfirmScreen
                    ├── TreeInventoryScreen
                    │       └── AddTreeScreen
                    └── ProfileScreen
```

---

## Screens — Full Specification

---

### 1. SplashScreen

**Purpose:** Brand entry, checks auth state, routes accordingly.

**Widgets:**
- `KeralaLandscapePainter` full-screen (CustomPainter, no package needed)
- App logo centered
- `CircularProgressIndicator` while auth state resolves

**Connections:**
- Listens to `authStateProvider` (Riverpod StreamProvider wrapping `FirebaseAuth.authStateChanges()`)
- Routes to `HomeScreen` if authenticated, `LoginScreen` if not

**Code:**
```dart
class SplashScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (_, state) {
      state.whenData((user) {
        if (user != null) context.go('/homeowner/home');
        else context.go('/login');
      });
    });
    return Scaffold(
      body: Stack(children: [
        CustomPaint(
          painter: KeralaLandscapePainter(),
          child: const SizedBox.expand(),
        ),
        const Center(child: AppLogo()),
      ]),
    );
  }
}
```

---

### 2. LoginScreen + OtpVerifyScreen

**Purpose:** Phone number entry → OTP verification → role assignment.

**Widgets:**
- `AppTextField` (phone number, numeric keyboard, +91 prefix)
- `AppButton` primary — "Send OTP"
- `OtpInputField` — 6 boxes, auto-read on Android via SMS Retriever API
- Countdown resend timer (60s)

**Connections:**
- `FirebaseAuth.verifyPhoneNumber()` → sends OTP
- `PhoneAuthCredential` → `signInWithCredential()`
- On success: checks `/users/{uid}` in Firestore for existing profile
  - Exists → route to `HomeScreen`
  - Missing → route to `ProfileSetupScreen`

**Firebase Auth config required:**
```
Authentication > Sign-in method > Phone > Enable
SHA-1 fingerprint added to Firebase project (for Android auto-read)
```

---

### 3. ProfileSetupScreen + TreeInventorySetupScreen

**Purpose:** First-time user fills name, district, property address, then logs their trees.

**Widgets:**
- `AppTextField` (name, address)
- `DistrictDropdown` — Kerala 14 districts
- `TreeTypeSelector` — grid of crop icons (coconut, mango, jackfruit, pepper, areca)
- `CountStepper` — +/- counter per tree type
- `AppButton` — "Save and continue"

**Connections:**
- Writes to Firestore:
```
/users/{uid} {
  name, phone, district, role: 'homeowner', createdAt
}
/homeowners/{uid}/trees/{treeId} {
  type: 'coconut', count: 24, avgAgeYears: 12, lastHarvested: null
}
```

---

### 4. HomeScreen *(primary screen)*

**Purpose:** Morning dashboard. Shows trees due for harvest, active job status, earnings summary, weekly chart.

**Widgets:**
```
HomeScreen
├── HeroLandscapeWidget          (KeralaLandscapePainter + greeting overlay)
├── CropInventoryRow             (horizontal scrollable crop chips)
├── Row [StatCard × 2]           (₹ earned · weight saved)
├── SectionLabel                 "This month"
├── CustomPaint → WeeklyEarningsChartPainter
├── SectionLabel                 "Active job"
├── JobStatusCard                (real-time, Firestore stream)
├── SectionLabel                 "Upcoming"
├── JobStatusCard                (scheduled jobs)
└── HomeownerBottomNav
```

**Connections:**
- `activeJobProvider(uid)` — StreamProvider on `/jobs` where `homeownerId == uid && status != complete`
- `monthlyEarningsProvider(uid)` — FutureProvider aggregating completed job earnings
- `treeInventoryProvider(uid)` — StreamProvider on `/homeowners/{uid}/trees`
- FCM listener: `job_started` notification deep-links to `LiveJobTrackerScreen`

**Real-time job card update:**
```dart
final activeJobProvider = StreamProvider.family<HarvestJob?, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('jobs')
      .where('homeownerId', isEqualTo: uid)
      .where('status', whereNotIn: ['complete', 'cancelled'])
      .limit(1)
      .snapshots()
      .map((s) => s.docs.isEmpty ? null : HarvestJob.fromJson(s.docs.first.data()));
});
```

---

### 5. BookHarvestScreen

**Purpose:** Homeowner selects which crops to harvest, picks a date, adds notes.

**Widgets:**
- `CropSelectGrid` — tappable cards per tree type (shows count from inventory)
- `DatePickerWidget` — disabled dates: past + already-booked slots
- `CropGradeToggle` — "Harvest all" vs "Ripe only" (for mango/jackfruit)
- `NoteTextField` — optional instructions (gate code, dog in yard, etc.)
- `YieldEstimateCard` — shows estimated yield kg + estimated earning
- `AppButton` — "Confirm booking"

**Connections:**
- `calculateYieldEstimate` Cloud Function call:
```dart
final result = await FirebaseFunctions.instance
    .httpsCallable('calculateYieldEstimate')
    .call({'cropTypes': selected, 'treeCounts': counts, 'district': userDistrict});
// Returns: { estimatedKg: 47.2, estimatedEarning: 4280, marketRate: 91.0 }
```
- On confirm: writes to `/jobs/{newJobId}`:
```
{
  homeownerId, cropTypes, scheduledAt, status: 'pending',
  location: GeoPoint, notes, estimatedYieldKg, createdAt
}
```
- Cloud Function `onJobCreate` triggers → assigns nearest available Site Manager

---

### 6. LiveJobTrackerScreen

**Purpose:** Real-time tracking during an active harvest. Homeowner can watch progress without being on-site.

**Widgets:**
- `JobProgressStepper` — horizontal steps: Assigned → En Route → On-site → Harvesting → Processing → Complete
- `GoogleMap` widget — shows Site Manager pin + worker pins, updates via Firestore GeoPoints
- `SitePhotoStream` — scrollable row of photos uploaded by Site Manager during job
- `LiveWeightCard` — updates as Site Manager logs yield (Firestore real-time listener)
- `ContactManagerButton` — opens phone dialer via `url_launcher`

**Connections:**
- Firestore stream on `/jobs/{jobId}/statusUpdates` (ordered by timestamp):
```dart
final statusUpdatesProvider = StreamProvider.family<List<JobStatusUpdate>, String>(
  (ref, jobId) => FirebaseFirestore.instance
      .collection('jobs/$jobId/statusUpdates')
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map((d) => JobStatusUpdate.fromJson(d.data())).toList()),
);
```
- Firestore stream on `/jobs/{jobId}` for `siteManagerLocation` GeoPoint (updated every 30s by Site Manager app)
- Firebase Storage: photos listed from `/job_photos/{jobId}/`

---

### 7. YieldReportScreen

**Purpose:** Post-harvest summary. Shows exactly what was harvested, graded, and what byproducts were routed where.

**Widgets:**
- `YieldDonutPainter` — Grade A / B / Tender breakdown
- `ByproductRoutingCard` — "12 kg husks → Ravi Coir Factory"
- `WeightLossBadge` — shows kg saved vs before platform (calculated by comparing processing delay)
- `EarningsBreakdownList` — crop × grade × market rate = subtotal
- `ShareReportButton` — generates PDF via Cloud Function, shares via WhatsApp (`share_plus`)

**Connections:**
- `generateHarvestReport` Cloud Function → returns PDF download URL stored in Firebase Storage
- Writes final earnings to `/homeowners/{uid}/transactions/{txId}`

---

### 8. PaymentScreen

**Purpose:** Pay the service fee (platform commission) after harvest is complete.

**Widgets:**
- `InvoiceCard` — itemised: harvest service + site manager fee + platform commission
- `UpiOptionRow` — GPay / PhonePe / Paytm icons (deep-linked via Razorpay)
- `AppButton` — "Pay ₹XXX"
- `PaymentSuccessAnimation` (Lottie)

**Connections:**
- Razorpay order created via Cloud Function (server-side key never exposed to client):
```dart
final order = await FirebaseFunctions.instance
    .httpsCallable('createRazorpayOrder')
    .call({'jobId': jobId, 'amount': feeAmount});
Razorpay().open({
  'key': order.data['keyId'],
  'order_id': order.data['orderId'],
  'amount': order.data['amountPaise'],
});
```
- On `payment.success`: Razorpay webhook → Cloud Function → updates `/jobs/{jobId}` `paymentStatus: 'paid'`

---

### 9. AMCScreen

**Purpose:** Annual Maintenance Contract subscription. Platform auto-dispatches harvest crews based on seasonal crop calendar.

**Widgets:**
- `AMCPlanCard` — Basic / Standard / Premium tiers with crop coverage listed
- `SeasonalCalendarWidget` — visual calendar showing auto-dispatch months per crop
- `AMCSavingsCalculator` — input tree count → shows estimated annual saving vs ad-hoc booking
- `SubscribeButton` → payment → confirmation

**Connections:**
- Writes to `/amc_contracts/{uid}`:
```
{
  plan: 'standard', crops: ['coconut','mango'], startDate,
  annualFee, autoRenew: true, nextDispatch: DateTime
}
```
- Cloud Function `scheduleAMCDispatches` — cron job that fires at crop calendar dates, auto-creates jobs for AMC subscribers

---

## Data Models

```dart
// HarvestJob
{
  id, homeownerId, siteManagerId, workerIds[],
  cropTypes[], status (JobStatus enum),
  location (GeoPoint), scheduledAt, completedAt?,
  estimatedYieldKg, actualYieldKg?,
  gradeA?, gradeB?, tender?,
  earningsAmount?, feeAmount?, paymentStatus,
  notes, photos[]
}

// TreeInventory
{ id, type (CropType), count, avgAgeYears, lastHarvestedAt? }

// AMCContract
{ plan, crops[], startDate, annualFee, autoRenew, nextDispatch }

// Transaction
{ jobId, amount, type: 'earning'|'fee', createdAt, status }
```

---

## State Management (Riverpod Providers)

```
authStateProvider          StreamProvider<AppUser?>
activeJobProvider(uid)     StreamProvider<HarvestJob?>
treeInventoryProvider(uid) StreamProvider<List<TreeInventory>>
jobStatusProvider(jobId)   StreamProvider<List<JobStatusUpdate>>
monthlyEarningsProvider    FutureProvider<double>
amcContractProvider(uid)   StreamProvider<AMCContract?>
livePhotosProvider(jobId)  StreamProvider<List<String>>   ← Storage URLs
```

---

## Notification Handling (FCM)

| Notification type | Trigger | Action in app |
|---|---|---|
| `job_assigned` | Site Manager assigned to job | Show "Your crew is on the way" banner |
| `job_started` | Site Manager checks in on-site | Deep-link to `LiveJobTrackerScreen` |
| `yield_update` | Site Manager logs weight | Update `LiveWeightCard` |
| `job_complete` | All steps done | Navigate to `YieldReportScreen` |
| `payment_due` | Job complete, not paid | Navigate to `PaymentScreen` |
| `amc_dispatch` | Upcoming auto-harvest | Show 3-day advance reminder |

---

## Build Order (Week 4–6)

```
Week 4
├── Day 1–2: Auth flow (Login + OTP + ProfileSetup)
├── Day 3–4: Tree inventory setup screen
└── Day 5:   HomeScreen shell + navigation

Week 5
├── Day 1–2: BookHarvestScreen + yield estimate Cloud Function
├── Day 3–4: LiveJobTrackerScreen + Firestore streams
└── Day 5:   YieldReportScreen

Week 6
├── Day 1–2: PaymentScreen + Razorpay integration
├── Day 3–4: AMCScreen
└── Day 5:   FCM handling + end-to-end flow testing
```

---

## Test Checklist

- [ ] OTP auto-read works on Android (SMS Retriever)
- [ ] Tree inventory saves correctly to Firestore
- [ ] Booking creates job document and triggers Site Manager assignment
- [ ] Job status card updates in real-time without screen refresh
- [ ] Google Maps shows correct pins from Firestore GeoPoints
- [ ] Yield report generates and shares via WhatsApp
- [ ] Razorpay UPI payment completes end-to-end
- [ ] AMC cron creates jobs at correct seasonal dates
- [ ] FCM notifications deep-link to correct screens
- [ ] App tested on Android 8.0+ and ₹10,000-range device
