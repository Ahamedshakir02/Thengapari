import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';

/// Stub. Real homeowner dashboard (hero landscape, stats, job cards) is built
/// in the Homeowner App phase.
class HomeownerHomeScreen extends ConsumerWidget {
  const HomeownerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homeowner'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: const Center(child: Text('Homeowner App')),
    );
  }
}
