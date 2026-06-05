import 'package:flutter/material.dart';

/// Worker job-ping proximity map. Concentric distance rings, the worker at
/// center, dimmed nearby workers, and an incoming job-ping dot whose pulse
/// ring is driven by [pingAnimValue] (0.0 → 1.0). Matches the worker design's
/// radar/ping screen. Render over a dark teal background (e.g. 0xFF0F6E56).
class RadarMapPainter extends CustomPainter {
  final double pingAnimValue; // 0.0 → 1.0, drives the pulse ring animation

  const RadarMapPainter({required this.pingAnimValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Distance rings: 1km, 3km, 5km
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (final r in [size.width * 0.18, size.width * 0.36, size.width * 0.48]) {
      canvas.drawCircle(Offset(cx, cy), r, ringPaint);
    }

    // Crosshair lines
    final crossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), crossPaint);
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), crossPaint);

    // Ring distance labels
    _drawLabel(canvas, '1 km', Offset(cx + size.width * 0.19, cy - 10),
        Colors.white.withValues(alpha: 0.35), 9);
    _drawLabel(canvas, '3 km', Offset(cx + size.width * 0.37, cy - 10),
        Colors.white.withValues(alpha: 0.35), 9);

    // Other available workers (dimmed teal dots)
    final otherWorkerPaint = Paint()
      ..color = const Color(0xFF5DCAA5).withValues(alpha: 0.6);
    for (final pos in [
      Offset(cx - size.width * 0.28, cy + size.height * 0.16),
      Offset(cx + size.width * 0.24, cy + size.height * 0.22),
      Offset(cx - size.width * 0.18, cy - size.height * 0.18),
    ]) {
      canvas.drawCircle(pos, 5, otherWorkerPaint);
    }

    // Job ping location — animated pulse rings
    final jobPos = Offset(cx + size.width * 0.25, cy - size.height * 0.18);
    final pulseR = 10.0 + pingAnimValue * 18.0;
    canvas.drawCircle(
      jobPos,
      pulseR,
      Paint()
        ..color =
            const Color(0xFFFAC775).withValues(alpha: 1.0 - pingAnimValue * 0.8),
    );
    canvas.drawCircle(jobPos, 9, Paint()..color = const Color(0xFFFAC775));
    canvas.drawCircle(jobPos, 5, Paint()..color = const Color(0xFF633806));

    // Job ping label
    _drawLabel(canvas, 'Job ping', Offset(jobPos.dx - 18, jobPos.dy - 22),
        const Color(0xFFFAC775), 10);

    // Worker dot at center (you)
    canvas.drawCircle(Offset(cx, cy), 8,
        Paint()..color = Colors.white.withValues(alpha: 0.95));
    canvas.drawCircle(
        Offset(cx, cy), 4, Paint()..color = const Color(0xFF0F6E56));
    _drawLabel(canvas, 'You', Offset(cx - 8, cy + 12),
        Colors.white.withValues(alpha: 0.6), 9);

    // Distance line from center to job ping
    canvas.drawLine(
      Offset(cx, cy),
      jobPos,
      Paint()
        ..color = const Color(0xFFFAC775).withValues(alpha: 0.4)
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawLabel(
      Canvas canvas, String text, Offset pos, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(RadarMapPainter old) => old.pingAnimValue != pingAnimValue;
}
