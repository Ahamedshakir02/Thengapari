import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:core/app/design_tokens.dart';
import 'package:core/core/models/b2b_order.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/b2b_providers.dart';
import '../widgets/b2b_widgets.dart';

/// Active + past orders. Active orders show a progress stepper and a track CTA.
class OrdersScreen extends ConsumerStatefulWidget {
  final void Function(B2BOrder order) onTrack;
  const OrdersScreen({super.key, required this.onTrack});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _tab = 0; // 0 active, 1 history

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final active = ref.watch(activeOrdersProvider(uid)).value ?? const [];
    final history = ref.watch(orderHistoryProvider(uid)).value ?? const [];
    final list = _tab == 0 ? active : history;

    return Column(
      children: [
        const B2bAppBar(eyebrow: 'Upcoming', title: 'My pre-books'),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
          child: _segmented(active.length, history.length),
        ),
        Expanded(
          child: list.isEmpty
              ? _empty()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _OrderCard(
                    order: list[i],
                    onTrack: () => widget.onTrack(list[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _segmented(int active, int history) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunk,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        children: [
          _seg('Active · $active', 0),
          _seg('History · $history', 1),
        ],
      ),
    );
  }

  Widget _seg(String label, int i) {
    final on = _tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = i),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: on ? AppShadows.sm : null,
          ),
          child: Text(label,
              style: AppText.button().copyWith(
                  fontSize: 14,
                  color: on ? AppColors.blue700 : AppColors.fg2)),
        ),
      ),
    );
  }

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 52, color: AppColors.borderStrong),
              const SizedBox(height: 12),
              Text(_tab == 0 ? 'No active orders' : 'No past orders',
                  style: AppText.title().copyWith(color: AppColors.fg2)),
            ],
          ),
        ),
      );
}

class _OrderCard extends StatelessWidget {
  final B2BOrder order;
  final VoidCallback onTrack;
  const _OrderCard({required this.order, required this.onTrack});

  @override
  Widget build(BuildContext context) {
    final o = order;
    return B2bCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CropGlyphBox(crop: o.cropType, size: 46, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${o.cropType.label} · ${o.quantity} ${o.unit}',
                        style: AppText.title().copyWith(color: AppColors.fg1)),
                    Text('₹${b2bInr(o.totalAmount)}',
                        style: AppText.bodySm().copyWith(color: AppColors.fg3)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statusTag(o.status),
                  const SizedBox(height: 5),
                  Text('saved ₹${b2bInr(o.savingsAmount)}',
                      style: AppText.caption().copyWith(
                          color: AppColors.green600,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _OrderStepper(status: o.status),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  size: 16, color: AppColors.fg3),
              const SizedBox(width: 6),
              Text(
                  o.deliveryDate == null
                      ? 'Delivery scheduled'
                      : 'Est. ${o.deliveryDate!.day}/${o.deliveryDate!.month}',
                  style: AppText.bodySm().copyWith(color: AppColors.fg2)),
              const Spacer(),
              if (o.status.isActive)
                GestureDetector(
                  onTap: onTrack,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.blue700,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Track',
                          style: AppText.button()
                              .copyWith(color: Colors.white, fontSize: 14)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 16, color: Colors.white),
                    ]),
                  ),
                )
              else if (o.invoiceUrl != null)
                GestureDetector(
                  onTap: onTrack,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.receipt_outlined,
                        size: 16, color: AppColors.blue700),
                    const SizedBox(width: 5),
                    Text('Invoice',
                        style: AppText.bodySm().copyWith(
                            color: AppColors.blue700,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusTag(B2BOrderStatus s) {
    final (bg, fg) = s == B2BOrderStatus.delivered
        ? (AppColors.statusCompleteBg, AppColors.statusCompleteFg)
        : s == B2BOrderStatus.cancelled
            ? (AppColors.statusErrorBg, AppColors.statusErrorFg)
            : (AppColors.statusScheduledBg, AppColors.statusScheduledFg);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Text(s.label,
          style: AppText.caption().copyWith(color: fg, fontWeight: FontWeight.w700)),
    );
  }
}

/// Confirmed → Dispatched → Out for delivery → Delivered.
class _OrderStepper extends StatelessWidget {
  final B2BOrderStatus status;
  const _OrderStepper({required this.status});

  static const _steps = ['Confirmed', 'Dispatched', 'Out', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    final current = status.step;
    return Row(
      children: [
        for (int i = 0; i < _steps.length; i++) ...[
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= current ? AppColors.blue700 : AppColors.surfaceSunk,
                  border: Border.all(
                      color: i <= current
                          ? AppColors.blue700
                          : AppColors.borderStrong),
                ),
                child: i < current
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : i == current
                        ? const _PulseInner()
                        : null,
              ),
              const SizedBox(height: 4),
              Text(_steps[i],
                  style: AppText.caption().copyWith(
                      fontSize: 9.5,
                      color: i <= current ? AppColors.blue700 : AppColors.fg3,
                      fontWeight: i == current ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
          if (i < _steps.length - 1)
            Expanded(
              child: Container(
                height: 2.5,
                margin: const EdgeInsets.only(bottom: 16),
                color: i < current ? AppColors.blue700 : AppColors.border,
              ),
            ),
        ],
      ],
    );
  }
}

class _PulseInner extends StatelessWidget {
  const _PulseInner();
  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      );
}
