import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:core/app/design_tokens.dart';
import 'package:core/core/models/inventory_listing.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/b2b_providers.dart';
import '../widgets/b2b_widgets.dart';

/// Live produce market — the primary B2B screen. Real-time inventory stream
/// with a savings band, savings-by-crop chart, and crop/grade/distance filters.
/// Matches `Designs/ThengaPari B2B Portal App/screen1.jsx`. Uses a lazy
/// ListView so 100+ lots scroll without jank.
class InventoryScreen extends ConsumerStatefulWidget {
  final void Function(InventoryListing listing) onOpen;
  const InventoryScreen({super.key, required this.onOpen});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  static const _cropOpts = [null, B2BCrop.coconut, B2BCrop.mango, B2BCrop.pepper, B2BCrop.jackfruit];
  static const _cropLabels = ['All crops', 'Coconut', 'Mango', 'Pepper', 'Jackfruit'];
  static const _gradeOpts = [null, 'Grade A', 'Grade B'];
  static const _gradeLabels = ['Any grade', 'Grade A', 'Grade B'];
  static const _distOpts = [null, 5.0, 10.0];
  static const _distLabels = ['Any distance', '< 5 km', '< 10 km'];

  int _cropIdx = 0, _gradeIdx = 0, _distIdx = 0;

  InventoryFilter get _filter => (
        crop: _cropOpts[_cropIdx],
        grade: _gradeOpts[_gradeIdx],
        maxKm: _distOpts[_distIdx],
      );

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final savings = ref.watch(monthlySavingsProvider(uid)).value;
    final all = ref.watch(inventoryStreamProvider).value ?? const [];
    final listings = ref.watch(liveInventoryProvider(_filter)).value ?? const [];
    final chartRows = _chartRows(all);

    // Header blocks precede the lazy listing rows.
    final headers = <Widget>[
      SavingsBand(
        amount: savings?.totalSaved ?? 2140,
        avgPercent: savings?.avgPercent ?? 13,
        orders: savings?.orderCount ?? 18,
        bestDeal: _bestDeal(all),
      ),
      if (chartRows.isNotEmpty) ...[
        const B2bSectionHead(title: 'Savings by crop', action: 'This week'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: SavingsByCropChart(rows: chartRows),
        ),
      ],
      const SizedBox(height: 14),
      _filterRow(),
      B2bSectionHead(
          title: 'Available now · ${listings.length} lots',
          action: 'Sort: Best savings'),
    ];

    return Column(
      children: [
        const B2bAppBar(
          eyebrow: 'Live produce inventory',
          title: "Today's harvest",
          sub: 'Manjaly & nearby wards · updated 2 min ago',
          live: true,
          action: B2bIconBtn(icon: Icons.search),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: headers.length + (listings.isEmpty ? 1 : listings.length + 1),
            itemBuilder: (context, i) {
              if (i < headers.length) return headers[i];
              if (listings.isEmpty) return _empty();
              final li = i - headers.length;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _InventoryRow(
                  listing: listings[li],
                  first: li == 0,
                  last: li == listings.length - 1,
                  onOpen: () => widget.onOpen(listings[li]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _filterRow() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          B2bFilterChip(
            icon: Icons.circle_outlined,
            label: _cropLabels[_cropIdx],
            active: _cropIdx != 0,
            onTap: () => setState(() => _cropIdx = (_cropIdx + 1) % _cropOpts.length),
          ),
          const SizedBox(width: 8),
          B2bFilterChip(
            icon: Icons.star_border,
            label: _gradeLabels[_gradeIdx],
            active: _gradeIdx != 0,
            onTap: () => setState(() => _gradeIdx = (_gradeIdx + 1) % _gradeOpts.length),
          ),
          const SizedBox(width: 8),
          B2bFilterChip(
            icon: Icons.place_outlined,
            label: _distLabels[_distIdx],
            active: _distIdx != 0,
            onTap: () => setState(() => _distIdx = (_distIdx + 1) % _distOpts.length),
          ),
        ],
      ),
    );
  }

  List<(B2BCrop, double, String)> _chartRows(List<InventoryListing> all) {
    final best = <B2BCrop, double>{};
    for (final l in all) {
      best[l.cropType] = (best[l.cropType] ?? 0) > l.savingsPercent
          ? best[l.cropType]!
          : l.savingsPercent;
    }
    final rows = best.entries
        .map((e) => (e.key, e.value, '${e.value.toStringAsFixed(0)}%'))
        .toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    return rows.take(4).toList();
  }

  String? _bestDeal(List<InventoryListing> all) {
    if (all.isEmpty) return null;
    final best = all.reduce((a, b) => a.savingsPercent >= b.savingsPercent ? a : b);
    return '${best.cropType.label} · ${best.savingsPercent.toStringAsFixed(0)}% off';
  }

  Widget _empty() => Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 52, color: AppColors.borderStrong),
            const SizedBox(height: 12),
            Text('No lots match your filters',
                style: AppText.title().copyWith(color: AppColors.fg2)),
          ],
        ),
      );
}

class _InventoryRow extends StatelessWidget {
  final InventoryListing listing;
  final bool first;
  final bool last;
  final VoidCallback onOpen;
  const _InventoryRow({
    required this.listing,
    required this.first,
    required this.last,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l = listing;
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: first ? const BorderSide(color: AppColors.border) : BorderSide.none,
            left: const BorderSide(color: AppColors.border),
            right: const BorderSide(color: AppColors.border),
            bottom: const BorderSide(color: AppColors.border),
          ),
          borderRadius: BorderRadius.vertical(
            top: first ? const Radius.circular(AppRadii.lg) : Radius.zero,
            bottom: last ? const Radius.circular(AppRadii.lg) : Radius.zero,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CropGlyphBox(crop: l.cropType, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(l.cropType.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.title().copyWith(color: AppColors.fg1)),
                      ),
                      const SizedBox(width: 7),
                      GradeTag(l.grade),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text('${l.harvestLabel} · ${l.ward}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySm().copyWith(color: AppColors.fg3)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      SaveBadge(percent: l.savingsPercent, small: true),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text('· ${l.quantityRemaining} ${l.unit}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppText.caption().copyWith(color: AppColors.ink400)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('₹${l.unitPrice.toStringAsFixed(l.unitPrice % 1 == 0 ? 0 : 0)}',
                        style: AppText.displayNum(19, color: AppColors.fg1)),
                    Text('/${l.unit}',
                        style: AppText.caption().copyWith(color: AppColors.ink500)),
                  ],
                ),
                Text('₹${l.wholesaleMarketPrice.toStringAsFixed(1)}/${l.unit}',
                    style: AppText.caption().copyWith(
                        color: AppColors.ink400,
                        decoration: TextDecoration.lineThrough)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onOpen,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      boxShadow: AppShadows.accent,
                    ),
                    child: Text('Pre-book',
                        style: AppText.button().copyWith(
                            color: AppColors.onAccent, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
