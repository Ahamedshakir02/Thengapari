import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Homeowner earnings bar chart — shows N weeks of earnings as bars. The
/// current (last) week bar is highlighted in [AgriColors.green400] with its
/// value labelled above it. Render at ~85px height.
class WeeklyEarningsChartPainter extends CustomPainter {
  final List<double> weeklyEarnings; // e.g. [2100, 2800, 1900, 3200, 4100, 4280]

  const WeeklyEarningsChartPainter({required this.weeklyEarnings});

  @override
  void paint(Canvas canvas, Size size) {
    if (weeklyEarnings.isEmpty) return;
    final maxVal = weeklyEarnings.reduce((a, b) => a > b ? a : b);
    if (maxVal <= 0) return;
    final chartH = size.height - 20; // leave 20px for x-axis labels
    final barUnit = size.width / weeklyEarnings.length;
    final barW = barUnit * 0.55;

    final basePaint = Paint()..color = AgriColors.green100;
    final activePaint = Paint()..color = AgriColors.green400;
    final baselinePaint = Paint()
      ..color = AgriColors.border
      ..strokeWidth = 0.5;

    // Baseline
    canvas.drawLine(
      Offset(0, chartH),
      Offset(size.width, chartH),
      baselinePaint,
    );

    for (int i = 0; i < weeklyEarnings.length; i++) {
      final barH = (weeklyEarnings[i] / maxVal) * chartH * 0.92;
      final x = i * barUnit + (barUnit - barW) / 2;
      final y = chartH - barH;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, barW, barH),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        i == weeklyEarnings.length - 1 ? activePaint : basePaint,
      );

      // X-axis week label
      final label = TextPainter(
        text: TextSpan(
          text: 'W${i + 1}',
          style: const TextStyle(fontSize: 9, color: Color(0xFF888888)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(x + barW / 2 - label.width / 2, chartH + 4));

      // Value label above current week bar only
      if (i == weeklyEarnings.length - 1) {
        final valLabel = TextPainter(
          text: TextSpan(
            text: '₹${(weeklyEarnings[i] / 1000).toStringAsFixed(1)}k',
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF3B6D11),
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        valLabel.paint(
            canvas, Offset(x + barW / 2 - valLabel.width / 2, y - 13));
      }
    }
  }

  @override
  bool shouldRepaint(WeeklyEarningsChartPainter old) =>
      old.weeklyEarnings != weeklyEarnings;
}
