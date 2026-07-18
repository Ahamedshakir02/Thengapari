import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

/// Homeowner app entrypoint.
///
/// Boots Firebase + Hive, signs in anonymously, and (for review) overrides the
/// homeowner data providers + service with seeded demo data so the app runs
/// without live Firestore. Swap the demo overrides for the real providers to
/// run against the live backend.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(Flavor.dev);
  try {
    await Firebase.initializeApp();
  } catch (_) {/* Firebase not configured yet — demo data still renders */}
  await Hive.initFlutter();
  await Hive.openBox(OnboardingService.boxName);

  String uid = 'dev-homeowner-uid';
  try {
    final cred = await FirebaseAuth.instance.signInAnonymously();
    uid = cred.user?.uid ?? uid;
  } catch (_) {/* anon auth disabled — demo data renders regardless */}

  final devUser = AppUser(
    uid: uid,
    phoneNumber: '+910000000000',
    firstName: 'Meera',
    lastName: 'Nair',
    district: 'Thrissur',
    role: UserRole.homeowner,
  );

  runApp(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(devUser)),
        homeownerServiceProvider.overrideWith((ref) => _DemoHomeownerService()),
        treeInventoryProvider.overrideWith((ref, _) => Stream.value(_sampleTrees)),
        activeJobProvider.overrideWith((ref, _) => Stream.value(_sampleJob)),
        latestCompletedJobProvider
            .overrideWith((ref, _) => Stream.value(_sampleCompletedJob)),
        monthlyEarningsProvider.overrideWith((ref, _) async => 4280),
        weeklyEarningsProvider.overrideWith(
            (ref, _) async => const [2100, 2800, 1900, 3200, 4100, 4280]),
      ],
      child: const HomeownerApp(),
    ),
  );
}

final _sampleTrees = <TreeInventory>[
  const TreeInventory(id: '1', type: CropType.coconut, count: 24, avgAgeYears: 12),
  const TreeInventory(id: '2', type: CropType.mango, count: 8, avgAgeYears: 10),
  const TreeInventory(id: '3', type: CropType.pepper, count: 2, avgAgeYears: 4),
  const TreeInventory(id: '4', type: CropType.jackfruit, count: 3, avgAgeYears: 15),
];

const _sampleJob = HarvestJob(
  id: 'demo-job',
  homeownerId: 'dev-homeowner-uid',
  siteManagerId: 'sm-1',
  cropTypes: ['coconut', 'mango'],
  status: 'in_progress',
  district: '2.1 km away',
  estimatedYieldKg: 23,
  actualYieldKg: 14.2,
);

final _sampleCompletedJob = HarvestJob(
  id: 'demo-done',
  homeownerId: 'dev-homeowner-uid',
  siteManagerId: 'sm-1',
  cropTypes: const ['coconut'],
  status: 'complete',
  completedAt: DateTime(2026, 6, 4),
  gradeA: 14,
  gradeB: 7,
  tender: 3,
  earningsAmount: 4180,
  feeAmount: 340,
  byproductCredit: 440,
);

/// Demo service: all writes succeed without touching live Firebase.
class _DemoHomeownerService extends HomeownerService {
  @override
  Future<void> saveProfile({
    required String uid,
    required String name,
    required String district,
    required String address,
    String? phoneNumber,
  }) async {}

  @override
  Future<void> saveTrees({
    required String uid,
    required List<TreeDraft> trees,
  }) async {}

  @override
  Future<String> createJob({
    required String uid,
    required List<CropType> crops,
    required DateTime scheduledAt,
    required double estimatedYieldKg,
    required String district,
    String notes = '',
    GeoPoint? location,
  }) async =>
      'demo-job';

  @override
  Future<void> subscribeAmc({
    required String uid,
    required AmcPlan plan,
    DateTime? nextDispatch,
  }) async {}

  @override
  Future<YieldEstimate> calculateYieldEstimate({
    required Map<CropType, int> treeCounts,
    required String district,
    required bool ripeOnly,
  }) async {
    final factor = ripeOnly ? 0.6 : 1.0;
    double kg = 0, earning = 0;
    for (final e in treeCounts.entries) {
      final cropKg = e.value * e.key.kgPerTree * factor;
      kg += cropKg;
      earning += cropKg * e.key.ratePerKg;
    }
    return YieldEstimate(
        estimatedKg: kg,
        estimatedEarning: earning,
        marketRate: kg == 0 ? 0 : earning / kg);
  }

  @override
  Future<RazorpayOrder> createRazorpayOrder({
    required String jobId,
    required double amount,
  }) async =>
      RazorpayOrder(
          keyId: 'demo',
          orderId: 'demo_order',
          amountPaise: (amount * 100).round());
}
