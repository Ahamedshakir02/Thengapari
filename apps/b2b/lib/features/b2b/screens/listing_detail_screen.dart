import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:b2b/router.dart';
import 'package:core/core/models/inventory_listing.dart';
import 'package:core/core/providers/b2b_providers.dart';
import '../widgets/b2b_widgets.dart';

/// Full listing detail: freshness, platform-vs-wholesale price bars, farm
/// source, quantity, and the 24h price-lock banner.
/// Matches `Designs/ThengaPari B2B Portal App/screen2.jsx`.
class ListingDetailScreen extends ConsumerStatefulWidget {
  final InventoryListing listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  late int _qty = widget.listing.unit == 'kg' ? 40 : 150;
  int get _step => widget.listing.unit == 'kg' ? 5 : 10;

  @override
  Widget build(BuildContext context) {
    // Prefer the live document (qty/price changes) but fall back to the passed
    // listing so the screen renders instantly.
    final l = ref.watch(listingDetailProvider(widget.listing.id)).value ??
        widget.listing;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          B2bBackBar(title: 'Listing', onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _hero(l),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.cropType.label,
                                    style: AppText.h2()
                                        .copyWith(color: AppColors.fg1)),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    GradeTag(l.grade),
                                    const SizedBox(width: 7),
                                    if (l.variety != null)
                                      Text(l.variety!,
                                          style: AppText.bodySm()
                                              .copyWith(color: AppColors.fg3)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SaveBadge(percent: l.savingsPercent),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _freshness(l),
                      const SizedBox(height: 16),
                      _infoGrid(l),
                    ],
                  ),
                ),
                const B2bSectionHead(title: 'Price comparison'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: B2bCard(
                      padding: const EdgeInsets.all(16),
                      child: _PriceCompare(listing: l)),
                ),
                const B2bSectionHead(title: 'Farm source', action: 'View profile'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: B2bCard(child: _farm(l)),
                ),
                const B2bSectionHead(title: 'Quantity'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: B2bCard(
                      padding: const EdgeInsets.all(16), child: _qtyCard(l)),
                ),
                _lockBanner(l),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _footer(l),
        ],
      ),
    );
  }

  Widget _hero(InventoryListing l) {
    return Container(
      height: 188,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 0.9,
          colors: [l.cropType.tint, AppColors.paper50],
        ),
      ),
      child: Stack(
        children: [
          Center(child: CropGlyph(crop: l.cropType, size: 120)),
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                boxShadow: AppShadows.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFF2E9E55), shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  Text(
                      'Harvested ${l.freshnessHours}h ago · ${l.freshnessLabel.toLowerCase()}',
                      style: AppText.bodySm().copyWith(
                          color: AppColors.greenForest800,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _freshness(InventoryListing l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Freshness',
                style: AppText.caption().copyWith(color: AppColors.fg3)),
            const Spacer(),
            Text(l.freshnessLabel,
                style: AppText.caption().copyWith(
                    color: AppColors.green600, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: l.freshnessFraction,
            minHeight: 7,
            backgroundColor: AppColors.surfaceSunk,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF2E9E55)),
          ),
        ),
      ],
    );
  }

  Widget _infoGrid(InventoryListing l) {
    final cells = [
      ('Available', '${l.quantityRemaining} ${l.unit}'),
      ('Distance', '${l.distanceKm?.toStringAsFixed(1) ?? "—"} km · ${l.ward}'),
      ('Condition', l.condition ?? '—'),
      ('Harvest', l.harvestLabel),
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        children: [
          Row(children: [_cell(cells[0]), _vline(), _cell(cells[1])]),
          const Divider(height: 1, color: AppColors.border),
          Row(children: [_cell(cells[2]), _vline(), _cell(cells[3])]),
        ],
      ),
    );
  }

  Widget _vline() => Container(width: 1, height: 48, color: AppColors.border);

  Widget _cell((String, String) c) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.$1, style: AppText.caption().copyWith(color: AppColors.fg3)),
            const SizedBox(height: 3),
            Text(c.$2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodySm().copyWith(
                    color: AppColors.fg1, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _farm(InventoryListing l) {
    final name = l.farmName ?? 'Farm collective';
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? '' : w[0])
        .join();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: AppColors.blue100, shape: BoxShape.circle),
            child: Text(
                initials.length <= 2
                    ? initials.toUpperCase()
                    : initials.substring(0, 2).toUpperCase(),
                style: AppText.displayNum(18, color: AppColors.blue700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppText.title().copyWith(color: AppColors.fg1)),
                Text('${l.farmPlot ?? l.ward} · since ${l.farmSince ?? "—"}',
                    style: AppText.bodySm().copyWith(color: AppColors.fg3)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.amber500),
                  const SizedBox(width: 3),
                  Text((l.farmRating ?? 4.8).toStringAsFixed(1),
                      style: AppText.bodySm().copyWith(
                          color: AppColors.fg1, fontWeight: FontWeight.w700)),
                ],
              ),
              Text('${l.farmHarvests ?? 0} harvests',
                  style: AppText.caption().copyWith(color: AppColors.fg3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyCard(InventoryListing l) {
    final subtotal = _qty * l.unitPrice;
    final saved = (_qty * l.savingsPerUnit).round();
    return Row(
      children: [
        Row(
          children: [
            _qtyBtn(Icons.remove, () => setState(() => _qty = (_qty - _step).clamp(_step, 99999))),
            SizedBox(
              width: 70,
              child: Column(
                children: [
                  Text('$_qty', style: AppText.displayNum(24, color: AppColors.fg1)),
                  Text(l.unit == 'kg' ? 'kilograms' : 'pieces',
                      style: AppText.caption().copyWith(color: AppColors.fg3)),
                ],
              ),
            ),
            _qtyBtn(Icons.add, () => setState(() => _qty += _step)),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Subtotal', style: AppText.caption().copyWith(color: AppColors.fg3)),
            Text('₹${b2bInr(subtotal)}',
                style: AppText.displayNum(22, color: AppColors.fg1)),
            Text('save ₹${b2bInr(saved)}',
                style: AppText.caption().copyWith(
                    color: AppColors.green600, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderStrong, width: 1.5),
        ),
        child: Icon(icon, size: 22, color: AppColors.blue700),
      ),
    );
  }

  Widget _lockBanner(InventoryListing l) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.amber100,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.amber200),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.amber400,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.lock_outline,
                size: 18, color: AppColors.greenForest900),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(TextSpan(
                style: AppText.bodySm().copyWith(
                    color: const Color(0xFF8A5A06), fontWeight: FontWeight.w600),
                children: [
                  const TextSpan(text: 'This '),
                  TextSpan(
                      text: '₹${l.unitPrice.toStringAsFixed(0)}/${l.unit}',
                      style: const TextStyle(color: Color(0xFF6E4504))),
                  const TextSpan(text: ' price is locked for '),
                  const TextSpan(
                      text: '24 hours',
                      style: TextStyle(color: Color(0xFF6E4504))),
                  const TextSpan(text: ' when you pre-book — no surge, no broker markup.'),
                ])),
          ),
        ],
      ),
    );
  }

  Widget _footer(InventoryListing l) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total · $_qty ${l.unit}',
                      style: AppText.caption().copyWith(color: AppColors.fg3)),
                  Text('₹${b2bInr(_qty * l.unitPrice)}',
                      style: AppText.displayNum(22, color: AppColors.fg1)),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: B2bButton(
                  label: 'Pre-book this lot',
                  onTap: () => context.push(AppRoutes.b2bPrebook,
                      extra: (listing: l, qty: _qty)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two side-by-side bars: ThengaPari price vs wholesale market.
class _PriceCompare extends StatelessWidget {
  final InventoryListing listing;
  const _PriceCompare({required this.listing});

  @override
  Widget build(BuildContext context) {
    final l = listing;
    final platFrac =
        l.wholesaleMarketPrice <= 0 ? 1.0 : l.unitPrice / l.wholesaleMarketPrice;
    return Column(
      children: [
        _bar('ThengaPari price', '₹${l.unitPrice.toStringAsFixed(0)}/${l.unit}',
            platFrac, AppColors.green600,
            const LinearGradient(
                colors: [AppColors.greenSage500, AppColors.green600])),
        const SizedBox(height: 14),
        _bar('Wholesale market',
            '₹${l.wholesaleMarketPrice.toStringAsFixed(1)}/${l.unit}', 1.0,
            AppColors.ink700, null, AppColors.ink400),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.statusCompleteBg,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                    'You save ₹${l.savingsPerUnit.toStringAsFixed(1)} on every ${l.unit}',
                    style: AppText.bodySm().copyWith(
                        color: AppColors.statusCompleteFg,
                        fontWeight: FontWeight.w600)),
              ),
              Text('${l.savingsPercent.toStringAsFixed(0)}% off',
                  style: AppText.displayNum(18, color: AppColors.statusCompleteFg)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bar(String label, String value, double frac, Color valueColor,
      LinearGradient? gradient,
      [Color? solid]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: solid ?? AppColors.green600,
                    borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 7),
            Expanded(
              child: Text(label,
                  style: AppText.bodySm().copyWith(color: AppColors.fg2)),
            ),
            Text(value, style: AppText.displayNum(16, color: valueColor)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(height: 30, color: AppColors.surfaceSunk),
              FractionallySizedBox(
                widthFactor: frac.clamp(0.0, 1.0),
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: gradient == null ? (solid ?? AppColors.ink400) : null,
                    gradient: gradient,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
