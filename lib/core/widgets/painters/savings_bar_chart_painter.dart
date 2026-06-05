import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// B2B savings-per-crop bar chart — the percentage saved vs. wholesale for
/// each crop. The tallest bar (best saving) is rendered in
/// [AgriColors.green400]; others in [AgriColors.green100]. Dashed reference
/// lines mark 10% and 20%. Render at ~95px height.
class SavingsBarChartPainter extends CustomPainter {
  final Map<String, double> savingsPercent;
  // e.g. {'Coconut': 14, 'Mango': 10, 'Pepper': 8, 'Jackfruit': 20}

  const SavingsBarChartPainter({required this.savingsPercent});

  @override
  void paint(Canvas canvas, Size size) {
    final entries = savingsPercent.entries.toList();
    if (entries.isEmpty) return;
    final maxVal = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (maxVal <= 0) return;
    final chartH = size.height - 22;
    final barUnit = (size.width - 30) / entries.length;
    final barW = barUnit * 0.55;

    // Dashed reference lines at 10% and 20%
    final dashPaint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..strokeWidth = 0.5;
    for (final pct in [10.0, 20.0]) {
      final y = chartH - (pct / maxVal) * chartH * 0.9;
      _drawDashedLine(canvas, Offset(28, y), Offset(size.width, y), dashPaint);
      (TextPainter(
        text: TextSpan(
            text: '${pct.toInt()}%',
            style: const TextStyle(fontSize: 9, color: Color(0xFFAAAAAA))),
        textDirection: TextDirection.ltr,
      )..layout())
          .paint(canvas, Offset(0, y - 6));
    }

    for (int i = 0; i < entries.length; i++) {
      final val = entries[i].value;
      final barH = (val / maxVal) * chartH * 0.9;
      final x = 30 + i * barUnit + (barUnit - barW) / 2;
      final y = chartH - barH;
      final isMax = val == maxVal;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, barW, barH),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        Paint()..color = isMax ? AgriColors.green400 : AgriColors.green100,
      );

      // Percentage label above bar
      (TextPainter(
        text: TextSpan(
          text: '${val.toInt()}%',
          style: TextStyle(
            fontSize: 9,
            color: isMax ? const Color(0xFF3B6D11) : const Color(0xFF888888),
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout())
          .paint(canvas, Offset(x + barW / 2 - 8, y - 13));

      // Crop name label
      (TextPainter(
        text: TextSpan(
            text: entries[i].key,
            style: const TextStyle(fontSize: 8, color: Color(0xFF888888))),
        textDirection: TextDirection.ltr,
      )..layout())
          .paint(canvas, Offset(x - 2, chartH + 4));
    }

    // Baseline
    canvas.drawLine(Offset(28, chartH), Offset(size.width, chartH),
        Paint()
          ..color = const Color(0xFFEEEEEE)
          ..strokeWidth = 0.5);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLen = 4.0;
    const gapLen = 3.0;
    double x = start.dx;
    while (x < end.dx) {
      canvas.drawLine(Offset(x, start.dy),
          Offset((x + dashLen).clamp(start.dx, end.dx), end.dy), paint);
      x += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(SavingsBarChartPainter old) =>
      old.savingsPercent != savingsPercent;
}
