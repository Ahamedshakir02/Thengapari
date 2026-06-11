import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:core/app/design_tokens.dart';
import 'package:core/core/models/amc_contract.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/homeowner_providers.dart';
import 'package:core/core/widgets/app_icon.dart';

/// Annual Maintenance Contract — pick a plan, see the seasonal auto-dispatch
/// calendar and savings, and subscribe (writes `/amc_contracts/{uid}`).
class AmcScreen extends ConsumerStatefulWidget {
  const AmcScreen({super.key});

  @override
  ConsumerState<AmcScreen> createState() => _AmcScreenState();
}

class _AmcScreenState extends ConsumerState<AmcScreen> {
  AmcPlan _selected = AmcPlan.standard;
  bool _subscribing = false;

  static const _months = [
    'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'
  ];
  static const _dispatchMonths = {2, 3, 4, 8, 9, 11}; // Mar/Apr/May/Sep/Oct/Dec

  Future<void> _subscribe() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    setState(() => _subscribing = true);
    try {
      await ref.read(homeownerServiceProvider).subscribeAmc(
            uid: user.uid,
            plan: _selected,
            nextDispatch: DateTime(DateTime.now().year, 9, 1),
          );
      if (!mounted) return;
      setState(() => _subscribing = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text('Subscribed to ${_selected.label} AMC.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _subscribing = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not subscribe: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final amc = ref.watch(amcContractProvider(uid));
    final active = amc.maybeWhen(data: (c) => c, orElse: () => null);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('AMC subscription')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter, 8, AppSpace.gutter, 12),
              children: [
                if (active != null) ...[
                  _ActivePlanCard(contract: active),
                  const SizedBox(height: 16),
                  Text('Change plan', style: AppText.h3()),
                  const SizedBox(height: 10),
                ] else ...[
                  Text('Never miss a harvest', style: AppText.h2()),
                  const SizedBox(height: 4),
                  Text(
                    'We auto-dispatch a crew at the right season for your crops '
                    '— no booking needed.',
                    style: AppText.bodySm().copyWith(color: AppColors.fg3),
                  ),
                  const SizedBox(height: 16),
                ],
                for (final plan in AmcPlan.values) ...[
                  _PlanCard(
                    plan: plan,
                    selected: _selected == plan,
                    onTap: () => setState(() => _selected = plan),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
                _SeasonalCalendar(
                    months: _months, dispatch: _dispatchMonths),
                const SizedBox(height: 14),
                _SavingsNote(plan: _selected),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(AppSpace.gutter, 12, AppSpace.gutter,
                12 + MediaQuery.of(context).padding.bottom),
            child: GestureDetector(
              onTap: _subscribing ? null : _subscribe,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  boxShadow: AppShadows.md,
                ),
                child: _subscribing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        active != null
                            ? 'Switch to ${_selected.label} · ₹${_selected.annualFee}/yr'
                            : 'Subscribe · ₹${_selected.annualFee}/yr',
                        style: AppText.button().copyWith(color: AppColors.onBrand)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final AmcPlan plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard(
      {required this.plan, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceSunk : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected ? null : AppShadows.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.brand : Colors.transparent,
                border: Border.all(
                    color: selected ? AppColors.brand : AppColors.borderStrong,
                    width: 1.5),
              ),
              child: selected
                  ? AppIcon('check',
                      size: 13, color: Colors.white, strokeWidth: 2.6)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.label,
                      style: AppText.title().copyWith(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(plan.coverage,
                      style: AppText.caption().copyWith(fontSize: 12.5)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${plan.annualFee}',
                    style: AppText.displayNum(18, color: AppColors.brandInk)),
                Text('/year', style: AppText.caption().copyWith(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonalCalendar extends StatelessWidget {
  final List<String> months;
  final Set<int> dispatch;

  const _SeasonalCalendar({required this.months, required this.dispatch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Auto-dispatch calendar', style: AppText.title()),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < months.length; i++)
                Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: dispatch.contains(i)
                            ? AppColors.brand
                            : AppColors.surfaceSunk,
                        shape: BoxShape.circle,
                      ),
                      child: Text(months[i],
                          style: AppText.caption().copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: dispatch.contains(i)
                                  ? Colors.white
                                  : AppColors.fg3)),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: AppColors.brand, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text('Scheduled auto-harvest months',
                  style: AppText.caption().copyWith(fontSize: 11.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavingsNote extends StatelessWidget {
  final AmcPlan plan;
  const _SavingsNote({required this.plan});

  @override
  Widget build(BuildContext context) {
    // Indicative saving vs ad-hoc booking.
    final saving = (plan.annualFee * 0.35).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
      decoration: BoxDecoration(
        color: AppColors.statusCompleteBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          AppIcon('trend-up', size: 20, color: AppColors.statusCompleteFg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                'Save about ₹$saving a year vs booking each harvest separately.',
                style: AppText.bodySm()
                    .copyWith(color: AppColors.statusCompleteFg)),
          ),
        ],
      ),
    );
  }
}

class _ActivePlanCard extends StatelessWidget {
  final AmcContract contract;
  const _ActivePlanCard({required this.contract});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.greenForest800, AppColors.greenForest900],
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.amber400,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text('ACTIVE',
                    style: AppText.caption().copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greenForest900)),
              ),
              const Spacer(),
              Text('₹${contract.annualFee}/yr',
                  style: AppText.caption().copyWith(
                      color: AppColors.greenLeaf200, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text('${contract.plan.label} plan',
              style: AppText.displayNum(24, color: Colors.white)),
          const SizedBox(height: 4),
          Text(contract.plan.coverage,
              style: AppText.caption()
                  .copyWith(color: AppColors.greenLeaf200, fontSize: 12.5)),
          if (contract.nextDispatch != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                AppIcon('calendar',
                    size: 15,
                    color: Colors.white.withValues(alpha: 0.8),
                    strokeWidth: 1.8),
                const SizedBox(width: 7),
                Text(
                    'Next auto-harvest: ${_fmt(contract.nextDispatch!)}',
                    style: AppText.caption()
                        .copyWith(color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[d.month - 1]} ${d.year}';
  }
}
