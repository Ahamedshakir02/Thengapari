import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/flavor_config.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/models/app_user.dart';
import 'core/models/harvest_job.dart';
import 'core/models/tree_inventory.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/homeowner_providers.dart';
import 'features/homeowner/screens/home_screen.dart';
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
        // Seed homeowner data so HomeScreen renders without live Firestore.
        treeInventoryProvider.overrideWith((ref, _) => Stream.value(_sampleTrees)),
        activeJobProvider.overrideWith((ref, _) => Stream.value(_sampleJob)),
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
  estimatedYieldKg: 47,
);

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
          builder: (_, _) => const HomeownerHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.homeownerBook,
          builder: (_, _) => const _ComingSoon(title: 'Book a harvest (step 3)'),
        ),
        GoRoute(
          path: AppRoutes.homeownerTracker,
          builder: (_, _) => const _ComingSoon(title: 'Live job tracker (step 4)'),
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

/// Placeholder for screens not yet built.
class _ComingSoon extends StatelessWidget {
  final String title;
  const _ComingSoon({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_outlined,
                color: AgriColors.amber600, size: 48),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 15, color: Color(0xFF4A4840))),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go(AppRoutes.homeownerHome),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
