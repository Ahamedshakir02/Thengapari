import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/models/app_user.dart';
import '../core/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_verify_screen.dart';
import '../features/auth/screens/role_gate_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/b2b/screens/home_screen.dart';
import '../features/homeowner/screens/book_harvest_screen.dart';
import '../features/homeowner/screens/home_screen.dart';
import '../features/homeowner/screens/profile_setup_screen.dart';
import '../features/homeowner/screens/tree_inventory_setup_screen.dart';
import '../features/site_manager/screens/home_screen.dart';
import '../features/worker/screens/home_screen.dart';

/// Route paths, centralised so screens can navigate without magic strings.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const otp = '/otp';
  static const selectRole = '/select-role';

  static const homeownerProfileSetup = '/homeowner/profile-setup';
  static const homeownerTreeSetup = '/homeowner/tree-setup';
  static const homeownerHome = '/homeowner/home';
  static const homeownerBook = '/homeowner/book';
  static const homeownerTracker = '/homeowner/tracker';
  static const workerHome = '/worker/home';
  static const managerHome = '/manager/home';
  static const b2bHome = '/b2b/home';

  /// Home route for a given role.
  static String homeForRole(UserRole role) => switch (role) {
        UserRole.homeowner => homeownerHome,
        UserRole.worker => workerHome,
        UserRole.siteManager => managerHome,
        UserRole.b2b => b2bHome,
      };
}

/// The app's [GoRouter], rebuilt once and refreshed via [authStateProvider].
///
/// The router instance is stable; a [ValueNotifier] bridges the Riverpod auth
/// stream into GoRouter's [GoRouter.refreshListenable] so redirects re-run on
/// every sign-in / sign-out / role change without recreating the router.
final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ValueNotifier<AsyncValue<AppUser?>>(const AsyncLoading());
  ref.onDispose(authListenable.dispose);
  ref.listen<AsyncValue<AppUser?>>(
    authStateProvider,
    (_, next) => authListenable.value = next,
    fireImmediately: true,
  );

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = authListenable.value;
      final loc = state.matchedLocation;

      // 1. Auth still resolving -> hold on splash.
      if (authState.isLoading) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final user = authState.value;
      final atAuthScreen = loc == AppRoutes.login || loc == AppRoutes.otp;

      // 2. Signed out -> only login/otp are reachable.
      if (user == null) {
        return atAuthScreen ? null : AppRoutes.login;
      }

      // 3. Signed in but no role yet (first login) -> role gate.
      if (user.role == null) {
        return loc == AppRoutes.selectRole ? null : AppRoutes.selectRole;
      }

      // 3b. Homeowner who hasn't finished profile setup -> onboarding.
      //     Setup routes are freely reachable; everything else funnels back
      //     to profile setup until name + district are saved.
      if (user.role == UserRole.homeowner && !user.isProfileComplete) {
        const setupRoutes = {
          AppRoutes.homeownerProfileSetup,
          AppRoutes.homeownerTreeSetup,
        };
        return setupRoutes.contains(loc)
            ? null
            : AppRoutes.homeownerProfileSetup;
      }

      // 4. Signed in with a role -> push out of any pre-home screen.
      final home = AppRoutes.homeForRole(user.role!);
      const preHome = {
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.otp,
        AppRoutes.selectRole,
      };
      return preHome.contains(loc) ? home : null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (_, state) {
          final args = state.extra as OtpArgs;
          return OtpVerifyScreen(
            verificationId: args.verificationId,
            phoneNumber: args.phoneNumber,
            resendToken: args.resendToken,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.selectRole,
        builder: (_, _) => const RoleGateScreen(),
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
        builder: (_, _) => const BookHarvestScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerHome,
        builder: (_, _) => const WorkerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerHome,
        builder: (_, _) => const SiteManagerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.b2bHome,
        builder: (_, _) => const B2BHomeScreen(),
      ),
    ],
  );
});
