import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/design_tokens.dart';
import 'app/flavor_config.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/models/app_user.dart';
import 'core/models/b2b_buyer_profile.dart';
import 'core/models/b2b_order.dart';
import 'core/models/b2b_savings.dart';
import 'core/models/inventory_listing.dart';
import 'core/models/standing_order.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/b2b_providers.dart';
import 'core/services/b2b_service.dart';
import 'features/b2b/screens/business_profile_setup_screen.dart';
import 'features/b2b/screens/gst_verification_screen.dart';
import 'features/b2b/screens/home_screen.dart';
import 'features/b2b/screens/invoice_view_screen.dart';
import 'features/b2b/screens/listing_detail_screen.dart';
import 'features/b2b/screens/order_tracking_screen.dart';
import 'features/b2b/screens/prebook_screen.dart';
import 'features/b2b/screens/standing_order_screen.dart';

/// B2B Portal dev entrypoint:
///   flutter run --flavor dev -t lib/main_b2b_dev.dart
///
/// Overrides [b2bServiceProvider] with an in-memory demo service seeded with
/// 120 inventory lots (to exercise the lazy list), orders, savings, and
/// standing orders — so the whole flow runs without live Firestore.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(Flavor.dev);
  await Firebase.initializeApp();

  String uid = 'dev-b2b-uid';
  String? authNote;
  try {
    final cred = await FirebaseAuth.instance.signInAnonymously();
    uid = cred.user?.uid ?? uid;
  } catch (_) {
    authNote = 'Anonymous auth is disabled in this Firebase project. The '
        'screens below run on seeded in-memory data.';
  }

  final devUser = AppUser(
    uid: uid,
    phoneNumber: '+910000000000',
    firstName: 'Saravanan',
    lastName: 'R',
    district: 'Ernakulam',
    role: UserRole.b2b,
  );

  runApp(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(devUser)),
        b2bServiceProvider.overrideWith((ref) => _DemoB2BService()),
      ],
      child: B2BDevApp(uid: uid, authNote: authNote),
    ),
  );
}

// ───────────────────────────── Seed data ─────────────────────────────

const _profile = B2BBuyerProfile(
  businessName: 'Saravana Juice Stall',
  businessType: BusinessType.juiceStall,
  gstNumber: '32AABCR1234F1Z5',
  district: 'Ernakulam',
  verified: true,
  totalOrdersPlaced: 18,
  totalSpent: 26400,
  totalSaved: 2140,
);

const _wards = ['Manjaly ward', 'Kuruppam ward', 'Edappally', 'Palarivattom', 'Idukki line', 'Wayanad line'];
const _farms = ['Anil Varghese', 'Leela Menon', 'Suresh Pillai', 'Thomas Kurian', 'Rema Suresh'];

/// 120 listings across crops/grades/wards for the performance test.
final List<InventoryListing> _listings = _buildListings();

List<InventoryListing> _buildListings() {
  final rnd = math.Random(7);
  const seeds = {
    B2BCrop.coconut: (18.0, 20.5),
    B2BCrop.jackfruit: (40.0, 50.0),
    B2BCrop.mango: (95.0, 105.5),
    B2BCrop.pepper: (480.0, 522.0),
    B2BCrop.banana: (55.0, 60.5),
    B2BCrop.ginger: (70.0, 75.5),
  };
  final crops = seeds.keys.toList();
  final out = <InventoryListing>[];
  for (var i = 0; i < 120; i++) {
    final crop = crops[i % crops.length];
    final (price, market) = seeds[crop]!;
    final jitter = 1 + (rnd.nextDouble() - 0.5) * 0.12;
    final unitPrice = (price * jitter);
    out.add(InventoryListing(
      id: '${crop.name}-$i',
      cropType: crop,
      grade: i % 3 == 0 ? 'Grade B' : 'Grade A',
      quantity: 50 + rnd.nextInt(250),
      quantityRemaining: 20 + rnd.nextInt(220),
      unitPrice: double.parse(unitPrice.toStringAsFixed(crop.unit == 'pc' ? 0 : 1)),
      wholesaleMarketPrice: market,
      harvestedAt: DateTime.now().subtract(Duration(hours: rnd.nextInt(40))),
      ward: _wards[i % _wards.length],
      distanceKm: double.parse((1 + rnd.nextDouble() * 18).toStringAsFixed(1)),
      condition: crop == B2BCrop.coconut ? 'Husked · sun-dried' : 'Fresh · graded',
      variety: switch (crop) {
        B2BCrop.coconut => 'West Coast Tall',
        B2BCrop.mango => 'Alphonso',
        B2BCrop.jackfruit => 'Koozha (firm)',
        B2BCrop.pepper => 'Karimunda',
        B2BCrop.banana => 'Nendran',
        _ => 'Local',
      },
      farmName: _farms[i % _farms.length],
      farmPlot: 'Plot ${1 + i % 30} · ${_wards[i % _wards.length]}',
      farmSince: '${2016 + i % 7}',
      farmRating: 4.5 + (i % 5) * 0.1,
      farmHarvests: 60 + rnd.nextInt(280),
    ));
  }
  return out;
}

final List<B2BOrder> _orders = [
  B2BOrder(
    id: 'KB1042',
    cropType: B2BCrop.coconut,
    grade: 'Grade A',
    quantity: 150,
    unitPrice: 18,
    totalAmount: 2700,
    savingsAmount: 375,
    deliveryDate: DateTime.now().add(const Duration(days: 1)),
    deliveryAddress: 'Saravana Juice Stall, MG Road',
    status: B2BOrderStatus.dispatched,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  B2BOrder(
    id: 'KB1041',
    cropType: B2BCrop.mango,
    grade: 'Grade A',
    quantity: 40,
    unitPrice: 95,
    totalAmount: 3800,
    savingsAmount: 420,
    deliveryDate: DateTime.now().add(const Duration(days: 2)),
    status: B2BOrderStatus.confirmed,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  B2BOrder(
    id: 'KB1038',
    cropType: B2BCrop.jackfruit,
    grade: 'Grade A',
    quantity: 30,
    unitPrice: 40,
    totalAmount: 1200,
    savingsAmount: 300,
    deliveryDate: DateTime.now().subtract(const Duration(days: 3)),
    status: B2BOrderStatus.delivered,
    invoiceUrl: 'https://thengapari.dev/invoices/KB1038.pdf',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
];

final List<StandingOrder> _standing = [
  StandingOrder(
    id: 's1',
    cropType: B2BCrop.coconut,
    grade: 'Grade A',
    quantityPerOrder: 150,
    frequency: StandingFrequency.weekly,
    nextDue: DateTime.now().add(const Duration(days: 3)),
  ),
  StandingOrder(
    id: 's2',
    cropType: B2BCrop.banana,
    grade: 'Grade A',
    quantityPerOrder: 60,
    frequency: StandingFrequency.weekly,
    nextDue: DateTime.now().add(const Duration(days: 2)),
  ),
  StandingOrder(
    id: 's3',
    cropType: B2BCrop.mango,
    grade: 'Grade A + B',
    quantityPerOrder: 40,
    frequency: StandingFrequency.biweekly,
    nextDue: DateTime.now().add(const Duration(days: 10)),
  ),
];

const _savings = SavingsSummary(
  totalSaved: 2140,
  totalSpent: 26400,
  orderCount: 18,
  avgPercent: 13,
  perCrop: {
    B2BCrop.coconut: 720,
    B2BCrop.mango: 560,
    B2BCrop.jackfruit: 480,
    B2BCrop.banana: 240,
    B2BCrop.pepper: 140,
  },
);

class _DemoB2BService extends B2BService {
  @override
  Stream<B2BBuyerProfile?> watchProfile(String uid) => Stream.value(_profile);

  @override
  Stream<List<InventoryListing>> watchInventory() => Stream.value(_listings);

  @override
  Stream<InventoryListing?> watchListing(String id) =>
      Stream.value(_listings.firstWhere((l) => l.id == id,
          orElse: () => _listings.first));

  @override
  Future<Map<String, double>> marketPrices() async => const {};

  @override
  Future<Map<String, dynamic>> createB2BOrder({
    required String listingId,
    required int quantity,
    required DateTime deliveryDate,
    required String paymentMethod,
    required String buyerId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return {'orderId': 'demo', 'keyId': 'demo', 'amountPaise': quantity * 1800};
  }

  @override
  Stream<List<B2BOrder>> watchActiveOrders(String uid) =>
      Stream.value(_orders.where((o) => o.status.isActive).toList());

  @override
  Future<List<B2BOrder>> fetchOrderHistory(String uid) async =>
      _orders.where((o) => !o.status.isActive).toList();

  @override
  Stream<List<TrackingEvent>> watchOrderTracking(String orderId) {
    final now = DateTime.now();
    return Stream.value([
      TrackingEvent(
          type: B2BOrderStatus.confirmed,
          timestamp: now.subtract(const Duration(hours: 5)),
          note: 'Order confirmed'),
      TrackingEvent(
          type: B2BOrderStatus.dispatched,
          timestamp: now.subtract(const Duration(hours: 1)),
          note: 'Picked up from farm'),
    ]);
  }

  @override
  Future<void> confirmDelivery(String orderId) async {}

  @override
  Future<String> generateInvoice(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return 'https://thengapari.dev/invoices/$orderId.pdf';
  }

  @override
  Future<SavingsSummary> monthlySavings(String uid) async => _savings;

  @override
  Future<List<double>> weeklySpend(String uid) async =>
      const [4200, 3600, 5100, 4400, 3900, 5300];

  @override
  Stream<List<StandingOrder>> watchStandingOrders(String uid) =>
      Stream.value(_standing);

  @override
  Future<void> createStandingOrder({
    required String uid,
    required B2BCrop cropType,
    required String grade,
    required int quantityPerOrder,
    required StandingFrequency frequency,
    double? maxPricePer,
    required DateTime startDate,
  }) async {}
}

class B2BDevApp extends StatelessWidget {
  final String uid;
  final String? authNote;
  const B2BDevApp({required this.uid, this.authNote, super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => _DevMenu(uid: uid, authNote: authNote)),
        GoRoute(
            path: AppRoutes.b2bProfileSetup,
            builder: (_, _) => const BusinessProfileSetupScreen()),
        GoRoute(
            path: AppRoutes.b2bVerification,
            builder: (_, _) => const GSTVerificationScreen()),
        GoRoute(path: AppRoutes.b2bHome, builder: (_, _) => const B2BHomeScreen()),
        GoRoute(
            path: AppRoutes.b2bListing,
            builder: (_, state) => ListingDetailScreen(
                listing: state.extra as InventoryListing? ?? _listings.first)),
        GoRoute(
            path: AppRoutes.b2bPrebook,
            builder: (_, state) => PreBookScreen(
                args: state.extra as PreBookArgs? ??
                    (listing: _listings.first, qty: 150))),
        GoRoute(
            path: AppRoutes.b2bTracking,
            builder: (_, state) =>
                OrderTrackingScreen(order: state.extra as B2BOrder? ?? _orders.first)),
        GoRoute(
            path: AppRoutes.b2bStanding,
            builder: (_, _) => const StandingOrderSetupScreen()),
        GoRoute(
            path: AppRoutes.b2bInvoice,
            builder: (_, state) =>
                InvoiceViewScreen(order: state.extra as B2BOrder? ?? _orders.last)),
      ],
    );
    return MaterialApp.router(
      title: 'ThengaPari B2B (dev)',
      debugShowCheckedModeBanner: false,
      theme: buildAgriTheme(),
      routerConfig: router,
    );
  }
}

class _DevMenu extends StatelessWidget {
  final String uid;
  final String? authNote;
  const _DevMenu({required this.uid, this.authNote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('B2B Portal · Dev Harness'),
        backgroundColor: AppColors.blue900,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (authNote != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.amber100,
                  borderRadius: BorderRadius.circular(12)),
              child: Text('⚠️  $authNote',
                  style: const TextStyle(fontSize: 12, color: AppColors.amberSaffron600)),
            ),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.blue100, borderRadius: BorderRadius.circular(12)),
            child: Text('Signed in as dev uid:\n$uid · 120 seeded lots',
                style: const TextStyle(fontSize: 12, color: AppColors.blue900)),
          ),
          const Text('SCREENS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.blue700)),
          const SizedBox(height: 8),
          _tile(context, '1 · Business profile + GST', 'Setup, 15-char GST regex',
              AppRoutes.b2bProfileSetup),
          _tile(context, '1 · GST verification', 'Pending gate · read-only browse',
              AppRoutes.b2bVerification),
          _tile(context, '2 · Market (inventory)', 'Live stream · 120 lots · filters',
              AppRoutes.b2bHome),
          _tile(context, '3 · Listing detail', 'Freshness, price bars, farm',
              AppRoutes.b2bListing),
          _tile(context, '4 · Pre-book', 'Summary, date, payment, success',
              AppRoutes.b2bPrebook),
          _tile(context, '5 · Order tracking', 'Map, timeline, confirm delivery',
              AppRoutes.b2bTracking),
          _tile(context, '6 · Savings dashboard', 'Hero, charts, standing orders',
              AppRoutes.b2bHome),
          _tile(context, '7 · Standing order setup', 'Crop, frequency, estimate',
              AppRoutes.b2bStanding),
          _tile(context, '8 · Invoice', 'GST breakdown · share',
              AppRoutes.b2bInvoice),
        ],
      ),
    );
  }

  Widget _tile(BuildContext c, String label, String sub, String route) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        title: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => c.go(route),
      ),
    );
  }
}
