import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/providers/auth_provider.dart';

/// Stub shown when a user is signed in but has no role yet (first login).
///
/// The full role-selection + profile-creation UI is a later deliverable; for
/// the foundation this just keeps the auth -> role -> home flow from
/// dead-ending. The router sends any role-less authenticated user here.
class RoleGateScreen extends ConsumerWidget {
  const RoleGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.badge_outlined,
                  color: AgriColors.green400, size: 44),
              const SizedBox(height: 16),
              const Text(
                'Choose your role',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AgriColors.green900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Role selection & profile setup come in the next phase.\n'
                'Once a role is written to /users/{uid}, the router sends you '
                'to that role’s app automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => ref.read(authServiceProvider).signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
