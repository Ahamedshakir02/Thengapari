# B2B Portal App — Full Implementation Plan
## Agri-Tech Marketplace · Role: Local Business Buyer
> Flutter · Firebase · Razorpay · Google Maps

---

## App Purpose

The B2B Portal serves **local business buyers** — juice stalls, bakeries, chips manufacturers, spice traders, coir factories, and dairy farmers. These buyers currently source raw materials through wholesale middlemen at inflated markups, receiving stale produce with no supply chain visibility.

This app gives them a **direct line to source**: live inventory updated as crops are harvested, pre-booking with price locks, savings analytics vs. wholesale prices, and a standing order subscription for predictable supply.

This app has the **highest revenue per transaction** in the platform. It is also the most likely to attract institutional investors because it demonstrates B2B traction — not just gig economy activity.

---

## Connection Map

```
B2B Portal App
│
├── Firebase Auth ──────────────── Phone OTP + Business verification
│
├── Cloud Firestore
│   ├── /users/{uid}                   Profile, role, business type
│   ├── /b2b_buyers/{uid}              Business name, GST, verified status
│   ├── /inventory/{listingId}         Live crop listings (written by platform ops)
│   ├── /b2b_orders/{orderId}          Orders placed by this buyer
│   ├── /b2b_orders/{orderId}/tracking  Delivery status events
│   ├── /standing_orders/{uid}         Weekly/monthly recurring orders
│   └── /b2b_buyers/{uid}/savings      Per-order savings vs wholesale
│
├── Firebase Cloud Functions
│   ├── createB2BOrder()               Reserves inventory, locks price
│   ├── confirmDelivery()              Marks order delivered, triggers invoice
│   ├── generateInvoice()              PDF invoice for GST compliance
│   ├── updateInventory()              Called by ops after each harvest
│   └── processStandingOrder()         Cron: auto-creates orders for subscribers
│
├── Firebase Cloud Messaging
│   └── Receives: new_stock_available, order_confirmed,
│                 order_dispatched, delivery_due, price_drop_alert
│
├── Razorpay SDK
│   └── Pre-payment or pay-on-delivery based on business tier
│
└── Google Maps Flutter
    └── Delivery location pin, farm-to-door distance display
```

---

## Screen Map & Navigation Flow

```
SplashScreen
    └── AuthGate
            ├── LoginScreen
            │       └── OtpVerifyScreen
            │               └── BusinessProfileSetupScreen
            │                       └── GSTVerificationScreen
            │                               └── InventoryScreen ←──────────┐
            └── InventoryScreen ────────────────────────────────────────────┘
                    │
                    ├── ListingDetailScreen
                    │       └── PreBookScreen
                    │               └── OrderConfirmScreen
                    │                       └── InventoryScreen
                    │
                    ├── OrdersScreen
                    │       ├── ActiveOrdersTab
                    │       │       └── OrderTrackingScreen
                    │       └── HistoryOrdersTab
                    │               └── OrderDetailScreen
                    │                       └── InvoiceViewScreen
                    │
                    ├── DashboardScreen
                    │       ├── SavingsChartWidget
                    │       ├── SpendAnalyticsWidget
                    │       └── StandingOrderScreen
                    │               └── StandingOrderSetupScreen
                    │
                    └── ProfileScreen
                            └── GSTDetailsScreen
```

---

## Screens — Full Specification

---

### 1. BusinessProfileSetupScreen + GSTVerificationScreen

**Purpose:** Onboard a business buyer. Collect business details, verify GST, set buying preferences.

**Widgets:**
- `AppTextField` — business name, owner name, address
- `BusinessTypeSelector` — Juice stall / Bakery / Chips manufacturer / Spice trader / Coir factory / Dairy farm / Restaurant / Other
- `GSTTextField` — validated 15-character GST format (regex validation)
- `CropPreferenceSelector` — which crops they want to buy (multi-select)
- `PreferredQuantityRange` — min kg per order, max kg per order
- `AppButton` — "Submit for verification"

**Account verification:**
- Admin reviews GST number against government database
- Sets `/b2b_buyers/{uid}.verified: true`
- Until verified: read-only inventory browse, cannot place orders

**Connections — Firestore writes:**
```dart
// /users/{uid}
{ name, phone, role: 'b2b', createdAt }

// /b2b_buyers/{uid}
{
  businessName: 'Rajan Juice Stall',
  businessType: 'juice_stall',
  gstNumber: '32AABCR1234F1Z5',
  address, district,
  cropPreferences: ['coconut', 'mango'],
  verified: false,
  totalOrdersPlaced: 0,
  totalSpent: 0.0,
  totalSaved: 0.0,
  fcmToken: await FirebaseMessaging.instance.getToken(),
}
```

---

### 2. InventoryScreen *(primary screen)*

**Purpose:** Live browse of available crops across the district. Updated as each harvest completes. The savings vs. wholesale price is shown prominently on every listing.

**Widgets:**
```
InventoryScreen
├── B2BHeaderWidget              Dark blue header, "Live produce inventory · Today"
├── SavingsBandWidget            "Your savings vs wholesale this month: ₹2,140"
├── CustomPaint → SavingsBarChartPainter   savings % per crop type
├── FilterRow
│   ├── CropTypeFilterChips      All / Coconut / Mango / Pepper / Jackfruit / Areca
│   ├── GradeFilterChip          All / Grade A / Grade B
│   └── DistanceFilterChip       Within 5 km / 10 km / 20 km
├── SectionLabel                 "Available now (harvested today)"
├── LiveInventoryList
│   └── LiveInventoryTile × n   (real-time, Firestore stream)
│       ├── CropIconDot
│       ├── CropName + Grade
│       ├── HarvestMeta          "Harvested today · Manjaly ward · 200+ units"
│       ├── PriceLabel           "₹18/pc"
│       ├── SavingsBadge         "↓12% vs market"
│       └── PreBookButton        → ListingDetailScreen
└── B2BBottomNav
```

**Connections:**
- `liveInventoryProvider` — Firestore real-time stream with filter state:
```dart
final liveInventoryProvider = StreamProvider.family<List<CropListing>, InventoryFilter>(
  (ref, filter) {
    Query<Map<String, dynamic>> q = FirebaseFirestore.instance
        .collection('inventory')
        .where('available', isEqualTo: true)
        .where('quantityRemaining', isGreaterThan: 0)
        .orderBy('harvestedAt', descending: false);

    if (filter.cropType != null) {
      q = q.where('cropType', isEqualTo: filter.cropType);
    }
    if (filter.grade != null) {
      q = q.where('grade', isEqualTo: filter.grade);
    }

    return q.snapshots()
        .map((s) => s.docs.map((d) => CropListing.fromJson(d.data())).toList());
  },
);
```
- `monthlySavingsProvider` — aggregates `/b2b_buyers/{uid}/savings` collection
- FCM: `new_stock_available` notification deep-links here with crop pre-filtered

---

### 3. ListingDetailScreen

**Purpose:** Full details for a specific crop listing. Shows farm source, freshness, grade breakdown, and price comparison against wholesale.

**Widgets:**
- `CropHeroCard` — large crop icon, name, grade, harvest time (e.g. "Harvested 2 hours ago")
- `FreshnessIndicator` — progress bar: 0–4h = "Peak fresh", 4–12h = "Fresh", 12h+ = "Good"
- `PriceComparisonWidget` — two bars side by side: platform price vs. APMC wholesale price
- `FarmSourceCard` — ward name, approximate farm size, distance from buyer
- `QuantityAvailableWidget` — "142 units remaining" (live)
- `QuantitySelector` — +/- input for desired quantity
- `PriceLockBanner` — "Price locked for 24 hours once you pre-book"
- `PreBookButton` — navigates to `PreBookScreen`

**Connections:**
- `listingDetailProvider(listingId)` — single document stream
- Market price comparison: fetches from `/market_prices/{cropType}` (updated daily by ops team from agmarknet.gov.in or manual entry)

---

### 4. PreBookScreen + OrderConfirmScreen

**Purpose:** Confirm quantity, preferred delivery date, and payment method. Place order.

**Widgets:**
```
PreBookScreen
├── OrderSummaryCard
│   ├── CropName + Grade
│   ├── QuantityDisplay          "120 coconuts"
│   ├── UnitPrice                "₹18/pc"
│   ├── SubtotalLine             "₹2,160"
│   ├── PlatformFeeNote          "No middleman fee — direct from source"
│   └── SavingsHighlight         "Saving ₹324 vs wholesale (₹20.70/pc)"
│
├── DeliveryDatePicker           available dates based on harvest schedule
├── DeliveryAddressCard          pre-filled from business profile, editable
│
├── PaymentMethodSelector
│   ├── PayNowOption             Razorpay UPI / card
│   └── PayOnDeliveryOption      (available for verified businesses, tier 2+)
│
└── ConfirmOrderButton
```

**Connections:**
```dart
// createB2BOrder Cloud Function — atomic:
// 1. Checks quantityRemaining >= requested amount
// 2. Decrements inventory quantityRemaining
// 3. Creates /b2b_orders/{orderId}
// 4. Sends confirmation FCM to buyer
// 5. Notifies ops team via Slack webhook

final result = await FirebaseFunctions.instance
    .httpsCallable('createB2BOrder')
    .call({
  'listingId': listingId,
  'quantity': quantity,
  'deliveryDate': deliveryDate.toIso8601String(),
  'paymentMethod': paymentMethod,
  'buyerId': uid,
});

// If pay now: opens Razorpay with returned order details
if (paymentMethod == 'pay_now') {
  Razorpay().open({
    'key': result.data['keyId'],
    'order_id': result.data['orderId'],
    'amount': result.data['amountPaise'],
  });
}
```

**Order document created:**
```
/b2b_orders/{orderId} {
  buyerId, listingId, cropType, grade, quantity,
  unitPrice, totalAmount, savingsAmount,
  deliveryDate, deliveryAddress, paymentMethod,
  paymentStatus: 'pending'|'paid',
  status: 'confirmed'|'dispatched'|'delivered'|'cancelled',
  createdAt
}
```

---

### 5. OrdersScreen + OrderTrackingScreen

**Purpose:** All active and past orders. Real-time tracking for in-flight orders.

**Active orders tab widgets:**
- `OrderStatusCard` × n (real-time stream)
  - Crop name + quantity
  - `OrderProgressStepper` — Confirmed → Dispatched → Out for Delivery → Delivered
  - Estimated delivery date
  - `TrackOrderButton` → `OrderTrackingScreen`
  - `ContactDriverButton` (when dispatched)

**Order tracking screen widgets:**
- `GoogleMap` — delivery driver location pin (live from Firestore)
- `DeliveryTimeBanner` — "Arriving in ~18 mins"
- `TrackingTimelineWidget` — vertical timeline with timestamps
- `InvoiceDownloadButton` (after delivery)
- `ConfirmDeliveryButton` — buyer confirms receipt

**Connections:**
```dart
// Active orders stream
final activeOrdersProvider = StreamProvider<List<B2BOrder>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  return FirebaseFirestore.instance
      .collection('b2b_orders')
      .where('buyerId', isEqualTo: uid)
      .where('status', whereNotIn: ['delivered', 'cancelled'])
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => B2BOrder.fromJson(d.data())).toList());
});

// Order tracking events stream
final orderTrackingProvider =
    StreamProvider.family<List<TrackingEvent>, String>((ref, orderId) {
  return FirebaseFirestore.instance
      .collection('b2b_orders/$orderId/tracking')
      .orderBy('timestamp')
      .snapshots()
      .map((s) => s.docs.map((d) => TrackingEvent.fromJson(d.data())).toList());
});

// Confirm delivery — calls Cloud Function
await FirebaseFunctions.instance
    .httpsCallable('confirmDelivery')
    .call({'orderId': orderId});
// Cloud Function: updates order status, generates invoice PDF, writes savings record
```

---

### 6. DashboardScreen

**Purpose:** Business analytics. Shows total spend, savings vs wholesale, crop breakdown, top-value crops. This screen is the investor-facing proof of value — buyers see exactly how much money the platform is saving them.

**Widgets:**
```
DashboardScreen
├── PeriodToggle                 Week / Month / Quarter / Year
├── SavingsSummaryCard
│   ├── TotalSaved               "₹14,320 saved this month"
│   ├── VsWholesalePercent       "11.4% below wholesale average"
│   └── OrderCount               "32 orders placed"
│
├── CustomPaint → SavingsBarChartPainter   per-crop savings %
│
├── SpendTrendChart              (fl_chart LineChart — spend per week)
│
├── CropBreakdownWidget          pie-style breakdown of spend per crop
│
├── TopCropValueCard             "Best saving: Jackfruit — 20% below market"
│
├── SectionLabel                 "Standing orders"
├── StandingOrderSummaryList
│   └── StandingOrderTile × n
│       ├── CropName + frequency
│       ├── NextDispatch date
│       └── EditButton
│
└── B2BBottomNav
```

**Connections:**
```dart
// Monthly savings aggregation
final monthlySavingsProvider = FutureProvider<SavingsSummary>((ref) async {
  final uid = ref.watch(authStateProvider).value?.uid;
  final snap = await FirebaseFirestore.instance
      .collection('b2b_buyers/$uid/savings')
      .where('createdAt', isGreaterThan: _30DaysAgo())
      .get();
  
  double totalSaved = 0;
  final Map<String, double> perCrop = {};
  for (final doc in snap.docs) {
    final d = doc.data();
    totalSaved += d['savingsAmount'] as double;
    perCrop[d['cropType'] as String] =
        (perCrop[d['cropType']] ?? 0) + (d['savingsAmount'] as double);
  }
  return SavingsSummary(totalSaved: totalSaved, perCrop: perCrop);
});

// Weekly spend for fl_chart
final weeklySpendProvider = FutureProvider<List<FlSpot>>((ref) async {
  final uid = ref.watch(authStateProvider).value?.uid;
  final snap = await FirebaseFirestore.instance
      .collection('b2b_orders')
      .where('buyerId', isEqualTo: uid)
      .where('status', isEqualTo: 'delivered')
      .where('createdAt', isGreaterThan: _8WeeksAgo())
      .get();
  // Group by week, sum amounts
  return _groupByWeek(snap.docs);
});
```

---

### 7. StandingOrderScreen + StandingOrderSetupScreen

**Purpose:** Subscribe to recurring orders. Buyer defines a weekly or monthly requirement, platform auto-books when fresh stock becomes available.

**Widgets:**
```
StandingOrderSetupScreen
├── CropTypeSelector             one crop per standing order
├── GradePreference              Grade A only / Grade A + B / Any
├── QuantityPerOrder             amount per dispatch (e.g. 100 coconuts)
├── FrequencySelector            Weekly / Bi-weekly / Monthly
├── MaxPriceToggle               "Skip dispatch if price > ₹22/pc" (optional)
├── StartDatePicker
├── PriceEstimateCard            "Estimated monthly spend: ₹8,400–9,600"
└── ActivateButton               "Start standing order"
```

**Connections:**
```dart
// /standing_orders/{uid} subcollection entry
await FirebaseFirestore.instance
    .collection('standing_orders')
    .add({
  'buyerId': uid,
  'cropType': cropType,
  'grade': gradePreference,
  'quantityPerOrder': quantity,
  'frequency': 'weekly',
  'maxPricePer': maxPrice,
  'startDate': startDate,
  'active': true,
  'lastFulfilled': null,
  'nextDue': startDate,
});

// Cloud Function cron (every morning 6 AM):
// 1. Finds standing_orders where nextDue <= today and active == true
// 2. Checks inventory for matching crop + grade + quantity
// 3. If found: auto-creates b2b_order, sends FCM: "Standing order placed: 100 coconuts"
// 4. If not found: sends FCM: "Standing order delayed — no matching stock today"
// 5. Updates nextDue to next cycle date
```

---

### 8. InvoiceViewScreen

**Purpose:** GST-compliant invoice PDF viewer and downloader for each completed order. Essential for B2B buyers who need invoice documentation.

**Widgets:**
- `PdfViewer` (syncfusion_flutter_pdfviewer) — renders PDF inline
- `DownloadButton` — saves to device Downloads folder
- `ShareButton` — WhatsApp or email to accountant
- `InvoiceDetailSummary` — order ref, GST breakdown, HSTN code

**Invoice PDF contents (generated by Cloud Function):**
```
Header:    Platform name, GST number, invoice number, date
Buyer:     Business name, GST, address
Seller:    Farm collective details
Line items: Crop × quantity × unit price × IGST/CGST/SGST rate
Total:     Taxable value, tax amount, grand total
Notes:     "Fresh produce — harvested on [date] from [ward]"
```

**Connections:**
```dart
// generateInvoice called when order marked delivered
final invoiceUrl = await FirebaseFunctions.instance
    .httpsCallable('generateInvoice')
    .call({'orderId': orderId});
// PDF stored at /invoices/{orderId}.pdf in Firebase Storage
// URL saved to /b2b_orders/{orderId}.invoiceUrl
```

---

## Data Models

```dart
// B2B Buyer profile
/b2b_buyers/{uid} {
  businessName, businessType, gstNumber,
  address, district, verified: bool,
  cropPreferences: [],
  totalOrdersPlaced: int,
  totalSpent: double,
  totalSaved: double,
  fcmToken: String
}

// Crop listing (written by platform ops after each harvest)
/inventory/{listingId} {
  cropType, grade, quantity, quantityRemaining,
  unitPrice, wholesaleMarketPrice,
  savingsPercent,                    // calculated: (wholesale - platform) / wholesale * 100
  harvestedAt: Timestamp,
  location: GeoPoint, ward: String,
  available: bool,
  jobId: String                      // link to source job
}

// B2B Order
/b2b_orders/{orderId} {
  buyerId, listingId, cropType, grade,
  quantity, unitPrice, totalAmount,
  savingsAmount, deliveryDate,
  deliveryAddress, paymentMethod,
  paymentStatus, status,
  invoiceUrl: String?,
  createdAt, confirmedAt?, deliveredAt?
}

// Standing Order
/standing_orders/{orderId} {
  buyerId, cropType, grade, quantityPerOrder,
  frequency, maxPricePer?: double,
  startDate, nextDue, active: bool,
  lastFulfilled: Timestamp?
}

// Savings record (written per order on delivery)
/b2b_buyers/{uid}/savings/{recordId} {
  orderId, cropType, quantity,
  platformPrice, wholesalePrice,
  savingsAmount, savingsPercent,
  createdAt
}

// Tracking event
/b2b_orders/{orderId}/tracking/{eventId} {
  type: 'confirmed'|'dispatched'|'out_for_delivery'|'delivered',
  timestamp: Timestamp,
  note: String?,
  location: GeoPoint?
}
```

---

## State Management

```
authStateProvider                  StreamProvider<AppUser?>
b2bProfileProvider(uid)            StreamProvider<B2BBuyerProfile>
liveInventoryProvider(filter)      StreamProvider<List<CropListing>>
activeOrdersProvider               StreamProvider<List<B2BOrder>>
orderHistoryProvider               FutureProvider<List<B2BOrder>>
orderTrackingProvider(orderId)     StreamProvider<List<TrackingEvent>>
monthlySavingsProvider             FutureProvider<SavingsSummary>
weeklySpendProvider                FutureProvider<List<FlSpot>>
standingOrdersProvider(uid)        StreamProvider<List<StandingOrder>>
marketPricesProvider               FutureProvider<Map<String, double>>
```

---

## Notification Handling (FCM)

| Notification type | Trigger | Action |
|---|---|---|
| `new_stock_available` | Harvest completes for preferred crop | Deep-link to InventoryScreen filtered by crop |
| `price_drop_alert` | Inventory price reduced | Banner: "Coconuts now ₹16/pc — ₹2 drop" |
| `order_confirmed` | Order placed successfully | Navigate to OrdersScreen |
| `order_dispatched` | Driver picks up order | Deep-link to OrderTrackingScreen |
| `delivery_due` | Delivery expected today | Reminder banner |
| `standing_order_placed` | Cron auto-creates order | "Your weekly coconut order is confirmed" |
| `standing_order_skipped` | No matching stock | "Standing order skipped — no Grade A coconut today" |

---

## Admin-Side Inventory Management

The inventory listings that buyers see are created by the platform operations team (or automatically) after each harvest completes. The flow is:

```
Harvest complete (Site Manager marks job done)
        ↓
Cloud Function: onJobComplete
        ↓
Creates /inventory/{listingId} with:
  - cropType, grade, quantity, yieldKg from job's yieldData
  - unitPrice: fetched from /market_prices/{cropType} × (1 - platformDiscount)
  - wholesaleMarketPrice: from /market_prices/{cropType}
  - savingsPercent: auto-calculated
  - harvestedAt: job.completedAt
  - available: true
        ↓
Standing order cron checks if any buyer has matching preferences
        ↓
FCM sent to buyers with matching cropPreferences
```

---

## Build Order (Week 12–13)

```
Week 12
├── Day 1:   Auth + business profile setup + GST verification
├── Day 2:   InventoryScreen + live stream + filter row
├── Day 3:   ListingDetailScreen + price comparison widget
└── Day 4–5: PreBookScreen + createB2BOrder Cloud Function + Razorpay

Week 13
├── Day 1:   OrdersScreen + OrderTrackingScreen + real-time tracking
├── Day 2:   DashboardScreen + savings chart + fl_chart spend trend
├── Day 3:   StandingOrderScreen + cron Cloud Function
├── Day 4:   InvoiceViewScreen + generateInvoice PDF Cloud Function
└── Day 5:   FCM handlers + end-to-end flow + notifications test
```

---

## Test Checklist

- [ ] GST format validation rejects invalid formats
- [ ] Inventory listings update in real-time when new harvest completes
- [ ] Quantity decrement is atomic — two buyers cannot over-order same stock (Firestore transaction)
- [ ] Price lock holds for 24 hours after pre-booking even if market price changes
- [ ] Razorpay payment completes and updates order paymentStatus
- [ ] Pay-on-delivery only available for verified buyers
- [ ] Standing order cron creates correct orders at right intervals
- [ ] Invoice PDF includes correct GST breakdown
- [ ] Savings calculations match manually computed values
- [ ] Order tracking map updates when driver location changes
- [ ] FCM new_stock notification filtered to matching cropPreferences only
- [ ] App tested with 100+ inventory listings for performance (no jank in ListView)

---

## Implementation Status — Flutter build (complete)

All eight screens are implemented in `lib/features/b2b/` against the locked
theme tokens (deep-blue header, green savings band, amber CTAs) and the
`Designs/ThengaPari B2B Portal App/` reference.

### Files
```
lib/core/models/
  inventory_listing.dart   InventoryListing + B2BCrop (tint/unit/glyph)
  b2b_buyer_profile.dart   B2BBuyerProfile + BusinessType + GST regex
  b2b_order.dart           B2BOrder + B2BOrderStatus + TrackingEvent
  standing_order.dart      StandingOrder + StandingFrequency
  b2b_savings.dart         SavingsSummary
lib/core/services/b2b_service.dart      all Firestore/Functions I/O
lib/core/providers/b2b_providers.dart   InventoryFilter, liveInventoryProvider, …
lib/features/b2b/widgets/b2b_widgets.dart   blue theme kit + painted CropGlyph
lib/features/b2b/screens/
  business_profile_setup_screen.dart  (1) + gst_verification_screen.dart (1)
  home_screen.dart                    shell: Market / Orders / Savings
  inventory_screen.dart               (2) live stream + filters (lazy list)
  listing_detail_screen.dart          (3) freshness + price-comparison bars
  prebook_screen.dart                 (4) + success
  orders_screen.dart                  (5) active/history + stepper
  order_tracking_screen.dart          (5) map + timeline + confirm
  dashboard_screen.dart               (6) savings + fl_chart spend trend
  standing_order_screen.dart          (7)
  invoice_view_screen.dart            (8) GST breakdown
lib/main_b2b_dev.dart                  dev harness (120 seeded lots)
```

### Run the dev harness
```
flutter run --flavor dev -t lib/main_b2b_dev.dart
```
Seeds 120 inventory lots (the perf check — the market uses a lazy
`ListView.builder`), plus orders, savings, and standing orders. GST validation
uses the 15-char GSTIN regex in `B2BBuyerProfile.gstPattern`. The role gate
(`b2b && !isProfileComplete`) routes to business setup; the GST verification
screen allows read-only browse until `verified == true`.

### Cross-app link
Inventory listings are created by the `updateInventoryOnHarvest` Cloud Function
when a Site Manager marks a job complete (reads `yieldData` + `market_prices`,
writes `/inventory/{id}`, FCMs buyers with matching `cropPreferences`). The B2B
`liveInventoryProvider` streams `/inventory` in real-time, so a completed
harvest surfaces here automatically. `createB2BOrder` decrements
`quantityRemaining` inside a transaction so two buyers can't over-order a lot.

### Deferred to Cloud Functions / later (needs Blaze)
`createB2BOrder`, `confirmDelivery`, `generateInvoice`, `updateInventoryOnHarvest`
are wired as callables/triggers (implemented in `functions/`, not deployed —
project is on Spark). Razorpay pay-now and Google Maps delivery tiles are
stubbed/painted for review. The PDF invoice viewer renders an in-app GST
breakdown rather than syncfusion_pdfviewer.
