import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:core/core/models/byproduct.dart';
import 'package:core/core/models/harvest_job.dart';
import 'package:core/core/models/job_step.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/site_manager_providers.dart';
import '../widgets/sm_widgets.dart';

/// Log the byproducts a harvest generated and auto-route each to its nearest
/// registered buyer (matched by accepted type + GeoPoint distance). Turns
/// disposal cost into revenue. Writes `/byproduct_routes`.
class ByproductRoutingScreen extends ConsumerStatefulWidget {
  final HarvestJob job;
  const ByproductRoutingScreen({super.key, required this.job});

  @override
  ConsumerState<ByproductRoutingScreen> createState() =>
      _ByproductRoutingScreenState();
}

class _ByproductRoutingScreenState
    extends ConsumerState<ByproductRoutingScreen> {
  final Map<ByproductType, double> _weights = {};
  final Map<ByproductType, ByproductBuyer> _chosenBuyer = {};
  bool _routing = false;

  List<ByproductType> get _applicable {
    final crops = widget.job.cropTypes.map((c) => c.toLowerCase()).toSet();
    final types = <ByproductType>[
      ByproductType.coconutHusk,
      ByproductType.coconutShell,
    ];
    if (crops.contains('jackfruit')) types.add(ByproductType.jackfruitRags);
    if (crops.contains('arecanut') || crops.contains('areca')) {
      types.add(ByproductType.arecaWaste);
    }
    return types;
  }

  void _toggle(ByproductType t) {
    setState(() {
      if (_weights.containsKey(t)) {
        _weights.remove(t);
        _chosenBuyer.remove(t);
      } else {
        _weights[t] = 10;
      }
    });
  }

  void _delta(ByproductType t, double d) {
    setState(() => _weights[t] = ((_weights[t] ?? 0) + d).clamp(0, 999));
  }

  Future<void> _routeAll() async {
    final selected = _weights.entries.where((e) => e.value > 0).toList();
    if (selected.isEmpty) return;
    setState(() => _routing = true);
    final uid = ref.read(authStateProvider).value?.uid ?? '';
    try {
      final svc = ref.read(siteManagerServiceProvider);
      final routes = <ByproductRoute>[];
      for (final e in selected) {
        final buyer = _chosenBuyer[e.key];
        routes.add(ByproductRoute(
          type: e.key,
          weightKg: e.value,
          buyerId: buyer?.id ?? 'unassigned',
          buyerName: buyer?.name ?? 'Nearest buyer',
        ));
      }
      await svc.routeByproducts(jobId: widget.job.id, routes: routes);
      await svc.completeStep(
          jobId: widget.job.id,
          uid: uid,
          kind: ManagerStepKind.byproductsRouted);
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _routing = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not route: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _weights.values.where((w) => w > 0).length;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SmPaperHeader(
            title: 'Route byproducts',
            subtitle: 'Match each type to its nearest buyer',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpace.s4),
              children: [
                const SmOverline('Byproducts generated'),
                const SizedBox(height: AppSpace.s3),
                for (final t in _applicable) ...[
                  _typeCard(t),
                  const SizedBox(height: AppSpace.s3),
                ],
              ],
            ),
          ),
          _routeBar(selectedCount),
        ],
      ),
    );
  }

  Widget _typeCard(ByproductType t) {
    final on = _weights.containsKey(t);
    return SmCard(
      border: Border.all(
          color: on ? AppColors.green600.withValues(alpha: 0.5) : AppColors.border,
          width: on ? 1.5 : 1),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: on ? AppColors.greenLeaf100 : AppColors.surfaceSunk,
                    borderRadius: BorderRadius.circular(AppRadii.md)),
                child: Icon(t.icon,
                    size: 22,
                    color: on ? AppColors.greenForest700 : AppColors.fg3),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.label,
                        style: AppText.title()
                            .copyWith(fontSize: 16, color: AppColors.fg1)),
                    Text(t.buyerHint,
                        style:
                            AppText.caption().copyWith(color: AppColors.fg3)),
                  ],
                ),
              ),
              Switch(
                value: on,
                activeThumbColor: AppColors.green600,
                onChanged: (_) => _toggle(t),
              ),
            ],
          ),
          if (on) ...[
            const Divider(height: 20, color: AppColors.border),
            Row(
              children: [
                Text('Weight',
                    style: AppText.bodySm().copyWith(color: AppColors.fg2)),
                const Spacer(),
                SmStepperCounter(
                  value: (_weights[t] ?? 0).round(),
                  onDelta: (d) => _delta(t, d * 5.0),
                ),
                const SizedBox(width: 8),
                Text('kg',
                    style: AppText.bodySm().copyWith(color: AppColors.fg3)),
              ],
            ),
            const SizedBox(height: AppSpace.s3),
            _BuyerMatch(
              type: t,
              near: widget.job.location,
              selectedId: _chosenBuyer[t]?.id,
              onPick: (b) => setState(() => _chosenBuyer[t] = b),
            ),
          ],
        ],
      ),
    );
  }

  Widget _routeBar(int count) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.s4, AppSpace.s3, AppSpace.s4, AppSpace.s3),
          child: SmButton(
            label: count == 0
                ? 'Select a byproduct to route'
                : 'Route $count byproduct${count == 1 ? "" : "s"}',
            icon: Icons.local_shipping_outlined,
            kind: SmButtonKind.brand,
            large: true,
            loading: _routing,
            onTap: count == 0 ? null : _routeAll,
          ),
        ),
      ),
    );
  }
}

/// Nearest-buyer suggestion for a byproduct type (sorted by GeoPoint distance).
class _BuyerMatch extends ConsumerWidget {
  final ByproductType type;
  final GeoPoint? near;
  final String? selectedId;
  final ValueChanged<ByproductBuyer> onPick;
  const _BuyerMatch({
    required this.type,
    required this.near,
    required this.selectedId,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async =
        ref.watch(nearbyBuyersProvider((type: type, near: near)));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2))),
      ),
      error: (_, _) => Text('No buyers found nearby',
          style: AppText.bodySm().copyWith(color: AppColors.fg3)),
      data: (buyers) {
        if (buyers.isEmpty) {
          return Text('No registered buyers for this type yet',
              style: AppText.bodySm().copyWith(color: AppColors.fg3));
        }
        // Auto-pick the nearest on first build.
        final chosenId = selectedId ?? buyers.first.id;
        if (selectedId == null) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => onPick(buyers.first));
        }
        return Column(
          children: [
            for (final b in buyers.take(2)) _buyerTile(b, b.id == chosenId),
          ],
        );
      },
    );
  }

  Widget _buyerTile(ByproductBuyer b, bool selected) {
    return GestureDetector(
      onTap: () => onPick(b),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceSunk : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
              color: selected ? AppColors.green600 : AppColors.border,
              width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? AppColors.green600 : AppColors.borderStrong),
            const SizedBox(width: 10),
            Expanded(
              child: Text(b.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySm().copyWith(
                      color: AppColors.fg1, fontWeight: FontWeight.w600)),
            ),
            SmChip('${b.distanceKmFrom(near).toStringAsFixed(1)} km',
                icon: Icons.place_outlined, kind: SmChipKind.line),
          ],
        ),
      ),
    );
  }
}
