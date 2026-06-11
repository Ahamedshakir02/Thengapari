import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

/// B2B Portal app entrypoint. Overrides [b2bServiceProvider] with an in-memory
/// demo service seeded with 120 inventory lots (to exercise the lazy list),
/// orders, savings, and standing orders — runs without live Firestore.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(Flavor.dev);
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox(OnboardingService.boxName);

  String uid = 'dev-b2b-uid';
  try {
    final cred = await FirebaseAuth.instance.signInAnonymously();
    uid = cred.user?.uid ?? uid;
  } catch (_) {/* anon auth disabled — demo data renders regardless */}

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
      child: const B2BApp(),
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
