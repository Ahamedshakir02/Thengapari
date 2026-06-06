import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/flavor_config.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/models/amc_contract.dart';
import 'core/models/app_user.dart';
import 'core/models/harvest_job.dart';
import 'core/models/tree_inventory.dart';
import 'core/models/yield_estimate.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/homeowner_providers.dart';
import 'core/services/homeowner_service.dart';
import 'features/homeowner/screens/amc_screen.dart';
import 'features/homeowner/screens/book_harvest_screen.dart';
import 'features/homeowner/screens/homeowner_shell.dart';
import 'features/homeowner/screens/live_job_tracker_screen.dart';
import 'features/homeowner/screens/payment_screen.dart';
import 'features/homeowner/screens/yield_report_screen.dart';
import 'features/homeowner/screens/profile_setup_screen.dart';
import 'features/homeowner/screens/tree_inventory_setup_screen.dart';

/// Dev entrypoint:  flutter run --flavor dev -t lib/main_dev.dart
///
/// While the Homeowner app is being built screen-by-screen, this runs a
/// **dev harness**: it boots Firebase, signs in anonymously (so Firestore
/// writes are authenticated and pass the security rules), overrides
/// [authStateProvider] with that uid, and shows a menu to jump to each screen
/// — no phone-OTP flow needed.
///
/// Because Firestore *reads* are also blocked without real auth, the harness
/// also seeds the homeowner data providers with sample data so HomeScreen
/// renders fully. The real app uses the live Firestore providers unchanged.
///
/// To run the real app shell instead, use `bootstrap(Flavor.dev)`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(Flavor.dev);
  await Firebase.initializeApp();

  String uid = 'dev-homeowner-uid';
  String? authNote;
  try {
    final cred = await FirebaseAuth.instance.signInAnonymously();
    uid = cred.user?.uid ?? uid;
  } catch (e) {
    authNote = 'Anonymous auth is disabled in this Firebase project, so '
        'Firestore writes will be rejected by security rules. Enable '
        'Authentication → Anonymous (dev only) to test real writes. '
        '(HomeScreen below uses sample data regardless.)';
  }

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
        // Demo service so write-buttons (book, save profile/trees, subscribe,
        // pay) succeed without live Firebase in the harness.
        homeownerServiceProvider.overrideWith((ref) => _DemoHomeownerService()),
        // Seed homeowner data so HomeScreen renders without live Firestore.
        treeInventoryProvider.overrideWith((ref, _) => Stream.value(_sampleTrees)),
        activeJobProvider.overrideWith((ref, _) => Stream.value(_sampleJob)),
        latestCompletedJobProvider
            .overrideWith((ref, _) => Stream.value(_sampleCompletedJob)),
        monthlyEarningsProvider.overrideWith((ref, _) async => 4280),
        weeklyEarningsProvider
            .overrideWith((ref, _) async => const [2100, 2800, 1900, 3200, 4100, 4280]),
      ],
      child: HomeownerDevApp(uid: uid, authNote: authNote),
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

/// Demo service for the dev harness: all writes succeed without touching live
/// Firebase, and Razorpay returns a `demo` order so the Payment flow can be
/// reviewed. The real app uses the unmodified [HomeownerService].
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

/// Standalone harness app routing to the homeowner screens built so far.
class HomeownerDevApp extends StatelessWidget {
  final String uid;
  final String? authNote;

  const HomeownerDevApp({required this.uid, this.authNote, super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => _DevMenu(uid: uid, authNote: authNote),
        ),
        GoRoute(
          path: AppRoutes.homeownerProfileSetup,
          builder: (_, _) => const ProfileSetupScreen(),
        ),
        GoRoute(
          path: AppRoutes.homeownerTreeSetup,
          builder: (_, _) => const TreeInventorySetupScreen(),
        ),
        GoRoute(
          path: AppRoutes.homeownerHome,
          builder: (_, _) => const HomeownerShell(),
        ),
        GoRoute(
          path: AppRoutes.homeownerBook,
          builder: (_, _) => const BookHarvestScreen(),
        ),
        GoRoute(
          path: AppRoutes.homeownerTracker,
          builder: (_, _) => const LiveJobTrackerScreen(),
        ),
        GoRoute(
          path: AppRoutes.homeownerReport,
          builder: (_, _) => const YieldReportScreen(),
        ),
        GoRoute(
          path: AppRoutes.homeownerPayment,
          builder: (_, _) => const PaymentScreen(),
        ),
        GoRoute(
          path: AppRoutes.homeownerAmc,
          builder: (_, _) => const AmcScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'ThengaPari (dev)',
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
      backgroundColor: AgriColors.surface,
      appBar: AppBar(
        title: const Text('Homeowner · Dev Harness'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (authNote != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEBCB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('⚠️  $authNote',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF633806))),
            ),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AgriColors.green50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Signed in as dev uid:\n$uid',
                style: const TextStyle(fontSize: 12, color: Color(0xFF27500A))),
          ),
          const Text('SCREENS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AgriColors.green800)),
          const SizedBox(height: 8),
          _MenuItem(
            label: '2 · Home dashboard',
            subtitle: 'Hero, crops, stats, chart, active job',
            onTap: () => context.go(AppRoutes.homeownerHome),
          ),
          _MenuItem(
            label: '3 · Book a harvest',
            subtitle: 'Crop grid, date, estimate, creates /jobs',
            onTap: () => context.go(AppRoutes.homeownerBook),
          ),
          _MenuItem(
            label: '4 · Live job tracker',
            subtitle: 'Stepper, grove map, live weight, photos',
            onTap: () => context.go(AppRoutes.homeownerTracker),
          ),
          _MenuItem(
            label: '5 · Yield report',
            subtitle: 'Grade donut, byproduct, earnings, share',
            onTap: () => context.go(AppRoutes.homeownerReport),
          ),
          _MenuItem(
            label: '6 · Payment',
            subtitle: 'Invoice, UPI options, Razorpay checkout',
            onTap: () => context.go(AppRoutes.homeownerPayment),
          ),
          _MenuItem(
            label: '7 · AMC subscription',
            subtitle: 'Plans, seasonal calendar, subscribe',
            onTap: () => context.go(AppRoutes.homeownerAmc),
          ),
          _MenuItem(
            label: '1 · Profile setup',
            subtitle: 'Writes /users/{uid} + /homeowners/{uid}',
            onTap: () => context.go(AppRoutes.homeownerProfileSetup),
          ),
          _MenuItem(
            label: '1 · Tree inventory setup',
            subtitle: 'Writes /homeowners/{uid}/trees',
            onTap: () => context.go(AppRoutes.homeownerTreeSetup),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AgriColors.border, width: 0.5),
      ),
      child: ListTile(
        title: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
