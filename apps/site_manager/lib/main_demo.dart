import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

/// Site Manager app entrypoint. Overrides [siteManagerServiceProvider] with an
/// in-memory demo service so the whole on-site flow (checklist → weigh →
/// broadcast → byproducts → report) is interactive without live Firestore.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(Flavor.dev);
  try {
    await Firebase.initializeApp();
  } catch (_) {/* Firebase not configured yet — demo data still renders */}
  await Hive.initFlutter();
  await Hive.openBox(OnboardingService.boxName);

  String uid = 'dev-manager-uid';
  try {
    final cred = await FirebaseAuth.instance.signInAnonymously();
    uid = cred.user?.uid ?? uid;
  } catch (_) {/* anon auth disabled — demo data renders regardless */}

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
      child: const SiteManagerApp(),
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
