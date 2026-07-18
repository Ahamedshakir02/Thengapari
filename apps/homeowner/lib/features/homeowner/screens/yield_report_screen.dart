import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:core/app/design_tokens.dart';
import 'package:core/core/models/harvest_job.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/homeowner_providers.dart';
import 'package:core/core/widgets/app_icon.dart';

/// Post-harvest yield report — grade-breakdown donut, byproduct routing card,
/// earnings breakdown, and WhatsApp share. Matches `ReportScreen` in
/// app-screens-report.jsx / `app.css`.
class YieldReportScreen extends ConsumerWidget {
  const YieldReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final jobAsync = ref.watch(latestCompletedJobProvider(uid));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Yield report'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.fromLTRB(9, 5, 11, 5),
                decoration: BoxDecoration(
                  color: AppColors.statusCompleteBg,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon('check',
                        size: 13,
                        color: AppColors.statusCompleteFg,
                        strokeWidth: 2.4),
                    const SizedBox(width: 5),
                    Text('Completed',
                        style: AppText.caption().copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.statusCompleteFg)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: jobAsync.when(
        data: (job) => job == null ? const _Empty() : _Report(job: job),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _Empty(),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon('report', size: 44, color: AppColors.brand),
            const SizedBox(height: 12),
            Text('No completed harvest yet',
                style: AppText.title(), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Your yield report appears here once a harvest is done.',
                style: AppText.bodySm().copyWith(color: AppColors.fg3),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _Report extends StatelessWidget {
  final HarvestJob job;
  const _Report({required this.job});

  Future<void> _share() async {
    final a = job.gradeA ?? 0, b = job.gradeB ?? 0, t = job.tender ?? 0;
    final net = (job.earningsAmount ?? 0) +
        (job.byproductCredit ?? 0) -
        (job.feeAmount ?? 0);
    final crops = job.cropTypes
        .map((c) => c.isEmpty ? c : '${c[0].toUpperCase()}${c.substring(1)}')
        .join(' + ');
    final text = 'ThengaPari — harvest report\n'
        '$crops harvest · ${a + b + t} units\n'
        'Grade A: $a · Grade B: $b · Tender: $t\n'
        'Net payout: ₹${net.toStringAsFixed(0)}';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final a = job.gradeA ?? 0, b = job.gradeB ?? 0, t = job.tender ?? 0;
    final total = a + b + t;
    final harvestValue = job.earningsAmount ?? 0;
    final fee = job.feeAmount ?? 0;
    final byproduct = job.byproductCredit;
    final net = harvestValue + (byproduct ?? 0) - fee;

    final segs = [
      (label: 'Grade A', value: a, color: AppColors.brand),
      (label: 'Grade B', value: b, color: AppColors.greenSage500),
      (label: 'Tender', value: t, color: AppColors.accent),
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter, 8, AppSpace.gutter, 12),
            children: [
              // Grade breakdown
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Grade breakdown', style: AppText.title()),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: 156,
                        height: 156,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(156, 156),
                              painter: _GradeDonutPainter([
                                for (final s in segs)
                                  (s.value.toDouble(), s.color)
                              ]),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$total', style: AppText.displayNum(26)),
                                Text('total nuts',
                                    style: AppText.caption()
                                        .copyWith(fontSize: 11.5)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final s in segs) ...[
                      _legendRow(s.label, s.value, total, s.color),
                      if (s.label != 'Tender') const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Byproduct routing
              Container(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
                decoration: BoxDecoration(
                  color: AppColors.amber100,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: AppColors.amber200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.amber400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppIcon('recycle',
                          size: 22, color: AppColors.greenForest900),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Husk & fronds routed to coir unit',
                              style: AppText.bodySm().copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.statusInprogressFg)),
                          const SizedBox(height: 2),
                          Text('Nothing wasted — you earn a little extra on byproduct.',
                              style: AppText.caption()
                                  .copyWith(color: AppColors.ink700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Earnings breakdown
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Earnings breakdown', style: AppText.title()),
                    const SizedBox(height: 4),
                    _breakdownRow('coconut', 'Harvest value',
                        '₹${harvestValue.toStringAsFixed(0)}', AppColors.fg1),
                    if (byproduct != null)
                      _breakdownRow('recycle', 'Byproduct credit',
                          '+₹${byproduct.toStringAsFixed(0)}', AppColors.green600),
                    _breakdownRow('wallet', 'Service fee',
                        '−₹${fee.toStringAsFixed(0)}', AppColors.statusErrorFg,
                        last: true),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Net payout', style: AppText.title()),
                              const SizedBox(height: 2),
                              Text('Paid to your UPI',
                                  style: AppText.caption()
                                      .copyWith(fontSize: 12.5)),
                            ],
                          ),
                        ),
                        Text('₹${net.toStringAsFixed(0)}',
                            style: AppText.displayNum(24,
                                color: AppColors.brandInk)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // WhatsApp share
        Container(
          padding: EdgeInsets.fromLTRB(AppSpace.gutter, 12, AppSpace.gutter,
              12 + MediaQuery.of(context).padding.bottom),
          child: GestureDetector(
            onTap: _share,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x5225D366),
                      blurRadius: 18,
                      offset: Offset(0, 6))
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppIcon('whatsapp', size: 20, color: Colors.white),
                  const SizedBox(width: 9),
                  Text('Share on WhatsApp',
                      style: AppText.button().copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: child,
      );

  Widget _legendRow(String name, int value, int total, Color color) {
    final pct = total == 0 ? 0 : (value / total * 100).round();
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(name,
              style: AppText.bodySm().copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.fg1)),
        ),
        Text('$pct%', style: AppText.caption().copyWith(fontSize: 12.5)),
        const SizedBox(width: 12),
        Text('$value',
            style: AppText.bodySm().copyWith(
                fontWeight: FontWeight.w700, color: AppColors.fg1)),
      ],
    );
  }

  Widget _breakdownRow(String icon, String label, String value, Color valueColor,
      {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          AppIcon(icon, size: 18, color: AppColors.fg3),
          const SizedBox(width: 9),
          Expanded(
            child: Text(label,
                style: AppText.bodySm().copyWith(color: AppColors.fg2)),
          ),
          Text(value,
              style: AppText.bodySm().copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor)),
        ],
      ),
    );
  }
}

class _GradeDonutPainter extends CustomPainter {
  final List<(double, Color)> segs;
  const _GradeDonutPainter(this.segs);

  @override
  void paint(Canvas canvas, Size size) {
    final total = segs.fold<double>(0, (s, e) => s + e.$1);
    if (total <= 0) return;
    final rect = Rect.fromLTWH(12, 12, size.width - 24, size.height - 24);
    const thick = 24.0;
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = AppColors.surfaceSunk
        ..style = PaintingStyle.stroke
        ..strokeWidth = thick,
    );
    double start = -math.pi / 2;
    for (final (value, color) in segs) {
      if (value <= 0) continue;
      final sweep = value / total * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep - 0.04,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = thick
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_GradeDonutPainter old) => old.segs != segs;
}
