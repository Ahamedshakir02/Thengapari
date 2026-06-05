import 'package:flutter/material.dart';

/// Homeowner hero illustration — a Kerala residential scene with a coconut
/// palm, mango tree and house. Colors are hardcoded (a physical scene, so it
/// deliberately does NOT follow the theme), matching the hero illustration in
/// the homeowner designs.
///
/// Render at ~140px height: `CustomPaint(painter: KeralaLandscapePainter(),
/// child: SizedBox(width: double.infinity, height: 140))`.
class KeralaLandscapePainter extends CustomPainter {
  const KeralaLandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height; // target: 140px height

    // Sky background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFDDEFD0),
    );

    // Sun
    canvas.drawCircle(
      Offset(w * 0.87, h * 0.22),
      h * 0.15,
      Paint()..color = const Color(0xFFFAC775),
    );

    // Back hill — lighter green
    final backHill = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.25, h * 0.50, w * 0.5, h * 0.64)
      ..quadraticBezierTo(w * 0.75, h * 0.78, w, h * 0.57)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(backHill, Paint()..color = const Color(0xFF97C459));

    // Front hill — darker green
    final frontHill = Path()
      ..moveTo(0, h * 0.86)
      ..quadraticBezierTo(w * 0.33, h * 0.70, w * 0.66, h * 0.82)
      ..quadraticBezierTo(w * 0.83, h * 0.90, w, h * 0.75)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(frontHill, Paint()..color = const Color(0xFF3B6D11));

    // Ground flat strip
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.90, w, h * 0.10),
      Paint()..color = const Color(0xFF27500A),
    );

    _drawHouse(canvas, size);
    _drawCoconutPalm(canvas, size);
    _drawMangoTree(canvas, size);
  }

  void _drawHouse(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hx = w * 0.43; // house left x
    final hy = h * 0.46; // house top y
    final hw = w * 0.20; // house width
    final hh = h * 0.38; // house height

    // Wall
    canvas.drawRect(
      Rect.fromLTWH(hx, hy, hw, hh),
      Paint()..color = const Color(0xFFF1EFE8),
    );
    // Roof
    final roofPath = Path()
      ..moveTo(hx - w * 0.02, hy)
      ..lineTo(hx + hw + w * 0.02, hy)
      ..lineTo(hx + hw / 2, hy - h * 0.18)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = const Color(0xFF993C1D));

    // Door
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hx + hw * 0.38, hy + hh * 0.52, hw * 0.24, hh * 0.48),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF712B13),
    );
    // Windows
    for (final wx in [hx + hw * 0.08, hx + hw * 0.68]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(wx, hy + hh * 0.16, hw * 0.20, hh * 0.20),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF85B7EB),
      );
    }
  }

  void _drawCoconutPalm(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final tx = w * 0.20; // trunk center x
    final ty = h * 0.85; // trunk base y

    // Trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tx - 3, ty - h * 0.52, 6, h * 0.52),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF633806),
    );

    // Fronds
    final frondPaint = Paint()
      ..color = const Color(0xFF3B6D11)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final frondTip = Offset(tx, ty - h * 0.52);
    final fronds = [
      Offset(tx - w * 0.14, frondTip.dy - h * 0.08),
      Offset(tx - w * 0.08, frondTip.dy - h * 0.18),
      Offset(tx + w * 0.10, frondTip.dy - h * 0.12),
      Offset(tx + w * 0.14, frondTip.dy - h * 0.04),
      Offset(tx + w * 0.04, frondTip.dy - h * 0.20),
    ];
    for (final tip in fronds) {
      canvas.drawLine(frondTip, tip, frondPaint);
    }

    // Coconuts cluster
    final coconutPaint = Paint()..color = const Color(0xFF854F0B);
    canvas.drawCircle(Offset(tx - 4, frondTip.dy + 6), 5, coconutPaint);
    canvas.drawCircle(Offset(tx + 4, frondTip.dy + 4), 5,
        Paint()..color = const Color(0xFF633806));
  }

  void _drawMangoTree(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final tx = w * 0.79; // trunk center

    // Trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tx - 3, h * 0.60, 7, h * 0.28),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF633806),
    );

    // Canopy layers (back to front)
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(tx, h * 0.46), width: w * 0.20, height: h * 0.22),
        Paint()..color = const Color(0xFF27500A));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(tx - w * 0.06, h * 0.50),
            width: w * 0.14,
            height: h * 0.18),
        Paint()..color = const Color(0xFF3B6D11));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(tx + w * 0.06, h * 0.50),
            width: w * 0.14,
            height: h * 0.18),
        Paint()..color = const Color(0xFF3B6D11));

    // Mangoes
    final mangoPaint = Paint()..color = const Color(0xFFEF9F27);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(tx - 6, h * 0.57), width: 10, height: 14),
        mangoPaint);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(tx + 8, h * 0.55), width: 10, height: 14),
        Paint()..color = const Color(0xFFBA7517));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
