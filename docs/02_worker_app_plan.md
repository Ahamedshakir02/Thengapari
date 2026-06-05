# Worker App — Full Implementation Plan
## Agri-Tech Marketplace · Role: Climber / Husker / Processor
> Flutter · Firebase · Google Maps · Razorpay Payout

---

## App Purpose

The Worker App serves **gig agricultural workers** — coconut tree climbers, huskers, pepper pickers, and jackfruit processors. These workers currently rely on word-of-mouth to find jobs, have unpredictable income, and sit idle even when demand exists nearby.

This app gives them a real-time job feed, instant UPI payouts on completion, a reliability score, and an income record they can show to banks. It is the most time-critical app in the platform — the job ping screen must feel **urgent and fast**.

---

## Connection Map

```
Worker App
│
├── Firebase Auth ──────────────── Phone OTP login
│
├── Cloud Firestore
│   ├── /users/{uid}               Profile, role, skill types
│   ├── /workers/{uid}             isOnline, location, reliabilityScore, fcmToken
│   ├── /jobs/{jobId}              Job details, assignment status
│   ├── /jobs/{jobId}/statusUpdates  Worker check-in, completion events
│   ├── /job_pings/{pingId}        Incoming ping (expires in 45s)
│   └── /workers/{uid}/earnings/{txId}  Per-job payout record
│
├── Firebase Cloud Messaging ────── CRITICAL: receives live job pings
│   └── High-priority data message → wakes app even if backgrounded
│
├── Firebase Cloud Functions
│   ├── acceptPing()               Assigns worker to job, cancels other pings
│   ├── declinePing()              Passes ping to next nearest worker
│   ├── completeJob()              Triggers payout, updates reliability score
│   └── broadcastProcessorPing()   Called by Site Manager, targets this worker
│
├── Geolocator
│   └── Background location updates → writes to /workers/{uid}.location
│
├── Razorpay Payout API (server-side)
│   └── Instant UPI transfer to worker's registered VPA on job completion
│
└── Google Maps Flutter
    └── Turn-by-turn navigation to homeowner property
```

---

## Screen Map & Navigation Flow

```
SplashScreen
    └── AuthGate
            ├── LoginScreen
            │       └── OtpVerifyScreen
            │               └── WorkerProfileSetupScreen
            │                       └── SkillSetupScreen
            │                               └── BankDetailsScreen
            │                                       └── WorkerHomeScreen ←──┐
            └── WorkerHomeScreen ───────────────────────────────────────────┘
                    │
                    ├── [FCM ping arrives] → JobPingScreen (full-screen takeover)
                    │       ├── Accept → NavigationScreen
                    │       └── Decline / Timeout → back to WorkerHomeScreen
                    │
                    ├── NavigationScreen
                    │       └── JobInProgressScreen
                    │               └── JobCompleteScreen
                    │                       └── WorkerHomeScreen
                    │
                    ├── EarningsScreen
                    │       └── EarningDetailScreen
                    │
                    ├── JobHistoryScreen
                    │       └── JobDetailScreen
                    │
                    └── WorkerProfileScreen
                            └── BankDetailsScreen
```

---

## Screens — Full Specification

---

### 1. WorkerProfileSetupScreen + SkillSetupScreen + BankDetailsScreen

**Purpose:** First-time setup. Worker defines their skills and registers UPI VPA for payouts.

**Widgets:**
- `AppTextField` — name, address
- `SkillMultiSelect` — grid of skill badges (climber, husker, pepper picker, jackfruit processor, general labour)
- `DistrictSelector` — operating district
- `UpiVpaField` — validated UPI ID (format: name@upi)
- `AppButton` — "Save and start earning"

**Connections — Firestore writes:**
```dart
// /users/{uid}
{ name, phone, district, role: 'worker', createdAt }

// /workers/{uid}
{
  skills: ['climber', 'husker'],
  upiVpa: 'ravi@okaxis',
  isOnline: false,
  reliabilityScore: 100.0,   // starts at 100, decrements on no-shows
  location: null,
  fcmToken: await FirebaseMessaging.instance.getToken(),
  totalJobsCompleted: 0,
  totalEarned: 0.0
}
```

---

### 2. WorkerHomeScreen

**Purpose:** Daily command center. Toggle availability, see today's confirmed jobs, check earnings, view reliability score.

**Widgets:**
```
WorkerHomeScreen
├── StatusBar (custom)           Dark green bg on this screen
├── WorkerAvailabilityToggle     Online/Offline — writes to Firestore isOnline
├── Row [StatCard × 2]           Today's earnings · Jobs completed today
├── ReliabilityScoreWidget       Circular progress (percent_indicator package)
├── SectionLabel                 "Today's jobs"
├── ConfirmedJobList             Pre-accepted jobs with time + location
├── SectionLabel                 "This week"
├── CustomPaint → WorkerEarningsChartPainter   (daily bar chart)
└── WorkerBottomNav
```

**Connections:**
- `workerAvailabilityProvider` — StateNotifier writes `isOnline` to Firestore on toggle
- Background location service starts when `isOnline = true`:
```dart
void _startLocationTracking(String uid) {
  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.balanced,
      distanceFilter: 50, // update every 50 metres
    ),
  ).listen((pos) {
    FirebaseFirestore.instance.collection('workers').doc(uid).update({
      'location': GeoPoint(pos.latitude, pos.longitude),
      'lastSeen': FieldValue.serverTimestamp(),
    });
  });
}
```
- FCM token refresh listener — updates token on Firestore if rotated

---

### 3. JobPingScreen *(most critical screen in the entire platform)*

**Purpose:** Full-screen takeover when a job ping arrives. Worker has 45 seconds to accept or decline. Designed to feel urgent — dark green background, live countdown, pulsing radar animation.

**This screen must launch even when the app is backgrounded.** Uses FCM high-priority data message + `flutter_local_notifications` to show a full-screen intent on Android.

**Widgets:**
```
JobPingScreen  (Scaffold bg: #0F6E56)
├── AnimatedBuilder → CustomPaint → RadarMapPainter  (pingAnimValue from AnimationController)
├── Column
│   ├── PingHeaderWidget         "NEW JOB PING · 1.8 KM AWAY"
│   ├── JobTitleText             "Coconut husking needed"
│   ├── LocationSubtitle         "Ravi Nair's property, Thrissur West"
│   ├── JobDetailsCard (white)
│   │   ├── WorkerJobDetailRow   Payout · ₹380
│   │   ├── WorkerJobDetailRow   Duration · ~1.5 hrs
│   │   ├── WorkerJobDetailRow   Distance · 1.8 km
│   │   ├── WorkerJobDetailRow   Crop type · 24 coconuts
│   │   └── WorkerJobDetailRow   Site Manager · Arjun K. ⭐4.9
│   ├── CountdownTimerWidget     45s → 0s (turns amber < 20s, red < 10s)
│   └── Row
│       ├── OutlinedButton       "Decline"
│       └── FilledButton         "Accept job"  (white bg, teal text)
└── WorkerBottomNavHidden        (hidden during ping — no escape route)
```

**Background wake-up setup (AndroidManifest.xml):**
```xml
<activity
  android:name=".MainActivity"
  android:showWhenLocked="true"
  android:turnScreenOn="true" />
```

**FCM handler (background):**
```dart
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['type'] == 'job_ping') {
    await FlutterLocalNotificationsPlugin().show(
      0,
      'New job nearby — ₹${message.data['payout']}',
      '${message.data['cropType']} · ${message.data['distanceKm']} km away',
      NotificationDetails(android: AndroidNotificationDetails(
        'job_ping', 'Job Pings',
        fullScreenIntent: true,     // ← wakes screen
        importance: Importance.max,
        priority: Priority.max,
      )),
      payload: jsonEncode(message.data),
    );
  }
}
```

**Connections:**
- Reads `/job_pings/{pingId}` on ping arrive
- `acceptPing(pingId)` Cloud Function — atomic write:
  - Sets `/job_pings/{pingId}.acceptedBy = uid`
  - Sets `/jobs/{jobId}.workerId = uid`, `status = 'worker_assigned'`
  - Cancels remaining pings for this job
  - Sends FCM to Site Manager: "Worker accepted — ETA X mins"
- `declinePing(pingId)` Cloud Function — marks declined, triggers next worker in broadcast queue
- 45s timeout: local `Timer` → calls `declinePing` automatically if no response

---

### 4. NavigationScreen

**Purpose:** Turn-by-turn navigation from worker's current location to the homeowner's property.

**Widgets:**
- `GoogleMap` widget — satellite or normal, worker location (blue dot), destination pin (green)
- `NavigationInfoBanner` — distance remaining, estimated arrival time
- `ContactSiteManagerButton` — tap-to-call `url_launcher('tel:+91...')`
- `ArrivedButton` — "I'm here" — triggers check-in

**Connections:**
- Reads job `location` GeoPoint from Firestore
- Google Maps Directions API (REST) for route calculation:
```dart
final url = Uri.parse(
  'https://maps.googleapis.com/maps/api/directions/json'
  '?origin=${currentLat},${currentLng}'
  '&destination=${jobLat},${jobLng}'
  '&key=$mapsApiKey'
);
```
- "I'm here" → writes to `/jobs/{jobId}/statusUpdates`:
```dart
{ type: 'worker_arrived', workerId: uid, timestamp: now }
```

---

### 5. JobInProgressScreen

**Purpose:** Worker stays on this screen during the harvest. Receives instructions from Site Manager, can photograph progress.

**Widgets:**
- `JobProgressBanner` — "Harvest in progress · Arjun K. supervising"
- `InstructionsFeed` — real-time stream of notes from Site Manager
- `PhotoUploadButton` — camera → `firebase_storage` upload → notifies homeowner
- `ActiveJobTimer` — elapsed time display
- `MarkCompleteButton` — disabled until Site Manager sends OTP confirmation

**Connections:**
- Listens to `/jobs/{jobId}/workerInstructions` collection for Site Manager notes
- Photo upload:
```dart
final ref = FirebaseStorage.instance
    .ref('job_photos/$jobId/${DateTime.now().millisecondsSinceEpoch}.jpg');
await ref.putFile(imageFile);
final url = await ref.getDownloadURL();
await FirebaseFirestore.instance
    .collection('jobs/$jobId/statusUpdates')
    .add({ 'type': 'photo_uploaded', 'url': url, 'by': uid });
```
- Site Manager sends OTP (4-digit code) via Firestore → worker enters it to unlock "Mark complete"

---

### 6. JobCompleteScreen

**Purpose:** Summary after marking complete. Shows payout, breakdown, rating prompt.

**Widgets:**
- `PayoutCard` — "₹380 sent to ravi@okaxis" with Razorpay Payout confirmation
- `JobSummaryCard` — duration, kg processed, crop type
- `SiteManagerRating` — 1–5 stars tap widget
- `HomeownerRating` — 1–5 stars
- `AppButton` — "Back to home"

**Connections:**
- `completeJob` Cloud Function:
  - Updates `/jobs/{jobId}` `status: 'complete'`
  - Calls Razorpay Payout API (server-side):
    ```
    POST https://api.razorpay.com/v1/payouts
    { account_number, fund_account_id, amount, currency, mode: 'UPI' }
    ```
  - Writes to `/workers/{uid}/earnings/{txId}` with payout amount
  - Decrements or maintains `reliabilityScore` based on on-time performance
  - Sends FCM to homeowner: job complete, yield report ready
- Rating writes to `/jobs/{jobId}` `workerRating`, `siteManagerRatingByWorker`

---

### 7. EarningsScreen

**Purpose:** Worker's financial dashboard. Shows income history, weekly trend, tax-ready annual summary.

**Widgets:**
- `CustomPaint → WorkerEarningsChartPainter` — daily earnings bars, last 14 days
- `EarningsPeriodToggle` — Day / Week / Month / Year
- `EarningsSummaryCard` — total earned this period, jobs count, avg per job
- `EarningsListView` — scrollable job-by-job history with amount, date, crop type
- `DownloadStatementButton` — generates PDF income statement via Cloud Function

**Connections:**
- `earningsProvider(uid, period)` — Firestore query on `/workers/{uid}/earnings` filtered by date range
- `downloadIncomeStatement` Cloud Function — builds PDF, returns Storage URL
- Deep-link from notification: `₹380 paid` notification → opens `EarningsScreen`

---

### 8. ReliabilityScoreWidget (shared component)

**Purpose:** Shown on home screen. Score starts at 100 and adjusts based on behaviour.

**Score change rules (enforced by Cloud Functions):**
```
+2   Job completed on time
 0   Job completed slightly late (< 30 mins)
-5   Job cancelled < 2 hours before scheduled time
-10  No-show (no check-in within 30 mins of scheduled time)
-3   Homeowner rating < 3 stars
```

**Visual:** Circular arc, colour: green > 80, amber 60–80, red < 60.

---

## Data Models

```dart
// Worker profile
/workers/{uid} {
  skills: ['climber', 'husker'],
  upiVpa: String,
  isOnline: bool,
  location: GeoPoint,
  reliabilityScore: double,    // 0–100
  fcmToken: String,
  totalJobsCompleted: int,
  totalEarned: double,
  lastSeen: Timestamp
}

// Job ping (expires in 45s — TTL via Cloud Function cleanup)
/job_pings/{pingId} {
  jobId, workerId (target), cropType, payoutAmount,
  distanceKm, estimatedHours, siteManagerName,
  siteManagerRating, jobLocation: GeoPoint,
  expiresAt: Timestamp, status: 'pending'|'accepted'|'declined'|'expired'
}

// Earnings record
/workers/{uid}/earnings/{txId} {
  jobId, cropType, payoutAmount, payoutMethod: 'upi',
  upiRef, paidAt, jobDurationMins, onTime: bool
}
```

---

## State Management

```
workerAvailabilityProvider    StateNotifierProvider<bool>
activeJobProvider(uid)        StreamProvider<HarvestJob?>
incomingPingProvider(uid)     StreamProvider<JobPing?>
earningsProvider(uid, period) FutureProvider<EarningsSummary>
reliabilityScoreProvider(uid) StreamProvider<double>
locationServiceProvider       Provider<LocationService>
```

---

## Notification Handling (FCM)

| Notification type | Trigger | Screen action |
|---|---|---|
| `job_ping` | Site Manager broadcasts | Full-screen `JobPingScreen` takeover |
| `ping_expired` | No response in 45s | Dismiss ping screen, show "ping missed" toast |
| `payout_sent` | Job complete | Show payout amount, navigate to EarningsScreen |
| `site_manager_note` | Manager sends instruction | Toast + badge on JobInProgressScreen |
| `rating_received` | Homeowner rates worker | Show rating received notification |

---

## Build Order (Week 7–9)

```
Week 7
├── Day 1–2: Auth + profile setup + skill selection
├── Day 3:   WorkerHomeScreen + availability toggle + location tracking
└── Day 4–5: FCM setup + background handler + local notification (full-screen intent)

Week 8
├── Day 1–2: JobPingScreen + RadarMapPainter + CountdownTimerWidget
├── Day 3:   Accept/Decline Cloud Function integration
└── Day 4–5: NavigationScreen + Google Maps + arrival check-in

Week 9
├── Day 1–2: JobInProgressScreen + OTP unlock flow
├── Day 3:   JobCompleteScreen + Razorpay Payout integration
└── Day 4–5: EarningsScreen + end-to-end flow testing
```

---

## Test Checklist

- [ ] FCM ping wakes screen from fully backgrounded state (Android)
- [ ] 45-second countdown auto-declines and passes to next worker
- [ ] Accept is atomic — two workers cannot accept the same ping simultaneously (Cloud Function transaction)
- [ ] Location tracking stops when worker sets Offline
- [ ] OTP completion handshake works between Site Manager and Worker apps
- [ ] Razorpay Payout transfers to correct UPI VPA
- [ ] Reliability score decrements correctly on no-show
- [ ] Earnings chart renders correctly for workers with zero earnings (empty state)
- [ ] App handles no internet gracefully — shows last known job details from Hive cache
