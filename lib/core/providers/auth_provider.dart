import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Single shared [AuthService] instance.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Dev-only login bypass. When non-null, [authStateProvider] emits this user
/// instead of the live Firebase stream — used by the debug "dev login" buttons
/// on [LoginScreen] so the full app is testable while phone auth is disabled in
/// `thengapari-dev`. Stays `null` in production (the buttons are `kDebugMode`-
/// gated), so the real auth path is unaffected.
class DevAuthOverride extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  void set(AppUser? user) => state = user;
}

final devAuthOverrideProvider =
    NotifierProvider<DevAuthOverride, AppUser?>(DevAuthOverride.new);

/// The current authenticated user (with role), or `null` when signed out.
///
/// Drives role-based routing in `lib/app/router.dart`.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final override = ref.watch(devAuthOverrideProvider);
  if (override != null) return Stream<AppUser?>.value(override);
  return ref.watch(authServiceProvider).authStateChanges;
});
