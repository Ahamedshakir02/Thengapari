import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/site_manager/screens/broadcast_ping_screen.dart';
import 'features/site_manager/screens/byproduct_routing_screen.dart';
import 'features/site_manager/screens/college_verification_screen.dart';
import 'features/site_manager/screens/harvest_report_screen.dart';
import 'features/site_manager/screens/home_screen.dart';
import 'features/site_manager/screens/sm_profile_setup_screen.dart';
import 'features/site_manager/screens/training_screen.dart';
import 'features/site_manager/screens/yield_weigh_screen.dart';

/// Route paths for the Site Manager app (single-role — no role gate).
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';

  static const managerProfileSetup = '/manager/profile-setup';
  static const managerVerification = '/manager/verification';
  static const managerHome = '/manager/home';
  static const managerTraining = '/manager/training';
  static const managerWeigh = '/manager/weigh';
  static const managerBroadcast = '/manager/broadcast';
  static const managerByproduct = '/manager/byproduct';
  static const managerReport = '/manager/report';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ValueNotifier<AsyncValue<AppUser?>>(const AsyncLoading());
  ref.onDispose(authListenable.dispose);
  ref.listen<AsyncValue<AppUser?>>(authStateProvider,
      (_, next) => authListenable.value = next, fireImmediately: true);

  final onboardingListenable =
      ValueNotifier<bool>(ref.read(onboardingSeenProvider));
  ref.onDispose(onboardingListenable.dispose);
  ref.listen<bool>(onboardingSeenProvider,
      (_, next) => onboardingListenable.value = next, fireImmediately: true);

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
      if (user == null) {
        if (!onboardingListenable.value) {
          return loc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
        }
        return loc == AppRoutes.login ? null : AppRoutes.login;
      }
      if (!user.isProfileComplete) {
        const setupRoutes = {
          AppRoutes.managerProfileSetup,
          AppRoutes.managerVerification,
        };
        return setupRoutes.contains(loc) ? null : AppRoutes.managerProfileSetup;
      }
      const preHome = {AppRoutes.splash, AppRoutes.onboarding, AppRoutes.login};
      return preHome.contains(loc) ? AppRoutes.managerHome : null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
          path: AppRoutes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
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
          path: AppRoutes.managerWeigh,
          builder: (_, state) => YieldWeighScreen(job: state.extra as HarvestJob)),
      GoRoute(
          path: AppRoutes.managerBroadcast,
          builder: (_, state) =>
              BroadcastPingScreen(job: state.extra as HarvestJob)),
      GoRoute(
          path: AppRoutes.managerByproduct,
          builder: (_, state) =>
              ByproductRoutingScreen(job: state.extra as HarvestJob)),
      GoRoute(
          path: AppRoutes.managerReport,
          builder: (_, state) =>
              HarvestReportScreen(job: state.extra as HarvestJob)),
    ],
  );
});
