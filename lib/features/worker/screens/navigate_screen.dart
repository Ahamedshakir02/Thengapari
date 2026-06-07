import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/design_tokens.dart';
import '../../../app/router.dart';
import '../theme/worker_theme.dart';

/// Turn-by-turn navigation to the job site — stylised dark map, ETA banner, and
/// an "I've arrived" check-in. Matches `Designs/ThengaPari Worker App/screen-navigate.jsx`.
/// The map is a painted approximation (no Google Maps key needed for review).
class NavigateScreen extends StatelessWidget {
  const NavigateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05231F),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapPainter())),
          // top scrim
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xD905231F), Color(0x0005231F)],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 14,
                  child: _backButton(context),
                ),
                Positioned(
                  top: 8,
                  left: 66,
                  right: 14,
                  child: _etaBanner(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _bottomSheet(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.canPop() ? context.pop() : context.go(AppRoutes.workerHome),
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xB3062925),
          border: Border.all(color: WColors.line),
        ),
        child: const Icon(Icons.chevron_left, size: 24, color: Colors.white),
      ),
    );
  }

  Widget _etaBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xDB08332F),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: const Color(0x386FB6AB)),
        boxShadow: AppShadows.lg,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0x29F4A52A),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.navigation, size: 20, color: WColors.accent2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('12',
                        style: AppText.displayNum(22, color: Colors.white, weight: FontWeight.w800)),
                    Text(' min',
                        style: AppText.bodySm().copyWith(
                            color: Colors.white.withValues(alpha: 0.8))),
                    const SizedBox(width: 8),
                    Text('· 1.8 km',
                        style: AppText.caption().copyWith(color: WColors.teal300)),
                  ],
                ),
                const SizedBox(height: 4),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: 'Arrive by ',
                      style: AppText.caption().copyWith(color: WColors.fg3)),
                  TextSpan(
                      text: '9:42 AM',
                      style: AppText.caption().copyWith(
                          color: WColors.teal100, fontWeight: FontWeight.w700)),
                ])),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: WColors.teal500),
            child: const Icon(Icons.call, size: 19, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _bottomSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF07302B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        boxShadow: [
          BoxShadow(color: Color(0x66000000), blurRadius: 36, offset: Offset(0, -14)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                  color: WColors.lineStrong,
                  borderRadius: BorderRadius.circular(999)),
            ),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: WColors.surface,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.eco, size: 21, color: WColors.teal300),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Head to the grove',
                          style: AppText.title().copyWith(fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('Parambil Estate · Ollur, Thrissur',
                          style: AppText.bodySm().copyWith(color: WColors.fg2)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.pushReplacement(AppRoutes.workerComplete),
              child: Container(
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [WColors.accent2, WColors.accent],
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: WColors.accent.withValues(alpha: 0.4),
                        blurRadius: 28,
                        offset: const Offset(0, 10)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.place, size: 21, color: AppColors.greenForest900),
                    const SizedBox(width: 10),
                    Text("I've arrived",
                        style: AppText.button().copyWith(
                            color: AppColors.greenForest900, fontSize: 19)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stylised dark map: grove plots, roads, the amber route, a destination pin,
/// and the worker's position marker.
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF05231F));

    // grove plots
    final plots = [
      Rect.fromLTWH(0.04 * w, 0.28 * h, 0.26 * w, 0.11 * h),
      Rect.fromLTWH(0.62 * w, 0.35 * h, 0.30 * w, 0.12 * h),
      Rect.fromLTWH(0.07 * w, 0.50 * h, 0.22 * w, 0.10 * h),
      Rect.fromLTWH(0.52 * w, 0.60 * h, 0.38 * w, 0.15 * h),
      Rect.fromLTWH(0.10 * w, 0.72 * h, 0.24 * w, 0.11 * h),
      Rect.fromLTWH(0.68 * w, 0.15 * h, 0.26 * w, 0.10 * h),
    ];
    for (int i = 0; i < plots.length; i++) {
      final r = RRect.fromRectAndRadius(plots[i], const Radius.circular(12));
      canvas.drawRRect(r, Paint()..color = i.isEven ? const Color(0xFF0B423B) : const Color(0xFF0A3C36));
      canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = WColors.teal300.withValues(alpha: 0.10),
      );
    }

    // roads
    final road = Paint()
      ..color = const Color(0xFF0E4A43)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-10, 0.65 * h), Offset(w + 10, 0.65 * h), road);
    canvas.drawLine(Offset(0.32 * w, h + 10), Offset(0.32 * w, 0.42 * h), road);
    canvas.drawLine(Offset(-10, 0.21 * h), Offset(w + 10, 0.21 * h), road);

    // route (amber, with glow)
    final route = Path()
      ..moveTo(0.44 * w, 0.86 * h)
      ..cubicTo(0.36 * w, 0.78 * h, 0.52 * w, 0.72 * h, 0.40 * w, 0.66 * h)
      ..cubicTo(0.30 * w, 0.60 * h, 0.32 * w, 0.52 * h, 0.52 * w, 0.46 * h)
      ..cubicTo(0.70 * w, 0.40 * h, 0.78 * w, 0.32 * h, 0.64 * w, 0.26 * h)
      ..cubicTo(0.58 * w, 0.23 * h, 0.62 * w, 0.20 * h, 0.66 * w, 0.19 * h);
    canvas.drawPath(
      route,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round
        ..color = WColors.accent.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      route,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round
        ..color = WColors.accent,
    );

    // destination pin
    final pin = Offset(0.66 * w, 0.19 * h);
    canvas.drawCircle(pin.translate(0, -4), 16, Paint()..color = WColors.accent);
    final tail = Path()
      ..moveTo(pin.dx - 9, pin.dy - 2)
      ..lineTo(pin.dx + 9, pin.dy - 2)
      ..lineTo(pin.dx, pin.dy + 12)
      ..close();
    canvas.drawPath(tail, Paint()..color = WColors.accent);
    canvas.drawCircle(pin.translate(0, -6), 7, Paint()..color = const Color(0xFF5A3206));

    // worker marker on route
    final worker = Offset(0.46 * w, 0.55 * h);
    canvas.drawCircle(worker, 11, Paint()..color = Colors.white);
    canvas.drawCircle(
      worker,
      11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = WColors.teal500,
    );
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => false;
}
