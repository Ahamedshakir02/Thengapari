import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:worker/router.dart';
import '../theme/worker_theme.dart';

/// Full-screen job-ping takeover — the most time-critical worker screen.
/// Animated radar, job detail card, and a 45-second countdown that
/// auto-declines on expiry. Matches `Designs/ThengaPari Worker App/screen-ping.jsx`.
class JobPingScreen extends StatefulWidget {
  const JobPingScreen({super.key});

  @override
  State<JobPingScreen> createState() => _JobPingScreenState();
}

class _JobPingScreenState extends State<JobPingScreen>
    with TickerProviderStateMixin {
  static const _duration = 45;
  int _left = _duration;
  Timer? _timer;

  late final AnimationController _sweep = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3600))
    ..repeat();
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left <= 1) {
        _timer?.cancel();
        _expire();
      } else {
        setState(() => _left--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sweep.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _expire() {
    if (!mounted) return;
    if (context.canPop()) context.pop();
  }

  void _decline() {
    _timer?.cancel();
    if (context.canPop()) context.pop();
  }

  void _accept() {
    _timer?.cancel();
    context.pushReplacement(AppRoutes.workerNavigate);
  }

  @override
  Widget build(BuildContext context) {
    final ratio = _left / _duration;
    final urgent = _left <= 10;
    final cdColor = ratio > 0.5
        ? WColors.good
        : ratio > 0.26
            ? WColors.accent2
            : WColors.bad;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1),
            radius: 1.1,
            colors: [WColors.glowTop, WColors.bg, WColors.bgDeep],
            stops: [0, 0.52, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  children: [
                    _pingHeader(),
                    const SizedBox(height: 6),
                    _radar(),
                    const SizedBox(height: 8),
                    Center(
                      child: Text('Coconut husking needed',
                          style: AppText.displayNum(26, color: Colors.white)),
                    ),
                    const SizedBox(height: 16),
                    _detailCard(),
                    const SizedBox(height: 16),
                    _countdown(ratio, cdColor, urgent),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              _buttons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pingHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeTransition(
          opacity: Tween(begin: 0.35, end: 1.0).animate(_pulse),
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: WColors.accent),
          ),
        ),
        const SizedBox(width: 9),
        Text('NEW JOB PING · 1.8 KM AWAY',
            style: AppText.overline().copyWith(
                color: WColors.accent2, letterSpacing: 2, fontSize: 12.5)),
      ],
    );
  }

  Widget _radar() {
    return SizedBox(
      height: 200,
      child: AnimatedBuilder(
        animation: _sweep,
        builder: (_, _) => CustomPaint(
          painter: _RadarPainter(_sweep.value, _pulse.value),
          size: Size.infinite,
        ),
      ),
    );
  }

  Widget _detailCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.paper0,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.lg,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PAYOUT',
                        style: AppText.overline()
                            .copyWith(color: AppColors.ink500, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text('₹380',
                        style: AppText.displayNum(42,
                            color: AppColors.amberSaffron600,
                            weight: FontWeight.w800)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: AppColors.statusCompleteBg,
                    borderRadius: BorderRadius.circular(999)),
                child: Text('≈ ₹16 / coconut',
                    style: AppText.bodySm().copyWith(
                        color: AppColors.green600, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          _cardDivider(),
          Row(
            children: [
              _fact(Icons.schedule, '~1.5 h', 'Duration'),
              _factDivider(),
              _fact(Icons.navigation_outlined, '1.8 km', 'Distance'),
              _factDivider(),
              _fact(Icons.spa_outlined, '24', 'Crop'),
            ],
          ),
          _cardDivider(),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.greenLeaf100),
                child: Text('A',
                    style: AppText.displayNum(18, color: AppColors.greenForest700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Arjun K.',
                        style: AppText.title()
                            .copyWith(fontSize: 16, color: AppColors.ink900)),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 13, color: AppColors.amber500),
                        const SizedBox(width: 4),
                        Text('4.9',
                            style: AppText.bodySm().copyWith(
                                color: AppColors.ink700, fontWeight: FontWeight.w600)),
                        Text(' · Site manager',
                            style: AppText.caption().copyWith(color: AppColors.ink500)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greenLeaf50,
                  border: Border.all(color: AppColors.mist200),
                ),
                child: const Icon(Icons.call, size: 18, color: AppColors.greenForest700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fact(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.brand),
          const SizedBox(height: 6),
          Text(value,
              style: AppText.title().copyWith(fontSize: 16, color: AppColors.ink900)),
          const SizedBox(height: 3),
          Text(label, style: AppText.caption().copyWith(color: AppColors.ink500)),
        ],
      ),
    );
  }

  Widget _cardDivider() => Container(
      height: 1, color: AppColors.mist200, margin: const EdgeInsets.symmetric(vertical: 15));

  Widget _factDivider() =>
      Container(width: 1, height: 44, color: AppColors.mist200);

  Widget _countdown(double ratio, Color color, bool urgent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RESPOND WITHIN',
                  style: AppText.caption().copyWith(
                      color: WColors.fg3, letterSpacing: 1.2, fontSize: 11)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0, 1),
                  minHeight: 8,
                  backgroundColor: const Color(0x24D6ECE7),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        AnimatedScale(
          scale: urgent ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 400),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: '$_left', style: AppText.displayNum(38, color: color, weight: FontWeight.w800)),
              TextSpan(text: 's', style: AppText.displayNum(18, color: color).copyWith(fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buttons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _decline,
              child: Container(
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: WColors.lineStrong, width: 1.5),
                ),
                child: Text('Decline',
                    style: AppText.button().copyWith(color: WColors.fg2, fontSize: 17)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: _accept,
              child: Container(
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check, size: 20, color: WColors.teal500),
                    const SizedBox(width: 9),
                    Text('Accept job',
                        style: AppText.button().copyWith(color: WColors.bg, fontSize: 18)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Radar: concentric rings, crosshair, rotating amber sweep, worker dot at
/// centre, and a pulsing amber job dot.
class _RadarPainter extends CustomPainter {
  final double sweep; // 0..1 rotation
  final double pulse; // 0..1 job-dot pulse
  _RadarPainter(this.sweep, this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) / 2 - 4;

    // rings
    for (int i = 0; i < 4; i++) {
      final r = maxR * (1 - i * 0.24);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = WColors.teal300.withValues(alpha: 0.34 - i * 0.06),
      );
    }
    // axes
    final axis = Paint()
      ..color = WColors.teal300.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(center.dx - maxR, center.dy), Offset(center.dx + maxR, center.dy), axis);
    canvas.drawLine(
        Offset(center.dx, center.dy - maxR), Offset(center.dx, center.dy + maxR), axis);

    // rotating sweep
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(sweep * 2 * math.pi);
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          WColors.accent.withValues(alpha: 0),
          WColors.accent.withValues(alpha: 0),
          WColors.accent.withValues(alpha: 0.10),
          WColors.accent.withValues(alpha: 0.42),
        ],
        stops: const [0, 0.82, 0.92, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: maxR));
    canvas.drawCircle(Offset.zero, maxR, sweepPaint);
    canvas.restore();

    // worker dot (centre)
    canvas.drawCircle(center, 11, Paint()..color = Colors.white.withValues(alpha: 0.14));
    canvas.drawCircle(center, 8, Paint()..color = Colors.white);

    // job dot (≈ -40° upper-right, between rings)
    final jobPos = center + Offset(maxR * 0.5, -maxR * 0.42);
    final ringR = 10 + pulse * 9;
    canvas.drawCircle(
      jobPos,
      ringR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = WColors.accent.withValues(alpha: (1 - pulse) * 0.8),
    );
    canvas.drawCircle(
        jobPos, 13, Paint()..color = WColors.accent.withValues(alpha: 0.4));
    canvas.drawCircle(jobPos, 10, Paint()..color = WColors.accent);
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.sweep != sweep || old.pulse != pulse;
}
