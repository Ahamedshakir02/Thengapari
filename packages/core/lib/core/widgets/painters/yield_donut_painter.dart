import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Site-manager crop-grade donut. Renders the Grade A / B / Tender split for
/// the current harvest with `canvas.drawArc`, the total unit count in the
/// center, and a legend on the right. Matches the site manager yield donut.
/// Render at ~120px height.
class YieldDonutPainter extends CustomPainter {
  final int gradeA;
  final int gradeB;
  final int tender;

  const YieldDonutPainter({
    required this.gradeA,
    required this.gradeB,
    required this.tender,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = gradeA + gradeB + tender;
    if (total == 0) return;

    final cx = size.width * 0.35;
    final cy = size.height / 2;
    final outerR = size.height * 0.42;
    final strokeW = outerR * 0.40;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: outerR);

    final segments = [
      _Segment(gradeA / total, AgriColors.green400),
      _Segment(gradeB / total, AgriColors.green100),
      _Segment(tender / total, const Color(0xFFDDEFD0)),
    ];

    double startAngle = -math.pi / 2; // start at top
    for (final seg in segments) {
      final sweep = seg.fraction * 2 * math.pi;
      canvas.drawArc(
        rect,
        startAngle,
        sweep - 0.02,
        false,
        Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep;
    }

    // Center text: total count
    _drawCenteredText(canvas, Offset(cx, cy - 9), '$total',
        const Color(0xFF173404), 22, FontWeight.w500);
    _drawCenteredText(canvas, Offset(cx, cy + 11), 'units',
        const Color(0xFF888888), 11, FontWeight.w400);

    // Legend (right side)
    final legendItems = [
      ('Grade A', '$gradeA units', AgriColors.green400),
      ('Grade B', '$gradeB units', AgriColors.green100),
      ('Tender', '$tender units', const Color(0xFFDDEFD0)),
    ];
    final lx = size.width * 0.58;
    for (int i = 0; i < legendItems.length; i++) {
      final ly = cy - 22.0 + i * 22.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(lx, ly, 10, 10), const Radius.circular(2)),
        Paint()..color = legendItems[i].$3,
      );
      _drawText(canvas, Offset(lx + 14, ly - 1), legendItems[i].$1,
          const Color(0xFF444441), 11, FontWeight.w500);
      _drawText(canvas, Offset(lx + 14, ly + 12), legendItems[i].$2,
          const Color(0xFF888888), 10, FontWeight.w400);
    }
  }

  void _drawCenteredText(Canvas canvas, Offset center, String text, Color color,
      double size, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style:
              TextStyle(fontSize: size, color: color, fontWeight: weight)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawText(Canvas canvas, Offset pos, String text, Color color,
      double size, FontWeight weight) {
    (TextPainter(
      text: TextSpan(
          text: text,
          style:
              TextStyle(fontSize: size, color: color, fontWeight: weight)),
      textDirection: TextDirection.ltr,
    )..layout())
        .paint(canvas, pos);
  }

  @override
  bool shouldRepaint(YieldDonutPainter old) =>
      old.gradeA != gradeA || old.gradeB != gradeB || old.tender != tender;
}

class _Segment {
  final double fraction;
  final Color color;
  _Segment(this.fraction, this.color);
}
