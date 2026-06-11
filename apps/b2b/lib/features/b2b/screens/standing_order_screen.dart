import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:core/core/models/inventory_listing.dart';
import 'package:core/core/models/standing_order.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/b2b_providers.dart';
import '../widgets/b2b_widgets.dart';

/// Set up a recurring auto-booked order. Writes `/standing_orders/{orderId}`;
/// the `processStandingOrders` cron books matching stock each cycle.
class StandingOrderSetupScreen extends ConsumerStatefulWidget {
  const StandingOrderSetupScreen({super.key});

  @override
  ConsumerState<StandingOrderSetupScreen> createState() =>
      _StandingOrderSetupScreenState();
}

class _StandingOrderSetupScreenState
    extends ConsumerState<StandingOrderSetupScreen> {
  // Rough per-unit price used only for the spend estimate.
  static const _approxPrice = {
    B2BCrop.coconut: 18.0,
    B2BCrop.mango: 95.0,
    B2BCrop.pepper: 480.0,
    B2BCrop.jackfruit: 40.0,
    B2BCrop.banana: 55.0,
    B2BCrop.ginger: 70.0,
    B2BCrop.arecanut: 300.0,
  };
  static const _grades = ['Grade A', 'Grade A + B', 'Any'];

  B2BCrop _crop = B2BCrop.coconut;
  String _grade = 'Grade A';
  int _qty = 100;
  StandingFrequency _freq = StandingFrequency.weekly;
  bool _maxPriceOn = false;
  double _maxPrice = 22;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  bool _saving = false;

  int get _step => _crop.unit == 'kg' ? 5 : 10;

  (int, int) get _estimateRange {
    final base = _qty * (_approxPrice[_crop] ?? 50) * _freq.perMonth;
    return ((base * 0.92).round(), (base * 1.08).round());
  }

  Future<void> _activate() async {
    final uid = ref.read(authStateProvider).value?.uid ?? '';
    setState(() => _saving = true);
    try {
      await ref.read(b2bServiceProvider).createStandingOrder(
            uid: uid,
            cropType: _crop,
            grade: _grade,
            quantityPerOrder: _qty,
            frequency: _freq,
            maxPricePer: _maxPriceOn ? _maxPrice : null,
            startDate: _startDate,
          );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not activate: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (lo, hi) = _estimateRange;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          B2bBackBar(title: 'New standing order', onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _label('Crop'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    for (final c in B2BCrop.values) _cropChoice(c),
                  ],
                ),
                const SizedBox(height: 20),
                _label('Grade preference'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final g in _grades) ...[
                      _gradeChoice(g),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                _label('Quantity per dispatch'),
                const SizedBox(height: 8),
                B2bCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text('$_qty ${_crop.unit}',
                          style: AppText.displayNum(22, color: AppColors.fg1)),
                      const Spacer(),
                      _stepBtn(Icons.remove,
                          () => setState(() => _qty = (_qty - _step).clamp(_step, 99999))),
                      const SizedBox(width: 10),
                      _stepBtn(Icons.add, () => setState(() => _qty += _step)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _label('Frequency'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final f in StandingFrequency.values) ...[
                      _freqChoice(f),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                _maxPriceCard(),
                const SizedBox(height: 20),
                _startDateCard(),
                const SizedBox(height: 20),
                _estimateCard(lo, hi),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: B2bButton(
                  label: 'Start standing order',
                  icon: Icons.autorenew,
                  loading: _saving,
                  onTap: _activate,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) =>
      Text(t.toUpperCase(), style: AppText.overline().copyWith(color: AppColors.fg3));

  Widget _cropChoice(B2BCrop c) {
    final on = _crop == c;
    return GestureDetector(
      onTap: () => setState(() {
        _crop = c;
        _qty = (_qty ~/ _step) * _step;
        if (_qty < _step) _qty = _step;
      }),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
        decoration: BoxDecoration(
          color: on ? AppColors.blue100 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
              color: on ? AppColors.blue700 : AppColors.borderStrong, width: 1.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CropGlyphBox(crop: c, size: 26, radius: 999, glyphSize: 18),
            const SizedBox(width: 8),
            Text(c.label,
                style: AppText.bodySm().copyWith(
                    fontWeight: FontWeight.w600,
                    color: on ? AppColors.blue900 : AppColors.fg2)),
          ],
        ),
      ),
    );
  }

  Widget _gradeChoice(String g) {
    final on = _grade == g;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _grade = g),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.blue700 : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
                color: on ? AppColors.blue700 : AppColors.borderStrong, width: 1.4),
          ),
          child: Text(g,
              style: AppText.bodySm().copyWith(
                  fontWeight: FontWeight.w600,
                  color: on ? Colors.white : AppColors.fg2)),
        ),
      ),
    );
  }

  Widget _freqChoice(StandingFrequency f) {
    final on = _freq == f;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _freq = f),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.blue700 : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
                color: on ? AppColors.blue700 : AppColors.borderStrong, width: 1.4),
          ),
          child: Text(f.label,
              style: AppText.bodySm().copyWith(
                  fontWeight: FontWeight.w600,
                  color: on ? Colors.white : AppColors.fg2)),
        ),
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderStrong, width: 1.5),
        ),
        child: Icon(icon, size: 20, color: AppColors.blue700),
      ),
    );
  }

  Widget _maxPriceCard() {
    return B2bCard(
      padding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Skip dispatch if price is too high',
                    style: AppText.bodySm().copyWith(
                        color: AppColors.fg1, fontWeight: FontWeight.w600)),
              ),
              Switch(
                value: _maxPriceOn,
                activeThumbColor: AppColors.blue700,
                onChanged: (v) => setState(() => _maxPriceOn = v),
              ),
            ],
          ),
          if (_maxPriceOn)
            Row(
              children: [
                Text('Max ₹${_maxPrice.toStringAsFixed(0)}/${_crop.unit}',
                    style: AppText.bodySm().copyWith(color: AppColors.fg2)),
                Expanded(
                  child: Slider(
                    value: _maxPrice,
                    min: 10,
                    max: 600,
                    activeColor: AppColors.blue700,
                    onChanged: (v) => setState(() => _maxPrice = v),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _startDateCard() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
        );
        if (picked != null) setState(() => _startDate = picked);
      },
      child: B2bCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.event_outlined, size: 20, color: AppColors.blue700),
            const SizedBox(width: 12),
            Text('Start date',
                style: AppText.body().copyWith(color: AppColors.fg2)),
            const Spacer(),
            Text('${_startDate.day}/${_startDate.month}/${_startDate.year}',
                style: AppText.body().copyWith(
                    color: AppColors.fg1, fontWeight: FontWeight.w600)),
            const Icon(Icons.chevron_right, color: AppColors.fg3),
          ],
        ),
      ),
    );
  }

  Widget _estimateCard(int lo, int hi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue700, AppColors.blue900],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ESTIMATED MONTHLY SPEND',
              style: AppText.overline().copyWith(color: AppColors.blue300)),
          const SizedBox(height: 6),
          Text('₹${b2bInr(lo)} – ₹${b2bInr(hi)}',
              style: AppText.displayNum(26, color: Colors.white)),
          const SizedBox(height: 4),
          Text('${_freq.label} · $_qty ${_crop.unit} per dispatch',
              style: AppText.bodySm().copyWith(color: AppColors.blue300)),
        ],
      ),
    );
  }
}
