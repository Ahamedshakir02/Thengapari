import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';

/// Stub. Real B2B portal (live inventory, pre-book, order tracking, savings
/// dashboard) is built in the B2B Portal phase.
class B2BHomeScreen extends ConsumerWidget {
  const B2BHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('B2B Portal'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: const Center(child: Text('B2B Portal')),
    );
  }
}
