import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:core/app/design_tokens.dart';
import 'package:core/core/models/harvest_job.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/homeowner_providers.dart';
import 'package:core/core/widgets/app_icon.dart';

/// Live job tracker — progress stepper, stylised grove map with the site
/// manager's position, contact row, live weight, and site photos. Matches
/// `TrackerScreen` in app-screens-flow.jsx / `app.css`.
class LiveJobTrackerScreen extends ConsumerWidget {
  const LiveJobTrackerScreen({super.key});

  static const _steps = ['Assigned', 'En route', 'On-site', 'Harvesting', 'Done'];

  int _activeIndex(String status) => switch (status) {
        'pending' => 0,
        'site_manager_assigned' => 1,
        'worker_assigned' => 1,
        'in_progress' => 2,
        'harvesting' => 3,
        'processing' => 3,
        'byproducts_routed' => 4,
        'complete' => 5,
        _ => 0,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final jobAsync = ref.watch(activeJobProvider(uid));
    final job = jobAsync.maybeWhen(data: (j) => j, orElse: () => null);
    final status = job?.status ?? 'in_progress';
    final activeIdx = _activeIndex(status);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Live job'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: _LivePill()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
            child: _Stepper(steps: _steps, activeIndex: activeIdx),
          ),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpace.gutter),
            child: GroveMap(),
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpace.gutter),
            child: _WorkerRow(),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
            child: _LiveWeight(job: job),
          ),
          const SizedBox(height: 16),
          const _SitePhotos(),
        ],
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 5, 11, 5),
      decoration: BoxDecoration(
        color: AppColors.statusInprogressBg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                color: AppColors.statusErrorFg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text('LIVE',
              style: AppText.caption().copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.statusInprogressFg)),
        ],
      ),
    );
  }
}

// ── Stepper ──────────────────────────────────────────────────────────

class _Stepper extends StatelessWidget {
  final List<String> steps;
  final int activeIndex;

  const _Stepper({required this.steps, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          Expanded(
            child: _StepItem(
              index: i,
              label: steps[i],
              done: i < activeIndex,
              active: i == activeIndex,
              showLeftLine: i != 0,
              leftFilled: i <= activeIndex,
            ),
          ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final String label;
  final bool done;
  final bool active;
  final bool showLeftLine;
  final bool leftFilled;

  const _StepItem({
    required this.index,
    required this.label,
    required this.done,
    required this.active,
    required this.showLeftLine,
    required this.leftFilled,
  });

  @override
  Widget build(BuildContext context) {
    final Color nodeBg = done
        ? AppColors.brand
        : active
            ? AppColors.accent
            : AppColors.surface;
    final Color nodeBorder = done
        ? AppColors.brand
        : active
            ? AppColors.accent
            : AppColors.borderStrong;
    final Color fg = done
        ? Colors.white
        : active
            ? AppColors.onAccent
            : AppColors.fg3;

    return Column(
      children: [
        SizedBox(
          height: 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showLeftLine)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 14,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(
                        height: 3,
                        color:
                            leftFilled ? AppColors.brand : AppColors.mist200,
                      ),
                    ),
                  ),
                ),
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: nodeBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: nodeBorder, width: 2),
                  boxShadow: active
                      ? const [
                          BoxShadow(
                              color: Color(0x2EF4A52A),
                              blurRadius: 0,
                              spreadRadius: 5)
                        ]
                      : null,
                ),
                child: done
                    ? AppIcon('check',
                        size: 16, color: Colors.white, strokeWidth: 2.4)
                    : Text('${index + 1}',
                        style: AppText.caption().copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: fg)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            textAlign: TextAlign.center,
            style: AppText.caption().copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: (done || active) ? AppColors.fg1 : AppColors.fg3)),
      ],
    );
  }
}

// ── Grove map ──────────────────────────────────────────────────────────

class GroveMap extends StatelessWidget {
  const GroveMap({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _GroveMapPainter())),
            // worker pin
            const Align(
              alignment: Alignment(0.24, -0.05),
              child: _WorkerPin(),
            ),
            // badge
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 7, 13, 7),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  boxShadow: AppShadows.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _smAvatar(26, 11),
                    const SizedBox(width: 8),
                    Text('2.1 km · 6 min away',
                        style: AppText.caption().copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.fg1)),
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

Widget _smAvatar(double size, double fontSize) => Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle),
      child: Text('SM',
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
    );

class _WorkerPin extends StatelessWidget {
  const _WorkerPin();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 48,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const Icon(Icons.location_on, color: AppColors.accent, size: 44),
          Positioned(
            top: 6,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Text('SM',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amberSaffron600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroveMapPainter extends CustomPainter {
  const _GroveMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 360, sy = size.height / 220;
    Offset p(double x, double y) => Offset(x * sx, y * sy);
    Rect r(double x, double y, double w, double h) =>
        Rect.fromLTWH(x * sx, y * sy, w * sx, h * sy);

    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEAF0E0));
    canvas.drawRect(r(-10, 120, 180, 120), Paint()..color = const Color(0xFFD6E5C2));
    canvas.drawRect(r(180, -10, 200, 110), Paint()..color = const Color(0xFFDDEAC9));

    // faint curved band
    final band = Path()
      ..moveTo(0, 60 * sy)
      ..quadraticBezierTo(120 * sx, 40 * sy, 200 * sx, 90 * sy)
      ..quadraticBezierTo(280 * sx, 130 * sy, 360 * sx, 70 * sy);
    canvas.drawPath(
      band,
      Paint()
        ..color = const Color(0xFFCFE0BC).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40 * sy,
    );

    // tree dots
    for (int row = 0; row < 5; row++) {
      for (int c = 0; c < 8; c++) {
        final isDark = (row + c) % 3 == 0;
        canvas.drawCircle(
          p(28 + c * 42, 40 + row * 40),
          6 * sx,
          Paint()
            ..color = (isDark
                    ? const Color(0xFF2E6B3E)
                    : const Color(0xFF6E9E5E))
                .withValues(alpha: 0.8),
        );
      }
    }

    // dashed path
    final path = Path()
      ..moveTo(40 * sx, 210 * sy)
      ..cubicTo(120 * sx, 160 * sy, 130 * sx, 120 * sy, 220 * sx, 96 * sy);
    final dashPaint = Paint()
      ..color = const Color(0xFFF1F6E9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9 * sy
      ..strokeCap = StrokeCap.round;
    _drawDashed(canvas, path, dashPaint, 2 * sx, 12 * sx);

    // home marker
    canvas.drawRRect(
      RRect.fromRectAndRadius(r(26, 190, 20, 14), Radius.circular(2 * sx)),
      Paint()..color = const Color(0xFFC8603A),
    );
    final roof = Path()
      ..moveTo(23 * sx, 190 * sy)
      ..lineTo(36 * sx, 180 * sy)
      ..lineTo(49 * sx, 190 * sy)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFA94F2E));
  }

  void _drawDashed(
      Canvas canvas, Path path, Paint paint, double dash, double gap) {
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final seg = metric.extractPath(dist, dist + dash);
        canvas.drawPath(seg, paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Worker contact row ──────────────────────────────────────────────────

class _WorkerRow extends StatelessWidget {
  const _WorkerRow();

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: '+910000000000');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.greenSage500, AppColors.brand],
              ),
            ),
            child: Text('SM',
                style: AppText.displayNum(17, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suresh Kumar',
                    style: AppText.title().copyWith(fontSize: 15.5)),
                const SizedBox(height: 1),
                Text('Site Manager en route · 2.1 km',
                    style: AppText.caption().copyWith(fontSize: 12.5)),
              ],
            ),
          ),
          _iconBtn('phone', _call),
          const SizedBox(width: 8),
          _iconBtn('chat', () {}),
        ],
      ),
    );
  }

  Widget _iconBtn(String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.greenLeaf100,
          shape: BoxShape.circle,
        ),
        child: AppIcon(icon, size: 19, color: AppColors.brand),
      ),
    );
  }
}

// ── Live weight ──────────────────────────────────────────────────────────

class _LiveWeight extends StatelessWidget {
  final HarvestJob? job;
  const _LiveWeight({required this.job});

  @override
  Widget build(BuildContext context) {
    final est = job?.estimatedYieldKg ?? 23;
    final actual = job?.actualYieldKg ?? 0;
    final pct = est <= 0 ? 0.0 : (actual / est).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Live weight', style: AppText.title())),
            const _LivePill(),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(76, 76),
                      painter: _DialPainter(pct.toDouble()),
                    ),
                    AppIcon('scale', size: 26, color: AppColors.accent),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(actual.toStringAsFixed(1),
                            style: AppText.displayNum(30)),
                        Text(' / ${est.toStringAsFixed(0)} kg',
                            style: AppText.caption().copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fg3)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text('Weighed so far · across the grove',
                        style: AppText.caption().copyWith(fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  final double pct;
  const _DialPainter(this.pct);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 5;
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppColors.surfaceSunk
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * pct,
      false,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) => old.pct != pct;
}

// ── Site photos ──────────────────────────────────────────────────────────

class _SitePhotos extends StatelessWidget {
  const _SitePhotos();

  static const _photos = [
    ([Color(0xFF357A47), Color(0xFF1E4D2B)], 'tree', '8:02'),
    ([Color(0xFF94B97F), Color(0xFF2E6B3E)], 'leaf', '8:14'),
    ([Color(0xFFFBBA4D), Color(0xFFDD8413)], 'scale', '8:31'),
    ([Color(0xFF6E9E5E), Color(0xFF357A47)], 'leaf', '8:40'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.gutter, 0, AppSpace.gutter, 10),
          child: Row(
            children: [
              Expanded(child: Text('Site photos', style: AppText.title())),
              Text('See all',
                  style: AppText.caption().copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brand)),
            ],
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
            itemCount: _photos.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final (colors, icon, time) = _photos[i];
              return Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: AppIcon(icon,
                          size: 30,
                          color: Colors.white.withValues(alpha: 0.85),
                          strokeWidth: 1.6),
                    ),
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0x9915331F),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Text(time,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
