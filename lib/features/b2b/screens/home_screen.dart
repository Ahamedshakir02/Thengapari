import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/design_tokens.dart';
import '../../../app/router.dart';
import '../../../core/models/b2b_order.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/b2b_providers.dart';
import '../widgets/b2b_widgets.dart';
import 'dashboard_screen.dart';
import 'inventory_screen.dart';
import 'orders_screen.dart';

/// B2B shell: Market / Orders / Savings tabs driven by [b2bTabProvider].
class B2BHomeScreen extends ConsumerWidget {
  const B2BHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(b2bTabProvider);
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final business =
        ref.watch(b2bProfileProvider(uid)).value?.businessName ?? 'Your business';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: tab,
        children: [
          InventoryScreen(
            onOpen: (listing) =>
                context.push(AppRoutes.b2bListing, extra: listing),
          ),
          OrdersScreen(onTrack: _track(context)),
          DashboardScreen(
            businessName: business,
            onNewStandingOrder: () => context.push(AppRoutes.b2bStanding),
          ),
        ],
      ),
      bottomNavigationBar: B2bBottomNav(
        index: tab,
        onTap: (i) => ref.read(b2bTabProvider.notifier).state = i,
      ),
    );
  }

  void Function(B2BOrder) _track(BuildContext context) => (order) {
        if (order.status == B2BOrderStatus.delivered) {
          context.push(AppRoutes.b2bInvoice, extra: order);
        } else {
          context.push(AppRoutes.b2bTracking, extra: order);
        }
      };
}
