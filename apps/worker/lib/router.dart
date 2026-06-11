import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/worker/screens/home_screen.dart';
import 'features/worker/screens/job_complete_screen.dart';
import 'features/worker/screens/job_ping_screen.dart';
import 'features/worker/screens/navigate_screen.dart';
import 'features/worker/screens/worker_setup_screen.dart';

/// Route paths for the Worker app (single-role — no role gate).
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';

  static const workerSetup = '/worker/setup';
  static const workerHome = '/worker/home';
  static const workerPing = '/worker/ping';
  static const workerNavigate = '/worker/navigate';
  static const workerComplete = '/worker/complete';
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
        return loc == AppRoutes.workerSetup ? null : AppRoutes.workerSetup;
      }
      const preHome = {AppRoutes.splash, AppRoutes.onboarding, AppRoutes.login};
      return preHome.contains(loc) ? AppRoutes.workerHome : null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
          path: AppRoutes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.workerSetup, builder: (_, _) => const WorkerSetupScreen()),
      GoRoute(
          path: AppRoutes.workerHome, builder: (_, _) => const WorkerHomeScreen()),
      GoRoute(path: AppRoutes.workerPing, builder: (_, _) => const JobPingScreen()),
      GoRoute(
          path: AppRoutes.workerNavigate, builder: (_, _) => const NavigateScreen()),
      GoRoute(
          path: AppRoutes.workerComplete,
          builder: (_, _) => const JobCompleteScreen()),
    ],
  );
});
