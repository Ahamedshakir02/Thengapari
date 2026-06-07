import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/flavor_config.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/models/app_user.dart';
import 'core/models/worker_profile.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/worker_providers.dart';
import 'core/services/worker_service.dart';
import 'features/worker/screens/home_screen.dart';
import 'features/worker/screens/worker_setup_screen.dart';

/// Worker dev entrypoint:
///   flutter run --flavor dev -t lib/main_worker_dev.dart
///
/// Mirrors the homeowner harness in [main_dev.dart] but for the Worker role:
/// boots Firebase, signs in anonymously, overrides [authStateProvider] with a
/// worker user, and seeds the worker data providers with sample data so the
/// dark-teal screens render fully without live Firestore. A demo
/// [WorkerService] makes the availability toggle + setup writes no-op.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(Flavor.dev);
  await Firebase.initializeApp();

  String uid = 'dev-worker-uid';
  String? authNote;
  try {
    final cred = await FirebaseAuth.instance.signInAnonymously();
    uid = cred.user?.uid ?? uid;
  } catch (e) {
    authNote = 'Anonymous auth is disabled in this Firebase project, so '
        'Firestore writes will be rejected. Screens below use sample data '
        'regardless.';
  }

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
      child: WorkerDevApp(uid: uid, authNote: authNote),
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

/// Standalone harness routing to the worker screens built so far.
class WorkerDevApp extends StatelessWidget {
  final String uid;
  final String? authNote;
  const WorkerDevApp({required this.uid, this.authNote, super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => _DevMenu(uid: uid, authNote: authNote)),
        GoRoute(
          path: AppRoutes.workerSetup,
          builder: (_, _) => const WorkerSetupScreen(),
        ),
        GoRoute(
          path: AppRoutes.workerHome,
          builder: (_, _) => const WorkerHomeScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'ThengaPari Worker (dev)',
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
      backgroundColor: const Color(0xFF08332F),
      appBar: AppBar(
        title: const Text('Worker · Dev Harness'),
        backgroundColor: const Color(0xFF0E5249),
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
                color: const Color(0x33F4A52A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('⚠️  $authNote',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFFBDFA6))),
            ),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0E5249),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Signed in as dev uid:\n$uid',
                style: const TextStyle(fontSize: 12, color: Color(0xFFD6ECE7))),
          ),
          const Text('SCREENS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Color(0xFF6FB6AB))),
          const SizedBox(height: 8),
          _MenuItem(
            label: '1 · Worker setup',
            subtitle: 'Skills, district, UPI · writes /workers/{uid}',
            onTap: () => context.go(AppRoutes.workerSetup),
          ),
          _MenuItem(
            label: '2 · Home dashboard',
            subtitle: 'Online toggle, stats, reliability, jobs, weekly chart',
            onTap: () => context.go(AppRoutes.workerHome),
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
      color: const Color(0xFF0E5249),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0x22D6ECE7), width: 0.5),
      ),
      child: ListTile(
        title: Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFFBDDDD5))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF6FB6AB)),
        onTap: onTap,
      ),
    );
  }
}
