import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/b2b/screens/business_profile_setup_screen.dart';
import 'features/b2b/screens/gst_verification_screen.dart';
import 'features/b2b/screens/home_screen.dart';
import 'features/b2b/screens/invoice_view_screen.dart';
import 'features/b2b/screens/listing_detail_screen.dart';
import 'features/b2b/screens/order_tracking_screen.dart';
import 'features/b2b/screens/prebook_screen.dart';
import 'features/b2b/screens/standing_order_screen.dart';

/// Route paths for the B2B Portal app (single-role — no role gate).
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';

  static const b2bProfileSetup = '/b2b/profile-setup';
  static const b2bVerification = '/b2b/verification';
  static const b2bHome = '/b2b/home';
  static const b2bListing = '/b2b/listing';
  static const b2bPrebook = '/b2b/prebook';
  static const b2bTracking = '/b2b/tracking';
  static const b2bStanding = '/b2b/standing';
  static const b2bInvoice = '/b2b/invoice';
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
          AppRoutes.b2bProfileSetup,
          AppRoutes.b2bVerification,
        };
        return setupRoutes.contains(loc) ? null : AppRoutes.b2bProfileSetup;
      }
      const preHome = {AppRoutes.splash, AppRoutes.onboarding, AppRoutes.login};
      return preHome.contains(loc) ? AppRoutes.b2bHome : null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
          path: AppRoutes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.b2bProfileSetup,
          builder: (_, _) => const BusinessProfileSetupScreen()),
      GoRoute(
          path: AppRoutes.b2bVerification,
          builder: (_, _) => const GSTVerificationScreen()),
      GoRoute(path: AppRoutes.b2bHome, builder: (_, _) => const B2BHomeScreen()),
      GoRoute(
          path: AppRoutes.b2bListing,
          builder: (_, state) =>
              ListingDetailScreen(listing: state.extra as InventoryListing)),
      GoRoute(
          path: AppRoutes.b2bPrebook,
          builder: (_, state) => PreBookScreen(args: state.extra as PreBookArgs)),
      GoRoute(
          path: AppRoutes.b2bTracking,
          builder: (_, state) =>
              OrderTrackingScreen(order: state.extra as B2BOrder)),
      GoRoute(
          path: AppRoutes.b2bStanding,
          builder: (_, _) => const StandingOrderSetupScreen()),
      GoRoute(
          path: AppRoutes.b2bInvoice,
          builder: (_, state) =>
              InvoiceViewScreen(order: state.extra as B2BOrder)),
    ],
  );
});
