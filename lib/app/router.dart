import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/models/app_user.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/onboarding_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/otp_verify_screen.dart';
import '../features/auth/screens/role_gate_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/b2b/screens/home_screen.dart';
import '../features/homeowner/screens/amc_screen.dart';
import '../features/homeowner/screens/book_harvest_screen.dart';
import '../features/homeowner/screens/homeowner_shell.dart';
import '../features/homeowner/screens/live_job_tracker_screen.dart';
import '../features/homeowner/screens/payment_screen.dart';
import '../features/homeowner/screens/yield_report_screen.dart';
import '../features/homeowner/screens/profile_setup_screen.dart';
import '../features/homeowner/screens/tree_inventory_setup_screen.dart';
import '../core/models/harvest_job.dart';
import '../features/site_manager/screens/broadcast_ping_screen.dart';
import '../features/site_manager/screens/byproduct_routing_screen.dart';
import '../features/site_manager/screens/college_verification_screen.dart';
import '../features/site_manager/screens/harvest_report_screen.dart';
import '../features/site_manager/screens/home_screen.dart';
import '../features/site_manager/screens/sm_profile_setup_screen.dart';
import '../features/site_manager/screens/training_screen.dart';
import '../features/site_manager/screens/yield_weigh_screen.dart';
import '../features/worker/screens/home_screen.dart';
import '../features/worker/screens/job_complete_screen.dart';
import '../features/worker/screens/job_ping_screen.dart';
import '../features/worker/screens/navigate_screen.dart';
import '../features/worker/screens/worker_setup_screen.dart';

/// Route paths, centralised so screens can navigate without magic strings.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const otp = '/otp';
  static const selectRole = '/select-role';

  static const homeownerProfileSetup = '/homeowner/profile-setup';
  static const homeownerTreeSetup = '/homeowner/tree-setup';
  static const homeownerHome = '/homeowner/home';
  static const homeownerBook = '/homeowner/book';
  static const homeownerTracker = '/homeowner/tracker';
  static const homeownerReport = '/homeowner/report';
  static const homeownerPayment = '/homeowner/payment';
  static const homeownerAmc = '/homeowner/amc';
  static const workerSetup = '/worker/setup';
  static const workerHome = '/worker/home';
  static const workerPing = '/worker/ping';
  static const workerNavigate = '/worker/navigate';
  static const workerComplete = '/worker/complete';
  static const managerProfileSetup = '/manager/profile-setup';
  static const managerVerification = '/manager/verification';
  static const managerHome = '/manager/home';
  static const managerTraining = '/manager/training';
  static const managerWeigh = '/manager/weigh';
  static const managerBroadcast = '/manager/broadcast';
  static const managerByproduct = '/manager/byproduct';
  static const managerReport = '/manager/report';
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

  // Bridge the onboarding flag too, so finishing onboarding re-runs redirects.
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

      // 1. Auth still resolving -> hold on splash.
      if (authState.isLoading) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final user = authState.value;
      final seenOnboarding = onboardingListenable.value;
      final atAuthScreen = loc == AppRoutes.login || loc == AppRoutes.otp;

      // 2. Signed out. First-ever launch shows onboarding once; after that,
      //    login/otp are reachable.
      if (user == null) {
        if (!seenOnboarding) {
          return loc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
        }
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

      // 3c. Worker who hasn't finished setup (no name/district yet) -> setup.
      if (user.role == UserRole.worker && !user.isProfileComplete) {
        return loc == AppRoutes.workerSetup ? null : AppRoutes.workerSetup;
      }

      // 3d. Site manager who hasn't finished setup -> profile setup. The
      //     verification-pending gate is freely reachable during onboarding.
      if (user.role == UserRole.siteManager && !user.isProfileComplete) {
        const setupRoutes = {
          AppRoutes.managerProfileSetup,
          AppRoutes.managerVerification,
        };
        return setupRoutes.contains(loc)
            ? null
            : AppRoutes.managerProfileSetup;
      }

      // 4. Signed in with a role -> push out of any pre-home screen.
      final home = AppRoutes.homeForRole(user.role!);
      const preHome = {
        AppRoutes.splash,
        AppRoutes.onboarding,
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
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
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
      GoRoute(
        path: AppRoutes.workerSetup,
        builder: (_, _) => const WorkerSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerHome,
        builder: (_, _) => const WorkerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerPing,
        builder: (_, _) => const JobPingScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerNavigate,
        builder: (_, _) => const NavigateScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerComplete,
        builder: (_, _) => const JobCompleteScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerProfileSetup,
        builder: (_, _) => const SiteManagerProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerVerification,
        builder: (_, _) => const CollegeVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerHome,
        builder: (_, _) => const SiteManagerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerTraining,
        builder: (_, _) => const TrainingScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerWeigh,
        builder: (_, state) =>
            YieldWeighScreen(job: state.extra as HarvestJob),
      ),
      GoRoute(
        path: AppRoutes.managerBroadcast,
        builder: (_, state) =>
            BroadcastPingScreen(job: state.extra as HarvestJob),
      ),
      GoRoute(
        path: AppRoutes.managerByproduct,
        builder: (_, state) =>
            ByproductRoutingScreen(job: state.extra as HarvestJob),
      ),
      GoRoute(
        path: AppRoutes.managerReport,
        builder: (_, state) =>
            HarvestReportScreen(job: state.extra as HarvestJob),
      ),
      GoRoute(
        path: AppRoutes.b2bHome,
        builder: (_, _) => const B2BHomeScreen(),
      ),
    ],
  );
});
