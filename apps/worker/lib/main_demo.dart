import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

/// Worker app entrypoint. Boots Firebase + Hive, signs in anonymously, and
/// seeds the worker providers with demo data so the dark-teal screens render
/// without live Firestore.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(Flavor.dev);
  // Worker design default: bilingual English + Malayalam ('Both').
  gAppLang = AppLang.both;
  try {
    await Firebase.initializeApp();
  } catch (_) {/* Firebase not configured yet — demo data still renders */}
  await Hive.initFlutter();
  await Hive.openBox(OnboardingService.boxName);

  String uid = 'dev-worker-uid';
  try {
    final cred = await FirebaseAuth.instance.signInAnonymously();
    uid = cred.user?.uid ?? uid;
  } catch (_) {/* anon auth disabled — demo data renders regardless */}

  final devUser = AppUser(
    uid: uid,
    phoneNumber: '+910000000000',
    firstName: 'Ravi',
    lastName: 'Menon',
    district: 'Thrissur',
    role: UserRole.worker,
  );

  final now = DateTime.now();
  runApp(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(devUser)),
        workerServiceProvider.overrideWith((ref) => _DemoWorkerService()),
        workerProfileProvider.overrideWith((ref, _) => Stream.value(
              const WorkerProfile(
                skills: [WorkerSkill.climber, WorkerSkill.husker],
                upiVpa: 'ravi@okaxis',
                isOnline: true,
                reliabilityScore: 94,
                totalJobsCompleted: 312,
                totalEarned: 184500,
              ),
            )),
        workerDayStatsProvider.overrideWith((ref, _) => Stream.value(
              const WorkerDayStats(earningsToday: 1240, jobsCompletedToday: 4),
            )),
        workerConfirmedJobsProvider.overrideWith((ref, _) => Stream.value([
              WorkerConfirmedJob(
                id: 'j1',
                title: 'Coconut climbing · 18 trees',
                place: "Suresh's grove",
                distance: '1.2 km',
                scheduledAt: DateTime(now.year, now.month, now.day, 14, 30),
                payout: 620,
                isNext: true,
              ),
              WorkerConfirmedJob(
                id: 'j2',
                title: 'Coconut husking · 24 nuts',
                place: 'Ravi Nair',
                distance: '2.8 km',
                scheduledAt: DateTime(now.year, now.month, now.day, 16, 0),
                payout: 380,
              ),
            ])),
        workerWeeklyEarningsProvider.overrideWith((ref, _) =>
            Stream.value(const [980, 1420, 760, 1680, 1240, 0, 0])),
      ],
      child: const WorkerApp(),
    ),
  );
}

/// Demo service: setup + availability writes succeed without live Firebase.
class _DemoWorkerService extends WorkerService {
  @override
  Future<void> saveWorkerSetup({
    required String uid,
    required String name,
    required String district,
    required List<WorkerSkill> skills,
    required String upiVpa,
    String? phoneNumber,
  }) async {}

  @override
  Future<void> setOnline(String uid, bool online) async {}
}
