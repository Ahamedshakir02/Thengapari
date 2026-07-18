import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/models/app_user.dart';
import '../../../core/providers/auth_provider.dart';

/// LEGACY — from the single-app era. The four split apps are single-role
/// (role is chosen at install; each app's setup screen writes the role), so
/// no router references this screen anymore. Kept only for reference; it
/// still uses the legacy AgriColors palette and should not be revived without
/// restyling to AppColors.
///
/// Shown when a user is signed in but has no role yet (first login). Picking a
/// role writes it to `/users/{uid}`; the router then routes onward (homeowner
/// → profile setup, other roles → their home).
class RoleGateScreen extends ConsumerStatefulWidget {
  const RoleGateScreen({super.key});

  @override
  ConsumerState<RoleGateScreen> createState() => _RoleGateScreenState();
}

class _RoleGateScreenState extends ConsumerState<RoleGateScreen> {
  bool _saving = false;

  Future<void> _pick(UserRole role) async {
    setState(() => _saving = true);
    try {
      await ref.read(authServiceProvider).setRole(role);
      // Router redirect handles navigation once the auth stream re-emits.
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not set role: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                'This is set once. It decides which app you see.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6E6B60)),
              ),
              const SizedBox(height: 28),
              _RoleTile(
                icon: Icons.home_outlined,
                title: 'Homeowner',
                subtitle: 'Book harvests for my trees',
                onTap: _saving ? null : () => _pick(UserRole.homeowner),
              ),
              _RoleTile(
                icon: Icons.work_outline,
                title: 'Worker',
                subtitle: 'Accept jobs and earn',
                onTap: _saving ? null : () => _pick(UserRole.worker),
              ),
              _RoleTile(
                icon: Icons.assignment_outlined,
                title: 'Site Manager',
                subtitle: 'Run on-site operations',
                onTap: _saving ? null : () => _pick(UserRole.siteManager),
              ),
              _RoleTile(
                icon: Icons.storefront_outlined,
                title: 'B2B Buyer',
                subtitle: 'Buy fresh produce',
                onTap: _saving ? null : () => _pick(UserRole.b2b),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed:
                    _saving ? null : () => ref.read(authServiceProvider).signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _RoleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AgriColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AgriColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AgriColors.green50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AgriColors.green600, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF173404))),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6E6B60))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFB4B2A9)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
