import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:homeowner/router.dart';
import 'package:core/core/models/tree_inventory.dart';
import 'package:core/core/models/yield_estimate.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/homeowner_providers.dart';
import 'package:core/core/widgets/app_icon.dart';

/// Book a harvest — pick crops, a date, ripe/all, see the live estimate, and
/// confirm (calls `calculateYieldEstimate` + creates the `/jobs` doc). Matches
/// `BookScreen` in app-screens-flow.jsx / `app.css`.
class BookHarvestScreen extends ConsumerStatefulWidget {
  const BookHarvestScreen({super.key});

  @override
  ConsumerState<BookHarvestScreen> createState() => _BookHarvestScreenState();
}

class _BookHarvestScreenState extends ConsumerState<BookHarvestScreen> {
  final Set<CropType> _selected = {};
  int _dayIdx = 1;
  bool _ripeOnly = true;
  bool _submitting = false;
  bool _initialised = false;

  late final List<_Day> _days = _buildDays();

  List<_Day> _buildDays() {
    final now = DateTime.now();
    const dows = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return [
      for (int i = 0; i < 7; i++)
        () {
          final d = DateTime(now.year, now.month, now.day + i);
          final label = i == 0
              ? 'Today'
              : i == 1
                  ? 'Tomorrow'
                  : dows[d.weekday % 7];
          return _Day(date: d, dow: label, ripe: i <= 2);
        }(),
    ];
  }

  Map<CropType, int> _countsFor(List<TreeInventory> trees) {
    final map = <CropType, int>{};
    for (final t in trees) {
      map[t.type] = (map[t.type] ?? 0) + t.count;
    }
    return map;
  }

  YieldEstimate _localEstimate(Map<CropType, int> counts) {
    final factor = _ripeOnly ? 0.6 : 1.0;
    double kg = 0, earning = 0;
    for (final c in _selected) {
      final cropKg = (counts[c] ?? 0) * c.kgPerTree * factor;
      kg += cropKg;
      earning += cropKg * c.ratePerKg;
    }
    return YieldEstimate(
        estimatedKg: kg,
        estimatedEarning: earning,
        marketRate: kg == 0 ? 0 : earning / kg);
  }

  Future<void> _confirm(Map<CropType, int> counts, String district) async {
    if (_selected.isEmpty) {
      _snack('Pick at least one crop to harvest.');
      return;
    }
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      _snack('Not signed in.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final service = ref.read(homeownerServiceProvider);
      final selectedCounts = {
        for (final c in _selected) c: counts[c] ?? 0,
      };
      final estimate = await service.calculateYieldEstimate(
        treeCounts: selectedCounts,
        district: district,
        ripeOnly: _ripeOnly,
      );
      await service.createJob(
        uid: user.uid,
        crops: _selected.toList(),
        scheduledAt: DateTime(_days[_dayIdx].date.year, _days[_dayIdx].date.month,
            _days[_dayIdx].date.day, 8),
        estimatedYieldKg: estimate.estimatedKg,
        district: district,
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      await _showConfirmSheet(estimate);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _snack('Could not book: $e');
    }
  }

  Future<void> _showConfirmSheet(YieldEstimate estimate) async {
    final day = _days[_dayIdx];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8015331F),
      builder: (ctx) => _ConfirmSheet(
        cropLabel: _selected.map((c) => c.label).join(' + '),
        dateLabel: '${day.dow}, ${day.date.day}',
        earning: estimate.estimatedEarning,
        onTrack: () {
          Navigator.of(ctx).pop();
          context.go(AppRoutes.homeownerTracker);
        },
        onClose: () {
          Navigator.of(ctx).pop();
          context.go(AppRoutes.homeownerHome);
        },
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final uid = user?.uid ?? '';
    final district = user?.district ?? '';
    final treesAsync = ref.watch(treeInventoryProvider(uid));
    final trees = treesAsync.maybeWhen(
        data: (t) => t, orElse: () => const <TreeInventory>[]);
    final counts = _countsFor(trees);

    // Preselect the first owned crop once.
    if (!_initialised && counts.isNotEmpty) {
      _selected.add(counts.keys.first);
      _initialised = true;
    }

    final cropTypes =
        counts.isNotEmpty ? counts.keys.toList() : CropType.values.toList();
    final estimate = _localEstimate(counts);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Book a harvest')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.gutter, 4, AppSpace.gutter, 12),
                children: [
                  Text('Pick crop', style: AppText.h3()),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 134,
                    ),
                    itemCount: cropTypes.length,
                    itemBuilder: (_, i) {
                      final c = cropTypes[i];
                      final cnt = counts[c] ?? 0;
                      return _CropCell(
                        type: c,
                        selected: _selected.contains(c),
                        sub: cnt > 0 ? '$cnt registered' : 'ripening soon',
                        onTap: () => setState(() {
                          _selected.contains(c)
                              ? _selected.remove(c)
                              : _selected.add(c);
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  Text('When', style: AppText.h3()),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 102,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _days.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 9),
                      itemBuilder: (_, i) => _DayCell(
                        day: _days[i],
                        selected: i == _dayIdx,
                        onTap: () => setState(() => _dayIdx = i),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Segment(
                    ripeOnly: _ripeOnly,
                    onChanged: (v) => setState(() => _ripeOnly = v),
                  ),
                  const SizedBox(height: 18),
                  _PreviewCard(estimate: estimate),
                ],
              ),
            ),
            _StickyFoot(
              earning: estimate.estimatedEarning,
              submitting: _submitting,
              onConfirm: () => _confirm(counts, district),
            ),
          ],
        ),
      ),
    );
  }
}

class _Day {
  final DateTime date;
  final String dow;
  final bool ripe;
  const _Day({required this.date, required this.dow, required this.ripe});
}

class _CropCell extends StatelessWidget {
  final CropType type;
  final bool selected;
  final String sub;
  final VoidCallback onTap;

  const _CropCell({
    required this.type,
    required this.selected,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceSunk : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.border,
            width: 1.5,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(color: Color(0x1A1E4D2B), blurRadius: 0, spreadRadius: 3)
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: CropPalette.tint(type),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: CropGlyph(type, size: 24, color: CropPalette.fg(type)),
                ),
                const SizedBox(height: 11),
                Text(type.label,
                    style: AppText.title().copyWith(fontSize: 16)),
                const SizedBox(height: 2),
                Text(sub, style: AppText.caption().copyWith(fontSize: 12.5)),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.brand : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.brand : AppColors.borderStrong,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? AppIcon('check',
                        size: 15, color: Colors.white, strokeWidth: 2.6)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final _Day day;
  final bool selected;
  final VoidCallback onTap;

  const _DayCell(
      {required this.day, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(day.dow,
                maxLines: 1,
                overflow: TextOverflow.clip,
                softWrap: false,
                style: AppText.caption().copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.fg3)),
            const SizedBox(height: 7),
            Text('${day.date.day}',
                style: AppText.displayNum(19,
                    color: selected ? Colors.white : AppColors.fg1)),
            const SizedBox(height: 6),
            if (day.ripe)
              Text('● ripe',
                  style: AppText.caption().copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.greenLeaf200
                          : AppColors.green600))
            else
              const SizedBox(height: 11),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final bool ripeOnly;
  final ValueChanged<bool> onChanged;

  const _Segment({required this.ripeOnly, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunk,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: _seg('Ripe only', ripeOnly, () => onChanged(true), icon: true)),
          Expanded(child: _seg('All', !ripeOnly, () => onChanged(false))),
        ],
      ),
    );
  }

  Widget _seg(String label, bool on, VoidCallback onTap, {bool icon = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: on ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: on ? AppShadows.sm : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon) ...[
              AppIcon('check',
                  size: 16,
                  color: on ? AppColors.brand : AppColors.fg3,
                  strokeWidth: 2.2),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: AppText.bodySm().copyWith(
                    fontWeight: FontWeight.w600,
                    color: on ? AppColors.brandInk : AppColors.fg2)),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final YieldEstimate estimate;
  const _PreviewCard({required this.estimate});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.greenForest800, AppColors.greenForest900],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x57F4A52A), Color(0x00F4A52A)],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _block(
                        'Est. yield',
                        '${estimate.estimatedKg.toStringAsFixed(0)} kg',
                        Colors.white,
                      ),
                    ),
                    _block(
                      'Est. earning',
                      '₹${estimate.estimatedEarning.toStringAsFixed(0)}',
                      AppColors.amber400,
                      alignEnd: true,
                    ),
                  ],
                ),
                Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    color: Colors.white.withValues(alpha: 0.16)),
                Row(
                  children: [
                    AppIcon('shield',
                        size: 15,
                        color: Colors.white.withValues(alpha: 0.7),
                        strokeWidth: 1.8),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Final price confirmed after weighing on-site.',
                        style: AppText.caption().copyWith(
                            color: Colors.white.withValues(alpha: 0.78)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _block(String k, String v, Color valueColor, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(k,
            style: AppText.caption()
                .copyWith(color: AppColors.greenLeaf200, fontSize: 12)),
        const SizedBox(height: 6),
        Text(v, style: AppText.displayNum(28, color: valueColor)),
      ],
    );
  }
}

class _StickyFoot extends StatelessWidget {
  final double earning;
  final bool submitting;
  final VoidCallback onConfirm;

  const _StickyFoot({
    required this.earning,
    required this.submitting,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpace.gutter, 12, AppSpace.gutter,
          12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(color: AppColors.bg),
      child: GestureDetector(
        onTap: submitting ? null : onConfirm,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: AppShadows.accent,
          ),
          child: submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.onAccent))
              : Text('Confirm booking · ₹${earning.toStringAsFixed(0)}',
                  style: AppText.button().copyWith(color: AppColors.onAccent)),
        ),
      ),
    );
  }
}

class _ConfirmSheet extends StatelessWidget {
  final String cropLabel;
  final String dateLabel;
  final double earning;
  final VoidCallback onTrack;
  final VoidCallback onClose;

  const _ConfirmSheet({
    required this.cropLabel,
    required this.dateLabel,
    required this.earning,
    required this.onTrack,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          boxShadow: AppShadows.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.statusCompleteBg,
                shape: BoxShape.circle,
              ),
              child: AppIcon('check',
                  size: 36, color: AppColors.statusCompleteFg, strokeWidth: 2.6),
            ),
            const SizedBox(height: 16),
            Text('Harvest booked!', style: AppText.h2()),
            const SizedBox(height: 8),
            Text('We’re assigning a site manager near you.',
                textAlign: TextAlign.center,
                style: AppText.body().copyWith(color: AppColors.fg2)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.surfaceSunk,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Column(
                children: [
                  _row('Crop', cropLabel),
                  const SizedBox(height: 9),
                  _row('Date', dateLabel),
                  const SizedBox(height: 9),
                  _row('Est. earning', '₹${earning.toStringAsFixed(0)}',
                      strong: true),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onTrack,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View tracker', style: AppText.button()),
                    const SizedBox(width: 8),
                    AppIcon('arrow-right',
                        size: 18, color: AppColors.onBrand, strokeWidth: 2.2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(onPressed: onClose, child: const Text('Back to home')),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v, {bool strong = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: AppText.bodySm().copyWith(color: AppColors.fg2)),
        Text(v,
            style: AppText.bodySm().copyWith(
                fontWeight: FontWeight.w700,
                color: strong ? AppColors.brandInk : AppColors.fg1)),
      ],
    );
  }
}
