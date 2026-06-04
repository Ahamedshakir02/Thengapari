import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Single shared [AuthService] instance.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// The current authenticated user (with role), or `null` when signed out.
///
/// Drives role-based routing in `lib/app/router.dart`.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
