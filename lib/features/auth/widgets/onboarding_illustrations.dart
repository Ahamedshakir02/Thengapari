import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Onboarding illustrations — a faithful Flutter port of the design's flat
/// (`painterly: false`) geometric SVGs in
/// `Designs/ThengaPari Auth Flow/auth/illustrations.jsx`.
///
/// Each slide is drawn against the original `0 0 340 300` viewBox and scaled to
/// fit (contain) the available box, so geometry, colours and proportions match
/// the source exactly. Colours come straight from the design palette `C`.
class OnboardingIllustration extends StatelessWidget {
  /// 0 = income, 1 = flow, 2 = report.
  final int index;
  const OnboardingIllustration({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    final painter = switch (index) {
      0 => const _IncomePainter(),
      1 => const _FlowPainter(),
      _ => const _ReportPainter(),
    };
    return CustomPaint(painter: painter, size: Size.infinite);
  }
}

// ── Design palette (from illustrations.jsx `C`) ──────────────────────────────
class _C {
  _C._();
  static const sky1 = Color(0xFFF1F6E9);
  static const hill1 = Color(0xFFBCD6A3);
  static const hill2 = Color(0xFF94B97F);
  static const grass = Color(0xFF6E9E5E);
  static const forest = Color(0xFF1E4D2B);
  static const forest2 = Color(0xFF2E6B3E);
  static const forest3 = Color(0xFF357A47);
  static const sage = Color(0xFF256038);
  static const trunk = Color(0xFF8B6239);
  static const trunkHi = Color(0xFFA9794C);
  static const trunkDk = Color(0xFF6E4326);
  static const trunkSeed = Color(0xFF7A4A2B);
  static const sun = Color(0xFFF4A52A);
  static const sun2 = Color(0xFFFBDFA6);
  static const saffron = Color(0xFFE89318);
  static const amber = Color(0xFFFBBA4D);
  static const roof2 = Color(0xFFA94F2E);
  static const ink2 = Color(0xFF4A4840);
  static const mist = Color(0xFFC9C5B6);
  static const paper = Color(0xFFFFFFFF);
  static const leaf = Color(0xFFE6EFD9);
  static const leaf2 = Color(0xFFCFE0BC);
  static const rupeeIncome = Color(0xFF85542F);
  static const rupeeBasket = Color(0xFF7A4A2B);
}

Paint _fill(Color c, {double opacity = 1}) => Paint()
  ..color = c.withValues(alpha: opacity)
  ..style = PaintingStyle.fill
  ..isAntiAlias = true;

Paint _stroke(Color c,
        {double width = 1,
        double opacity = 1,
        StrokeCap cap = StrokeCap.butt,
        StrokeJoin join = StrokeJoin.miter}) =>
    Paint()
      ..color = c.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = cap
      ..strokeJoin = join
      ..isAntiAlias = true;

void _path(Canvas c, String d, Paint p) => c.drawPath(parseSvgPath(d), p);

/// Scales the canvas so the `0 0 340 300` design viewBox is "contain"-fit and
/// centred in [size], then runs [draw] in design coordinates.
void _withViewBox(Canvas canvas, Size size, void Function(Canvas) draw) {
  const vbW = 340.0, vbH = 300.0;
  final scale = math.min(size.width / vbW, size.height / vbH);
  final dx = (size.width - vbW * scale) / 2;
  final dy = (size.height - vbH * scale) / 2;
  canvas.save();
  canvas.translate(dx, dy);
  canvas.scale(scale);
  draw(canvas);
  canvas.restore();
}

// ── Shared sub-illustrations (Palm / Ground / Coin) ──────────────────────────

void _drawPalm(Canvas c, double x, double y, {double s = 1, bool climber = false}) {
  c.save();
  c.translate(x, y);
  c.scale(s);
  // curved trunk
  _path(c, 'M-7 0 C-12 -40 -10 -78 4 -110 L16 -106 C2 -76 0 -40 7 0 Z', _fill(_C.trunk));
  _path(c, 'M-3 -8 C-6 -40 -5 -72 6 -100',
      _stroke(_C.trunkDk, width: 2.4, opacity: 0.5));
  // coconuts
  c.drawCircle(const Offset(2, -112), 7, _fill(_C.trunkDk));
  c.drawCircle(const Offset(16, -110), 7, _fill(_C.trunkDk));
  c.drawCircle(const Offset(9, -120), 6.5, _fill(_C.trunkSeed));
  // fronds — back layer
  final back = _fill(_C.forest);
  _path(c, 'M9 -118 C-34 -132 -74 -120 -100 -92 C-62 -100 -22 -110 9 -116 Z', back);
  _path(c, 'M9 -118 C52 -132 92 -120 118 -92 C80 -100 40 -110 9 -116 Z', back);
  // fronds — front layer
  final front = _fill(_C.forest2);
  _path(c, 'M9 -120 C-22 -156 -52 -180 -54 -214 C-30 -186 0 -154 12 -122 Z', front);
  _path(c, 'M9 -120 C40 -156 70 -180 72 -214 C48 -186 18 -154 6 -122 Z', front);
  _path(c, 'M9 -120 C-12 -150 -42 -168 -72 -170 C-44 -150 -14 -132 10 -124 Z', front);
  _path(c, 'M9 -120 C30 -150 60 -168 90 -170 C62 -150 32 -132 8 -124 Z', front);
  if (climber) {
    c.save();
    c.translate(-2, -58);
    c.drawCircle(const Offset(0, -8), 6.5, _fill(_C.ink2));
    _path(c, 'M-5 -2 q5 -3 10 0 l-1 18 q-4 3 -8 0 Z', _fill(_C.forest2));
    _path(c, 'M5 2 q10 -6 14 -18 M-5 2 q-9 -5 -12 -16',
        _stroke(_C.ink2, width: 3, cap: StrokeCap.round));
    _path(c, 'M3 16 q9 6 11 18 M-3 16 q-8 6 -10 18',
        _stroke(_C.ink2, width: 3, cap: StrokeCap.round));
    c.restore();
  }
  c.restore();
}

void _drawGround(Canvas c, {double y = 250}) {
  _path(c,
      'M-10 $y Q120 ${y - 26} 250 ${y - 8} T360 ${y - 12} L360 300 L-10 300 Z',
      _fill(_C.hill1));
  _path(c,
      'M-10 ${y + 18} Q160 ${y - 6} 320 ${y + 14} T360 ${y + 8} L360 300 L-10 300 Z',
      _fill(_C.hill2));
  c.drawRect(Rect.fromLTWH(-10, y + 34, 360, 300 - (y + 34)), _fill(_C.grass));
}

void _drawCoin(Canvas c, double x, double y, {double r = 15, double rot = 0}) {
  c.save();
  c.translate(x, y);
  c.rotate(rot * math.pi / 180);
  c.drawCircle(Offset.zero, r, _fill(_C.sun));
  c.drawCircle(Offset.zero, r, _stroke(_C.saffron, width: 2.4));
  c.drawCircle(Offset.zero, r - 5, _stroke(_C.saffron, width: 1.4, opacity: 0.7));
  // rupee glyph (ported relative path)
  final rupee =
      'M${-r * 0.32} ${-r * 0.42} h${r * 0.62} M${-r * 0.32} ${-r * 0.08} h${r * 0.62} '
      'M${-r * 0.16} ${-r * 0.42} c${r * 0.5} 0 ${r * 0.5} ${r * 0.46} 0 ${r * 0.46} '
      'h${-r * 0.16} l${r * 0.5} ${r * 0.5}';
  _path(c, rupee,
      _stroke(_C.roof2, width: 2.2, cap: StrokeCap.round, join: StrokeJoin.round));
  c.restore();
}

void _drawText(
  Canvas c,
  String text,
  Offset at, {
  required double size,
  required Color color,
  required FontWeight weight,
  bool display = false,
  TextAlign align = TextAlign.left,
}) {
  final style = display
      ? GoogleFonts.balooChettan2(fontSize: size, fontWeight: weight, color: color)
      : GoogleFonts.notoSans(fontSize: size, fontWeight: weight, color: color);
  final tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textAlign: align,
  )..layout();
  // SVG `y` is the text baseline; Flutter draws from the top-left. Shift up by
  // the font ascent and apply horizontal anchoring.
  final dy = at.dy - tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  double dx = at.dx;
  if (align == TextAlign.center) dx -= tp.width / 2;
  if (align == TextAlign.right) dx -= tp.width;
  tp.paint(c, Offset(dx, dy));
}

// ── Slide 1 — income ─────────────────────────────────────────────────────────
class _IncomePainter extends CustomPainter {
  const _IncomePainter();

  @override
  void paint(Canvas canvas, Size size) => _withViewBox(canvas, size, (c) {
        // sun + birds
        c.drawCircle(const Offset(285, 62), 30, _fill(_C.sun2));
        c.drawCircle(const Offset(285, 62), 20, _fill(_C.sun));
        _path(c, 'M52 64 q7 -7 14 0 q7 -7 14 0',
            _stroke(_C.ink2, width: 2.6, cap: StrokeCap.round));
        _path(c, 'M92 50 q5 -5 10 0 q5 -5 10 0',
            _stroke(_C.ink2, width: 2.6, cap: StrokeCap.round));

        _drawGround(c, y: 246);

        // mango tree (right)
        c.save();
        c.translate(244, 248);
        _drawRRect(c, -7, -66, 14, 70, 6, _fill(_C.trunk));
        _path(c, 'M0 -30 l-20 -14 M0 -46 l22 -14',
            _stroke(_C.trunk, width: 7, cap: StrokeCap.round));
        c.drawCircle(const Offset(0, -92), 46, _fill(_C.forest2));
        c.drawCircle(const Offset(-34, -70), 32, _fill(_C.forest3));
        c.drawCircle(const Offset(34, -72), 33, _fill(_C.sage));
        c.drawCircle(const Offset(0, -96), 34, _fill(_C.forest3));
        _ellipse(c, -26, -66, 7, 9.5, _fill(_C.sun));
        _ellipse(c, 28, -58, 7, 9.5, _fill(_C.amber));
        _ellipse(c, 2, -50, 7, 9.5, _fill(_C.saffron));
        _ellipse(c, -4, -104, 6.5, 9, _fill(_C.amber));
        c.restore();

        // coconut palm (left)
        _drawPalm(c, 92, 248, s: 1.04);

        // basket of coconuts
        c.save();
        c.translate(150, 258);
        _path(c, 'M-26 -2 L26 -2 L20 22 L-20 22 Z', _fill(_C.trunkHi));
        _path(c, 'M-26 -2 L26 -2 L24 6 L-24 6 Z', _fill(_C.trunk));
        c.drawCircle(const Offset(-9, -7), 9, _fill(_C.rupeeBasket));
        c.drawCircle(const Offset(9, -8), 9, _fill(_C.trunkDk));
        c.drawCircle(const Offset(0, -13), 8.5, _fill(_C.rupeeIncome));
        c.restore();

        // floating coins
        _drawCoin(c, 206, 150, r: 17, rot: -8);
        _drawCoin(c, 238, 186, r: 13, rot: 10);
        _drawCoin(c, 186, 118, r: 11, rot: 6);
      });

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Slide 2 — flow ───────────────────────────────────────────────────────────
class _FlowPainter extends CustomPainter {
  const _FlowPainter();

  @override
  void paint(Canvas canvas, Size size) => _withViewBox(canvas, size, (c) {
        // dotted connector
        _drawDashedPath(
          c,
          parseSvgPath(
              'M70 120 C110 88 150 88 170 150 C190 212 230 212 270 176'),
          _stroke(_C.sage, width: 3.4, cap: StrokeCap.round, opacity: 0.75),
          dash: 2,
          gap: 10,
        );

        // Station 1 — book
        c.save();
        c.translate(70, 120);
        c.drawCircle(Offset.zero, 46, _fill(_C.leaf));
        _rrect(c, -20, -30, 40, 60, 8, _fill(_C.paper));
        _rrectStroke(c, -20, -30, 40, 60, 8, _stroke(_C.forest2, width: 2.5));
        _rrect(c, -20, -30, 40, 15, 8, _fill(_C.forest2));
        c.drawRect(const Rect.fromLTWH(-20, -22, 40, 7), _fill(_C.forest2));
        final cell = _fill(_C.sage);
        for (final p in const [
          [-13.0, -7.0], [-3.5, -7.0], [6.0, -7.0],
          [-13.0, 3.0], [6.0, 3.0],
          [-13.0, 13.0], [-3.5, 13.0],
        ]) {
          _rrect(c, p[0], p[1], 7, 7, 1.5, cell);
        }
        _rrect(c, -3.5, 3, 7, 7, 1.5, _fill(_C.sun)); // highlighted day
        c.drawCircle(const Offset(26, -26), 13, _fill(_C.sun));
        _path(c, 'M21 -26 l3.5 3.5 L31 -30',
            _stroke(_C.paper, width: 2.6, cap: StrokeCap.round, join: StrokeJoin.round));
        c.restore();

        // Station 2 — crew arrives
        c.save();
        c.translate(170, 150);
        c.drawCircle(Offset.zero, 52, _fill(_C.leaf2));
        c.save();
        c.translate(-2, 30);
        c.scale(0.62);
        _drawPalm(c, 0, 0, s: 1, climber: true);
        c.restore();
        // three-wheeler auto
        c.save();
        c.translate(20, 24);
        _path(c, 'M-22 0 q2 -16 16 -16 l8 0 q9 0 11 8 l3 8 Z', _fill(_C.sun));
        _path(c, 'M-22 0 l38 0 0 6 -38 0 Z', _fill(_C.saffron));
        _rrect(c, -13, -13, 11, 9, 2, _fill(_C.leaf));
        c.drawCircle(const Offset(-12, 8), 6, _fill(_C.ink2));
        c.drawCircle(const Offset(-12, 8), 2.4, _fill(_C.mist));
        c.drawCircle(const Offset(12, 8), 6, _fill(_C.ink2));
        c.drawCircle(const Offset(12, 8), 2.4, _fill(_C.mist));
        c.restore();
        c.restore();

        // Station 3 — done
        c.save();
        c.translate(270, 176);
        c.drawCircle(Offset.zero, 44, _fill(_C.leaf));
        c.drawCircle(Offset.zero, 30, _fill(_C.forest2));
        c.drawCircle(Offset.zero, 30, _stroke(_C.forest, width: 2, opacity: 0.5));
        _path(c, 'M-13 1 l9 10 L16 -11',
            _stroke(_C.paper, width: 5.5, cap: StrokeCap.round, join: StrokeJoin.round));
        _path(c, 'M30 -30 l2 7 7 2 -7 2 -2 7 -2 -7 -7 -2 7 -2 Z', _fill(_C.sun));
        c.restore();
      });

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Slide 3 — report ─────────────────────────────────────────────────────────
class _ReportPainter extends CustomPainter {
  const _ReportPainter();

  @override
  void paint(Canvas canvas, Size size) => _withViewBox(canvas, size, (c) {
        // soft halo
        c.drawCircle(const Offset(170, 138), 116, _fill(_C.leaf, opacity: 0.6));

        // report card (tilted -5deg)
        c.save();
        c.translate(120, 56);
        c.rotate(-5 * math.pi / 180);
        _rrect(c, 0, 0, 150, 178, 14, _fill(_C.paper));
        _rrectStroke(c, 0, 0, 150, 178, 14, _stroke(_C.mist, width: 1.5));
        // header band
        _path(c, 'M0 14 a14 14 0 0 1 14 -14 h122 a14 14 0 0 1 14 14 v22 h-150 Z',
            _fill(_C.forest2));
        c.drawCircle(const Offset(22, 18), 9, _fill(_C.sun));
        _path(c, 'M18 18 l3 3 5 -6',
            _stroke(_C.paper, width: 2, cap: StrokeCap.round, join: StrokeJoin.round));
        _rrect(c, 38, 13, 64, 6, 3, _fill(_C.paper, opacity: 0.95));
        _rrect(c, 38, 24, 40, 5, 2.5, _fill(_C.paper, opacity: 0.55));
        // line items
        _rrect(c, 16, 52, 58, 6, 3, _fill(_C.ink2, opacity: 0.7));
        _rrect(c, 104, 52, 30, 6, 3, _fill(_C.mist));
        _rrect(c, 16, 70, 48, 6, 3, _fill(_C.mist));
        _rrect(c, 104, 70, 30, 6, 3, _fill(_C.mist));
        _rrect(c, 16, 88, 54, 6, 3, _fill(_C.mist));
        _rrect(c, 104, 88, 30, 6, 3, _fill(_C.mist));
        // weight chip
        c.save();
        c.translate(16, 108);
        _rrect(c, 0, 0, 62, 24, 12, _fill(_C.leaf));
        _drawText(c, '148 kg', const Offset(31, 16),
            size: 12, weight: FontWeight.w700, color: _C.forest, align: TextAlign.center);
        c.restore();
        // total
        _drawDashedPath(
          c,
          parseSvgPath('M16 146 L134 146'),
          _stroke(_C.mist, width: 1.5),
          dash: 3,
          gap: 4,
        );
        _drawText(c, 'Total paid', const Offset(16, 168),
            size: 11, weight: FontWeight.w600, color: _C.ink2);
        _drawText(c, '₹4,260', const Offset(134, 170),
            size: 20,
            weight: FontWeight.w800,
            color: _C.forest,
            display: true,
            align: TextAlign.right);
        c.restore();

        // UPI / paid badge
        c.save();
        c.translate(232, 178);
        c.drawCircle(Offset.zero, 38, _fill(_C.sun));
        c.drawCircle(Offset.zero, 38, _stroke(_C.saffron, width: 2.5, opacity: 0.6));
        _path(c, 'M-15 2 l10 11 L18 -13',
            _stroke(_C.paper, width: 6, cap: StrokeCap.round, join: StrokeJoin.round));
        _drawText(c, 'PAID', const Offset(0, 30),
            size: 11, weight: FontWeight.w800, color: _C.roof2, align: TextAlign.center);
        c.restore();

        // coins
        _drawCoin(c, 86, 236, r: 18, rot: -6);
        _drawCoin(c, 116, 250, r: 14, rot: 8);
      });

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Small drawing helpers ────────────────────────────────────────────────────
void _rrect(Canvas c, double x, double y, double w, double h, double r, Paint p) =>
    c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)), p);

void _rrectStroke(
        Canvas c, double x, double y, double w, double h, double r, Paint p) =>
    c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)), p);

void _drawRRect(Canvas c, double x, double y, double w, double h, double r, Paint p) =>
    _rrect(c, x, y, w, h, r, p);

void _ellipse(Canvas c, double cx, double cy, double rx, double ry, Paint p) =>
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), p);

void _drawDashedPath(Canvas c, Path path, Paint paint,
    {required double dash, required double gap}) {
  for (final metric in path.computeMetrics()) {
    double dist = 0;
    while (dist < metric.length) {
      final end = math.min(dist + dash, metric.length);
      c.drawPath(metric.extractPath(dist, end), paint);
      dist += dash + gap;
    }
  }
}

// ── Minimal SVG path-data parser (M,L,H,V,C,S,Q,T,A,Z + relative variants) ───
Path parseSvgPath(String d) {
  final path = Path();
  final tokens = _tokenize(d);
  int i = 0;
  double cx = 0, cy = 0, sx = 0, sy = 0; // current + subpath-start
  double lastCx = 0, lastCy = 0; // last cubic control (for S)
  double lastQx = 0, lastQy = 0; // last quad control (for T)
  String prevCmd = '';

  double num() => tokens[i++].number!;

  while (i < tokens.length) {
    final cmd = tokens[i].command ?? prevCmd;
    if (tokens[i].command != null) i++;
    final rel = cmd == cmd.toLowerCase();
    switch (cmd.toUpperCase()) {
      case 'M':
        cx = rel ? cx + num() : num();
        cy = rel ? cy + num() : num();
        path.moveTo(cx, cy);
        sx = cx;
        sy = cy;
        prevCmd = rel ? 'l' : 'L'; // subsequent pairs are implicit lineto
      case 'L':
        cx = rel ? cx + num() : num();
        cy = rel ? cy + num() : num();
        path.lineTo(cx, cy);
        prevCmd = cmd;
      case 'H':
        cx = rel ? cx + num() : num();
        path.lineTo(cx, cy);
        prevCmd = cmd;
      case 'V':
        cy = rel ? cy + num() : num();
        path.lineTo(cx, cy);
        prevCmd = cmd;
      case 'C':
        final x1 = rel ? cx + num() : num();
        final y1 = rel ? cy + num() : num();
        final x2 = rel ? cx + num() : num();
        final y2 = rel ? cy + num() : num();
        final x = rel ? cx + num() : num();
        final y = rel ? cy + num() : num();
        path.cubicTo(x1, y1, x2, y2, x, y);
        lastCx = x2;
        lastCy = y2;
        cx = x;
        cy = y;
        prevCmd = cmd;
      case 'S':
        final isCubic = prevCmd.toUpperCase() == 'C' || prevCmd.toUpperCase() == 'S';
        final x1 = isCubic ? 2 * cx - lastCx : cx;
        final y1 = isCubic ? 2 * cy - lastCy : cy;
        final x2 = rel ? cx + num() : num();
        final y2 = rel ? cy + num() : num();
        final x = rel ? cx + num() : num();
        final y = rel ? cy + num() : num();
        path.cubicTo(x1, y1, x2, y2, x, y);
        lastCx = x2;
        lastCy = y2;
        cx = x;
        cy = y;
        prevCmd = cmd;
      case 'Q':
        final x1 = rel ? cx + num() : num();
        final y1 = rel ? cy + num() : num();
        final x = rel ? cx + num() : num();
        final y = rel ? cy + num() : num();
        path.quadraticBezierTo(x1, y1, x, y);
        lastQx = x1;
        lastQy = y1;
        cx = x;
        cy = y;
        prevCmd = cmd;
      case 'T':
        final isQuad = prevCmd.toUpperCase() == 'Q' || prevCmd.toUpperCase() == 'T';
        final x1 = isQuad ? 2 * cx - lastQx : cx;
        final y1 = isQuad ? 2 * cy - lastQy : cy;
        final x = rel ? cx + num() : num();
        final y = rel ? cy + num() : num();
        path.quadraticBezierTo(x1, y1, x, y);
        lastQx = x1;
        lastQy = y1;
        cx = x;
        cy = y;
        prevCmd = cmd;
      case 'A':
        final rx = num().abs();
        final ry = num().abs();
        final xAxisRot = num();
        final largeArc = num() != 0;
        final sweep = num() != 0;
        final x = rel ? cx + num() : num();
        final y = rel ? cy + num() : num();
        _arcTo(path, cx, cy, rx, ry, xAxisRot, largeArc, sweep, x, y);
        cx = x;
        cy = y;
        prevCmd = cmd;
      case 'Z':
        path.close();
        cx = sx;
        cy = sy;
        prevCmd = cmd;
    }
  }
  return path;
}

/// Endpoint-to-centre SVG elliptical-arc conversion, appended to [path].
void _arcTo(Path path, double x0, double y0, double rx, double ry,
    double xAxisRotDeg, bool largeArc, bool sweep, double x, double y) {
  if (rx == 0 || ry == 0) {
    path.lineTo(x, y);
    return;
  }
  final phi = xAxisRotDeg * math.pi / 180;
  final cosP = math.cos(phi), sinP = math.sin(phi);
  final dx = (x0 - x) / 2, dy = (y0 - y) / 2;
  final x1p = cosP * dx + sinP * dy;
  final y1p = -sinP * dx + cosP * dy;
  var rxs = rx * rx, rys = ry * ry;
  final x1ps = x1p * x1p, y1ps = y1p * y1p;
  // correct radii if too small
  final lambda = x1ps / rxs + y1ps / rys;
  if (lambda > 1) {
    final s = math.sqrt(lambda);
    rx *= s;
    ry *= s;
    rxs = rx * rx;
    rys = ry * ry;
  }
  var denom = rxs * y1ps + rys * x1ps;
  var num = rxs * rys - rxs * y1ps - rys * x1ps;
  if (num < 0) num = 0;
  var coef = math.sqrt(num / denom);
  if (largeArc == sweep) coef = -coef;
  final cxp = coef * rx * y1p / ry;
  final cyp = -coef * ry * x1p / rx;
  final ccx = cosP * cxp - sinP * cyp + (x0 + x) / 2;
  final ccy = sinP * cxp + cosP * cyp + (y0 + y) / 2;

  double angle(double ux, double uy, double vx, double vy) {
    final dot = ux * vx + uy * vy;
    final len = math.sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy));
    var a = math.acos((dot / len).clamp(-1.0, 1.0));
    if (ux * vy - uy * vx < 0) a = -a;
    return a;
  }

  final theta1 = angle(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry);
  var delta = angle((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx,
      (-y1p - cyp) / ry);
  if (!sweep && delta > 0) delta -= 2 * math.pi;
  if (sweep && delta < 0) delta += 2 * math.pi;

  path.addArc(
    Rect.fromCenter(center: Offset(ccx, ccy), width: rx * 2, height: ry * 2),
    theta1,
    delta,
  );
  // NB: rotation (phi) is 0 for all arcs used here, so we skip transform.
}

class _Token {
  final String? command;
  final double? number;
  _Token.cmd(this.command) : number = null;
  _Token.num(this.number) : command = null;
}

List<_Token> _tokenize(String d) {
  final out = <_Token>[];
  final re = RegExp(r'[a-zA-Z]|-?\d*\.?\d+(?:[eE][-+]?\d+)?');
  for (final m in re.allMatches(d)) {
    final s = m.group(0)!;
    final code = s.codeUnitAt(0);
    final isLetter =
        (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
    if (isLetter) {
      out.add(_Token.cmd(s));
    } else {
      out.add(_Token.num(double.parse(s)));
    }
  }
  return out;
}
