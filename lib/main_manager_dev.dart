import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'core/models/byproduct.dart';
import 'core/models/harvest_job.dart';
import 'core/models/job_step.dart';
import 'core/models/processor_response.dart';
import 'core/models/site_manager_profile.dart';
import 'core/models/yield_data.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/site_manager_providers.dart';
import 'core/services/site_manager_service.dart';
import 'features/site_manager/screens/broadcast_ping_screen.dart';
import 'features/site_manager/screens/byproduct_routing_screen.dart';
import 'features/site_manager/screens/college_verification_screen.dart';
import 'features/site_manager/screens/harvest_report_screen.dart';
import 'features/site_manager/screens/home_screen.dart';
import 'features/site_manager/screens/navigation_to_site_screen.dart';
import 'features/site_manager/screens/sm_profile_setup_screen.dart';
import 'features/site_manager/screens/training_screen.dart';
import 'features/site_manager/screens/yield_weigh_screen.dart';

/// Site Manager dev entrypoint:
///   flutter run --flavor dev -t lib/main_manager_dev.dart
///
/// Boots Firebase, signs in anonymously, and overrides
/// [siteManagerServiceProvider] with an in-memory demo service so the whole
/// on-site flow (checklist → weigh → broadcast → byproducts → report) is fully
/// interactive without live Firestore. Real screens use the live service
/// unchanged.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(Flavor.dev);
  await Firebase.initializeApp();

  String uid = 'dev-manager-uid';
  String? authNote;
  try {
    final cred = await FirebaseAuth.instance.signInAnonymously();
    uid = cred.user?.uid ?? uid;
  } catch (_) {
    authNote = 'Anonymous auth is disabled in this Firebase project, so live '
        'Firestore writes would be rejected. The screens below run entirely '
        'on seeded in-memory data.';
  }

  final devUser = AppUser(
    uid: uid,
    phoneNumber: '+910000000000',
    firstName: 'Arjun',
    lastName: 'Pradeep',
    district: 'Ernakulam',
    role: UserRole.siteManager,
  );

  runApp(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(devUser)),
        siteManagerServiceProvider
            .overrideWith((ref) => _DemoSiteManagerService(uid)),
      ],
      child: ManagerDevApp(uid: uid, authNote: authNote),
    ),
  );
}

// ───────────────────────────── Seed data ─────────────────────────────

final _activeLoc = const GeoPoint(10.02, 76.30);

final _jobs = <HarvestJob>[
  HarvestJob(
    id: 'KH2261',
    homeownerId: 'ho-1',
    siteManagerId: 'dev-manager-uid',
    cropTypes: const ['coconut', 'tender'],
    status: 'in_progress',
    notes: 'Ravi Nair',
    district: 'Vaduthala',
    address: '0.0 km',
    estimatedYieldKg: 52,
    actualYieldKg: 47.2,
    location: _activeLoc,
    scheduledAt: _at(9, 0),
  ),
  HarvestJob(
    id: 'KH2262',
    homeownerId: 'ho-2',
    siteManagerId: 'dev-manager-uid',
    cropTypes: const ['coconut'],
    status: 'site_manager_assigned',
    notes: 'Lakshmi Menon',
    district: 'Edappally',
    address: '3.2 km',
    estimatedYieldKg: 38,
    location: const GeoPoint(10.03, 76.31),
    scheduledAt: _at(11, 30),
  ),
  HarvestJob(
    id: 'KH2263',
    homeownerId: 'ho-3',
    siteManagerId: 'dev-manager-uid',
    cropTypes: const ['coconut', 'arecanut'],
    status: 'site_manager_assigned',
    notes: 'Suresh Pillai',
    district: 'Palarivattom',
    address: '5.8 km',
    estimatedYieldKg: 61,
    location: const GeoPoint(10.00, 76.33),
    scheduledAt: _at(14, 15),
  ),
];

DateTime _at(int h, int m) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day, h, m);
}

const _demoProfile = SiteManagerProfile(
  collegeName: 'Govt. Engineering College, Thrissur',
  rollNumber: 'TCR21CS045',
  branch: CollegeBranch.engineering,
  yearOfStudy: YearOfStudy.third,
  verified: true,
  rating: 4.8,
  jobsCompleted: 37,
  currentJobId: 'KH2261',
  trainingComplete: true,
);

/// In-memory service: drives the entire flow without Firebase.
class _DemoSiteManagerService extends SiteManagerService {
  _DemoSiteManagerService(this.uid);
  final String uid;

  final _done = <String, Map<String, DateTime?>>{
    'KH2261': {
      'arrived': _at(9, 16),
      'harvest_started': _at(9, 24),
      'harvest_complete': _at(9, 48),
    },
  };
  final _stepCtrls = <String, StreamController<List<JobStep>>>{};
  final _yields = <String, YieldData>{
    'KH2261': const YieldData(
        totalKg: 47.2, gradeA: 31, gradeB: 9, tender: 4, estimatedValue: 999),
  };
  final _yieldCtrls = <String, StreamController<YieldData?>>{};

  Map<String, DateTime?> _doneFor(String jobId) =>
      _done.putIfAbsent(jobId, () => {});

  StreamController<List<JobStep>> _stepCtrl(String jobId) =>
      _stepCtrls.putIfAbsent(
          jobId, () => StreamController<List<JobStep>>.broadcast());

  StreamController<YieldData?> _yieldCtrl(String jobId) =>
      _yieldCtrls.putIfAbsent(
          jobId, () => StreamController<YieldData?>.broadcast());

  @override
  Stream<SiteManagerProfile?> watchProfile(String _) =>
      Stream.value(_demoProfile);

  @override
  Stream<List<HarvestJob>> watchTodayJobs(String _) => Stream.value(_jobs);

  @override
  Stream<List<JobStep>> watchSteps(String jobId) async* {
    yield buildJobSteps(_doneFor(jobId));
    yield* _stepCtrl(jobId).stream;
  }

  @override
  Stream<YieldData?> watchYield(String jobId) async* {
    yield _yields[jobId];
    yield* _yieldCtrl(jobId).stream;
  }

  @override
  Future<void> completeStep({
    required String jobId,
    required String uid,
    required ManagerStepKind kind,
    String? note,
    String? photoUrl,
    GeoPoint? location,
    String? jobStatus,
    Map<String, Object?> extraJobFields = const {},
  }) async {
    _doneFor(jobId)[kind.id] = DateTime.now();
    _stepCtrl(jobId).add(buildJobSteps(_doneFor(jobId)));
  }

  @override
  Future<void> saveYield({
    required String jobId,
    required String uid,
    required double totalKg,
    required int gradeA,
    required int gradeB,
    required int tender,
    String? scalePhotoUrl,
  }) async {
    _yields[jobId] = YieldData(
      totalKg: totalKg,
      gradeA: gradeA,
      gradeB: gradeB,
      tender: tender,
      estimatedValue: YieldData.estimate(gradeA, gradeB, tender).toDouble(),
      scalePhotoUrl: scalePhotoUrl,
    );
    _yieldCtrl(jobId).add(_yields[jobId]);
  }

  @override
  Future<void> broadcastProcessorPing({
    required String jobId,
    required String cropType,
    required double yieldKg,
    required double lat,
    required double lng,
    double radiusKm = 5,
  }) async {}

  @override
  Stream<List<ProcessorResponse>> watchPingResponses(String jobId) async* {
    const all = [
      ProcessorResponse(
          id: 'w1', workerId: 'w1', name: 'Anil Kumar', rating: 4.9,
          jobsCompleted: 212, distanceKm: 0.8, etaMin: 6,
          typeLabel: 'Processor · copra'),
      ProcessorResponse(
          id: 'w2', workerId: 'w2', name: 'Faisal Rahman', rating: 4.8,
          jobsCompleted: 156, distanceKm: 1.4, etaMin: 9,
          typeLabel: 'Tender buyer'),
      ProcessorResponse(
          id: 'w3', workerId: 'w3', name: 'Deepa Thomas', rating: 4.7,
          jobsCompleted: 98, distanceKm: 2.1, etaMin: 12,
          typeLabel: 'Processor · oil mill'),
    ];
    final acc = <ProcessorResponse>[];
    yield acc.toList();
    const delays = [1400, 1800, 2200];
    for (var i = 0; i < all.length; i++) {
      await Future<void>.delayed(Duration(milliseconds: delays[i]));
      acc.add(all[i]);
      yield acc.toList();
    }
  }

  @override
  Future<void> assignProcessor({
    required String jobId,
    required String pingId,
    required String workerId,
  }) async {}

  @override
  Future<List<ByproductBuyer>> nearbyBuyers(
      ByproductType type, GeoPoint? near) async {
    final base = near ?? _activeLoc;
    final byType = <ByproductType, List<ByproductBuyer>>{
      ByproductType.coconutHusk: [
        ByproductBuyer(
            id: 'b1',
            name: 'Ravi Coir Factory',
            acceptsTypes: const [ByproductType.coconutHusk],
            location: GeoPoint(base.latitude + 0.011, base.longitude)),
        ByproductBuyer(
            id: 'b2',
            name: 'Kerala Coir Co-op',
            acceptsTypes: const [ByproductType.coconutHusk],
            location: GeoPoint(base.latitude + 0.03, base.longitude)),
      ],
      ByproductType.coconutShell: [
        ByproductBuyer(
            id: 'b3',
            name: 'Shakthi Charcoal Unit',
            acceptsTypes: const [ByproductType.coconutShell],
            location: GeoPoint(base.latitude + 0.019, base.longitude)),
        ByproductBuyer(
            id: 'b4',
            name: 'Cochin Shell Crafts',
            acceptsTypes: const [ByproductType.coconutShell],
            location: GeoPoint(base.latitude + 0.04, base.longitude)),
      ],
      ByproductType.arecaWaste: [
        ByproductBuyer(
            id: 'b5',
            name: 'Greenboard Mills',
            acceptsTypes: const [ByproductType.arecaWaste],
            location: GeoPoint(base.latitude + 0.025, base.longitude)),
      ],
      ByproductType.jackfruitRags: [
        ByproductBuyer(
            id: 'b6',
            name: 'Anand Dairy Farm',
            acceptsTypes: const [ByproductType.jackfruitRags],
            location: GeoPoint(base.latitude + 0.015, base.longitude)),
      ],
    };
    final list = byType[type] ?? const <ByproductBuyer>[];
    final sorted = [...list]
      ..sort((a, b) =>
          a.distanceKmFrom(near).compareTo(b.distanceKmFrom(near)));
    return sorted;
  }

  @override
  Future<String> generateHarvestReport(String jobId) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return 'https://thengapari.dev/reports/$jobId.pdf';
  }

  @override
  Future<void> markJobComplete({
    required String jobId,
    required String reportUrl,
  }) async {}
}

/// Standalone harness routing to the Site Manager screens.
class ManagerDevApp extends StatelessWidget {
  final String uid;
  final String? authNote;
  const ManagerDevApp({required this.uid, this.authNote, super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
            path: '/',
            builder: (_, _) => _DevMenu(uid: uid, authNote: authNote)),
        GoRoute(
            path: AppRoutes.managerProfileSetup,
            builder: (_, _) => const SiteManagerProfileSetupScreen()),
        GoRoute(
            path: AppRoutes.managerVerification,
            builder: (_, _) => const CollegeVerificationScreen()),
        GoRoute(
            path: AppRoutes.managerHome,
            builder: (_, _) => const SiteManagerHomeScreen()),
        GoRoute(
            path: AppRoutes.managerTraining,
            builder: (_, _) => const TrainingScreen()),
        GoRoute(
            path: '/manager/navigate',
            builder: (_, _) => NavigationToSiteScreen(job: _jobs[1])),
        GoRoute(
            path: AppRoutes.managerWeigh,
            builder: (_, state) => YieldWeighScreen(
                job: (state.extra as HarvestJob?) ?? _jobs.first)),
        GoRoute(
            path: AppRoutes.managerBroadcast,
            builder: (_, state) => BroadcastPingScreen(
                job: (state.extra as HarvestJob?) ?? _jobs.first)),
        GoRoute(
            path: AppRoutes.managerByproduct,
            builder: (_, state) => ByproductRoutingScreen(
                job: (state.extra as HarvestJob?) ?? _jobs.first)),
        GoRoute(
            path: AppRoutes.managerReport,
            builder: (_, state) => HarvestReportScreen(
                job: (state.extra as HarvestJob?) ?? _jobs.first)),
      ],
    );

    return MaterialApp.router(
      title: 'ThengaPari Site Manager (dev)',
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
    final job = _jobs.first;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Site Manager · Dev Harness'),
        backgroundColor: AppColors.brandInk,
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
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.amberSaffron600)),
            ),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.greenLeaf100,
                borderRadius: BorderRadius.circular(12)),
            child: Text('Signed in as dev uid:\n$uid',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.greenForest800)),
          ),
          const Text('SCREENS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.greenForest700)),
          const SizedBox(height: 8),
          _item(context, '1 · Profile setup',
              'College details + ID upload → verification', AppRoutes.managerProfileSetup),
          _item(context, '1 · Verification pending',
              'Admin-approval gate that blocks dispatch', AppRoutes.managerVerification),
          _item(context, '2 · Today · queue + shell',
              'List/map toggle, bottom nav (Today/On-site/Earnings/Profile)',
              AppRoutes.managerHome),
          _item(context, '3 · Navigate to site',
              '100 m GPS check-in gate', '/manager/navigate'),
          _item(context, '4 · On-site dashboard',
              'Checklist + live yield donut (On-site tab)', AppRoutes.managerHome),
          _itemExtra(context, '5 · Weigh & grade',
              'Keypad, grade counters, live donut', AppRoutes.managerWeigh, job),
          _itemExtra(context, '6 · Broadcast ping',
              'Nearby count → live responses → assign', AppRoutes.managerBroadcast, job),
          _itemExtra(context, '7 · Route byproducts',
              'Nearest-buyer matching by type', AppRoutes.managerByproduct, job),
          _itemExtra(context, '8 · Harvest report',
              'Preview, sign-off, generate PDF, complete', AppRoutes.managerReport, job),
          _item(context, '9 · Training',
              'Modules, badges, certificate', AppRoutes.managerTraining),
        ],
      ),
    );
  }

  Widget _item(BuildContext c, String label, String sub, String route) =>
      _MenuTile(label: label, subtitle: sub, onTap: () => c.go(route));

  Widget _itemExtra(
          BuildContext c, String label, String sub, String route, HarvestJob job) =>
      _MenuTile(label: label, subtitle: sub, onTap: () => c.go(route, extra: job));
}

class _MenuTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        title: Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
