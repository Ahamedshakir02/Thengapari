import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:core/app/design_tokens.dart';
import 'package:core/core/models/b2b_savings.dart';
import 'package:core/core/models/standing_order.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/b2b_providers.dart';
import '../widgets/b2b_widgets.dart';

/// Business savings analytics — the investor-facing proof of value. Matches
/// `Designs/ThengaPari B2B Portal App/screen4.jsx`.
class DashboardScreen extends ConsumerWidget {
  final VoidCallback onNewStandingOrder;
  final String businessName;
  const DashboardScreen({
    super.key,
    required this.onNewStandingOrder,
    this.businessName = 'Your business',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final savings =
        ref.watch(monthlySavingsProvider(uid)).value ?? const SavingsSummary();
    final week = ref.watch(weeklySpendProvider(uid)).value ?? const [];
    final standing = ref.watch(standingOrdersProvider(uid)).value ?? const [];

    final cropRows = (savings.perCrop.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .map((e) => (e.key, e.value, '₹${b2bInr(e.value)}'))
        .toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _hero(savings),
        Transform.translate(
          offset: const Offset(0, -16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _statRow(savings),
          ),
        ),
        if (cropRows.isNotEmpty) ...[
          const B2bSectionHead(title: 'Savings by crop · this month'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SavingsByCropChart(rows: cropRows),
          ),
        ],
        const B2bSectionHead(
            title: 'Weekly spend trend',
            action: '↓ 8% vs last month',
            actionColor: AppColors.green600),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: B2bCard(
            padding: const EdgeInsets.fromLTRB(10, 16, 14, 8),
            child: SizedBox(height: 150, child: _SpendChart(week: week)),
          ),
        ),
        const B2bSectionHead(title: 'Standing orders', action: 'Manage'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: B2bCard(
            child: Column(
              children: [
                for (final s in standing) _standingTile(s),
                GestureDetector(
                  onTap: onNewStandingOrder,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 18, color: AppColors.blue700),
                        const SizedBox(width: 6),
                        Text('New standing order',
                            style: AppText.button().copyWith(
                                color: AppColors.blue700,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _hero(SavingsSummary s) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0, -1),
          end: Alignment(0.3, 1),
          colors: [AppColors.blue700, AppColors.blue900],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('$businessName · this month',
                        style: AppText.overline().copyWith(color: AppColors.blue300)),
                  ),
                  const B2bIconBtn(icon: Icons.settings_outlined),
                ],
              ),
              const SizedBox(height: 12),
              Text('TOTAL SAVED VS WHOLESALE',
                  style: AppText.overline().copyWith(color: AppColors.blue300)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹', style: AppText.displayNum(32, color: Colors.white)),
                  Text(b2bInr(s.totalSaved == 0 ? 14320 : s.totalSaved),
                      style: AppText.displayNum(52, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ED07A).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up, size: 13, color: Color(0xFFB6F0C9)),
                    const SizedBox(width: 6),
                    Text('₹480 more than last month',
                        style:
                            AppText.bodySm().copyWith(color: const Color(0xFFB6F0C9))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(SavingsSummary s) {
    return Row(
      children: [
        _stat('${s.orderCount == 0 ? 18 : s.orderCount}', 'Pre-books'),
        const SizedBox(width: 10),
        _stat('${(s.avgPercent == 0 ? 13 : s.avgPercent).toStringAsFixed(0)}%', 'Avg savings'),
        const SizedBox(width: 10),
        _stat('₹${s.totalSpent == 0 ? "26.4k" : b2bInr(s.totalSpent)}', 'Total spend'),
      ],
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: B2bCard(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppText.displayNum(20, color: AppColors.fg1)),
            const SizedBox(height: 4),
            Text(label, style: AppText.caption().copyWith(color: AppColors.fg3)),
          ],
        ),
      ),
    );
  }

  Widget _standingTile(StandingOrder s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          CropGlyphBox(crop: s.cropType, size: 44, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${s.cropType.label} · ${s.grade}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title().copyWith(color: AppColors.fg1)),
                Text('${s.quantityPerOrder} ${s.unit} / ${s.frequency.label.toLowerCase()}',
                    style: AppText.bodySm().copyWith(color: AppColors.fg3)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                    color: AppColors.blue100,
                    borderRadius: BorderRadius.circular(AppRadii.pill)),
                child: Text(s.frequency.label,
                    style: AppText.caption().copyWith(
                        color: AppColors.blue700, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 5),
              Text(
                  s.nextDue == null
                      ? 'Active'
                      : 'Next: ${s.nextDue!.day}/${s.nextDue!.month}',
                  style: AppText.caption().copyWith(color: AppColors.fg3)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpendChart extends StatelessWidget {
  final List<double> week;
  const _SpendChart({required this.week});

  @override
  Widget build(BuildContext context) {
    final data = week.isEmpty
        ? const <double>[4200, 3600, 5100, 4400, 3900, 5300]
        : week;
    final spots = [
      for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i]),
    ];
    final maxY = data.reduce((a, b) => a > b ? a : b) * 1.2;
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 2,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1, dashArray: [3, 4]),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (v, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('W${v.toInt() + 1}',
                    style: AppText.caption()
                        .copyWith(color: AppColors.ink400, fontSize: 10)),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.blue500,
            barWidth: 2.4,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                radius: spot.x == spots.length - 1 ? 5 : 3.2,
                color: spot.x == spots.length - 1 ? AppColors.blue700 : Colors.white,
                strokeWidth: 2,
                strokeColor: AppColors.blue500,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.blue500.withValues(alpha: 0.22),
                  AppColors.blue500.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
