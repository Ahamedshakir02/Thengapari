import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/homeowner/screens/amc_screen.dart';
import 'features/homeowner/screens/book_harvest_screen.dart';
import 'features/homeowner/screens/homeowner_shell.dart';
import 'features/homeowner/screens/live_job_tracker_screen.dart';
import 'features/homeowner/screens/payment_screen.dart';
import 'features/homeowner/screens/profile_setup_screen.dart';
import 'features/homeowner/screens/tree_inventory_setup_screen.dart';
import 'features/homeowner/screens/yield_report_screen.dart';

/// Route paths for the Homeowner app. This app IS the homeowner role (chosen at
/// install), so there is no role-gate — login flows straight into the homeowner
/// onboarding/home.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';

  static const homeownerProfileSetup = '/homeowner/profile-setup';
  static const homeownerTreeSetup = '/homeowner/tree-setup';
  static const homeownerHome = '/homeowner/home';
  static const homeownerBook = '/homeowner/book';
  static const homeownerTracker = '/homeowner/tracker';
  static const homeownerReport = '/homeowner/report';
  static const homeownerPayment = '/homeowner/payment';
  static const homeownerAmc = '/homeowner/amc';
}

/// The Homeowner app's [GoRouter]. Redirects are driven by the shared auth +
/// onboarding providers from `core`.
final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ValueNotifier<AsyncValue<AppUser?>>(const AsyncLoading());
  ref.onDispose(authListenable.dispose);
  ref.listen<AsyncValue<AppUser?>>(
    authStateProvider,
    (_, next) => authListenable.value = next,
    fireImmediately: true,
  );

  final onboardingListenable =
      ValueNotifier<bool>(ref.read(onboardingSeenProvider));
  ref.onDispose(onboardingListenable.dispose);
  ref.listen<bool>(
    onboardingSeenProvider,
    (_, next) => onboardingListenable.value = next,
    fireImmediately: true,
  );

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: Listenable.merge([authListenable, onboardingListenable]),
    redirect: (context, state) {
      final authState = authListenable.value;
      final loc = state.matchedLocation;

      if (authState.isLoading) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final user = authState.value;
      final seenOnboarding = onboardingListenable.value;

      if (user == null) {
        if (!seenOnboarding) {
          return loc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
        }
        return loc == AppRoutes.login ? null : AppRoutes.login;
      }

      // Signed in but profile not finished -> homeowner setup flow.
      if (!user.isProfileComplete) {
        const setupRoutes = {
          AppRoutes.homeownerProfileSetup,
          AppRoutes.homeownerTreeSetup,
        };
        return setupRoutes.contains(loc)
            ? null
            : AppRoutes.homeownerProfileSetup;
      }

      const preHome = {
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
      };
      return preHome.contains(loc) ? AppRoutes.homeownerHome : null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
          path: AppRoutes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.homeownerProfileSetup,
          builder: (_, _) => const ProfileSetupScreen()),
      GoRoute(
          path: AppRoutes.homeownerTreeSetup,
          builder: (_, _) => const TreeInventorySetupScreen()),
      GoRoute(
          path: AppRoutes.homeownerHome, builder: (_, _) => const HomeownerShell()),
      GoRoute(
          path: AppRoutes.homeownerBook, builder: (_, _) => const BookHarvestScreen()),
      GoRoute(
          path: AppRoutes.homeownerTracker,
          builder: (_, _) => const LiveJobTrackerScreen()),
      GoRoute(
          path: AppRoutes.homeownerReport,
          builder: (_, _) => const YieldReportScreen()),
      GoRoute(
          path: AppRoutes.homeownerPayment,
          builder: (_, _) => const PaymentScreen()),
      GoRoute(path: AppRoutes.homeownerAmc, builder: (_, _) => const AmcScreen()),
    ],
  );
});
