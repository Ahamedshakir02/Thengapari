import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';

/// Stub. Real site-manager dashboard (job queue, on-site checklist, yield
/// weighing, broadcast ping) is built in the Site Manager App phase.
class SiteManagerHomeScreen extends ConsumerWidget {
  const SiteManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Manager'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: const Center(child: Text('Site Manager App')),
    );
  }
}
