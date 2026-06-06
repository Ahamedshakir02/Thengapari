# Flutter App Implementation Plan
## Agri-Tech Marketplace — Multi-Role Mobile Platform
> Language: Flutter (Dart) | Backend: Firebase + Node.js | Target: Android-first, iOS later

---

## Overview

The platform requires **four distinct app experiences**, all built from a single Flutter codebase using role-based routing:

| App Role | Primary User | Key Actions |
|---|---|---|
| **Homeowner App** | Property owners | Book harvest, track job, view yield report, pay |
| **Worker App** | Climbers, processors, huskers | Accept jobs, navigate to site, log completion |
| **Site Manager App** | Student supervisors | Manage on-site ops, weigh yield, grade crops, trigger pings |
| **B2B Portal** | Shops, factories, traders | Browse live inventory, pre-book produce, track delivery |

All four are served from one Flutter project using role-based navigation after login.

---

## Tech Stack Decision

| Layer | Choice | Reason |
|---|---|---|
| Frontend | Flutter (Dart) | Single codebase for Android + iOS; fast UI iteration |
| Auth | Firebase Auth | Phone number OTP — most Kerala users don't use email |
| Database | Cloud Firestore | Real-time listeners needed for live job pings |
| Storage | Firebase Storage | Profile photos, crop images, yield reports |
| Backend Logic | Firebase Cloud Functions (Node.js) | Job matching, payment triggers, notifications |
| Payments | Razorpay Flutter SDK | UPI-first, widely used in Kerala |
| Maps & Navigation | Google Maps Flutter plugin | Worker navigation to homeowner address |
| Push Notifications | Firebase Cloud Messaging (FCM) | Live job ping broadcasts |
| State Management | Riverpod | Scalable, testable, good for multi-role apps |
| Local Storage | Hive | Offline caching of worker schedules and crop data |

---

## Repository Structure

```
thengapari/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── router.dart              # Role-based routing (GoRouter)
│   │   └── theme.dart               # App-wide design tokens
│   ├── core/
│   │   ├── models/                  # Shared data models
│   │   │   ├── user_model.dart
│   │   │   ├── job_model.dart
│   │   │   ├── crop_model.dart
│   │   │   └── transaction_model.dart
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   ├── job_service.dart
│   │   │   ├── payment_service.dart
│   │   │   ├── notification_service.dart
│   │   │   └── location_service.dart
│   │   └── utils/
│   │       ├── constants.dart
│   │       └── validators.dart
│   ├── features/
│   │   ├── auth/                    # Shared login/OTP flow
│   │   ├── homeowner/               # Homeowner screens
│   │   ├── worker/                  # Worker screens
│   │   ├── site_manager/            # Site manager screens
│   │   └── b2b/                     # B2B portal screens
├── functions/                       # Firebase Cloud Functions
│   ├── src/
│   │   ├── jobMatching.ts
│   │   ├── paymentWebhook.ts
│   │   └── notifications.ts
├── test/
│   ├── unit/
│   └── widget/
└── pubspec.yaml
```

---

## UI Widget System & Visual Design Specification

> This section defines every custom widget, SVG illustration, and animation used across all four app roles. Build these as a shared widget library in `lib/core/widgets/` before starting any feature screen.

---

### Color Tokens (theme.dart)

```dart
class AgriColors {
  // Primary greens — used across all roles
  static const green50  = Color(0xFFEAF3DE);
  static const green100 = Color(0xFFC0DD97);
  static const green400 = Color(0xFF639922);
  static const green600 = Color(0xFF3B6D11);
  static const green800 = Color(0xFF27500A);
  static const green900 = Color(0xFF173404);

  // Amber — warnings, in-progress states, mango crops
  static const amber100 = Color(0xFFFAC775);
  static const amber400 = Color(0xFFEF9F27);
  static const amber600 = Color(0xFFBA7517);
  static const amber800 = Color(0xFF633806);

  // Blue — B2B portal, info states
  static const blue50   = Color(0xFFE6F1FB);
  static const blue400  = Color(0xFF378ADD);
  static const blue600  = Color(0xFF185FA5);
  static const blue900  = Color(0xFF042C53);

  // Teal — worker ping screen, available states
  static const teal100  = Color(0xFF9FE1CB);
  static const teal400  = Color(0xFF1D9E75);
  static const teal600  = Color(0xFF0F6E56);

  // Neutrals
  static const surface  = Color(0xFFF5F5F0);
  static const border   = Color(0xFFEEEEEE);
}
```

---

### Custom Painter Widgets (SVG-equivalent in Flutter)

Flutter has no native SVG renderer for custom illustrations. Use `CustomPainter` for all illustrated graphics. These are the exact visuals from the app presentation mockup, translated to Flutter's Canvas API.

---

#### 1. `KeralaLandscapePainter` — Homeowner hero illustration

Used on the Homeowner home screen as the top hero banner. Depicts a Kerala residential scene with coconut palm, mango tree, and house. Hardcoded colors (physical scene — does not follow theme).

```dart
// lib/core/widgets/painters/kerala_landscape_painter.dart
class KeralaLandscapePainter extends CustomPainter {
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
    canvas.drawOval(Rect.fromCenter(center: Offset(tx, h * 0.46), width: w * 0.20, height: h * 0.22),
        Paint()..color = const Color(0xFF27500A));
    canvas.drawOval(Rect.fromCenter(center: Offset(tx - w * 0.06, h * 0.50), width: w * 0.14, height: h * 0.18),
        Paint()..color = const Color(0xFF3B6D11));
    canvas.drawOval(Rect.fromCenter(center: Offset(tx + w * 0.06, h * 0.50), width: w * 0.14, height: h * 0.18),
        Paint()..color = const Color(0xFF3B6D11));

    // Mangoes
    final mangoPaint = Paint()..color = const Color(0xFFEF9F27);
    canvas.drawOval(Rect.fromCenter(center: Offset(tx - 6, h * 0.57), width: 10, height: 14), mangoPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(tx + 8, h * 0.55), width: 10, height: 14),
        Paint()..color = const Color(0xFFBA7517));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

Usage in HomeownerHomeScreen:
```dart
CustomPaint(
  painter: KeralaLandscapePainter(),
  child: SizedBox(width: double.infinity, height: 140),
)
```

---

#### 2. `WeeklyEarningsChartPainter` — Homeowner earnings bar chart

Displayed on the Homeowner home screen below the stats row. Shows 6 weeks of earnings as a bar chart. The current week bar is highlighted in `green600`.

```dart
// lib/core/widgets/painters/weekly_earnings_chart_painter.dart
class WeeklyEarningsChartPainter extends CustomPainter {
  final List<double> weeklyEarnings; // e.g. [2100, 2800, 1900, 3200, 4100, 4280]

  WeeklyEarningsChartPainter({required this.weeklyEarnings});

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = weeklyEarnings.reduce((a, b) => a > b ? a : b);
    final chartH = size.height - 20; // leave 20px for x-axis labels
    final barUnit = size.width / weeklyEarnings.length;
    final barW = barUnit * 0.55;

    final basePaint   = Paint()..color = AgriColors.green100;
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
              fontSize: 9, color: Color(0xFF3B6D11), fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        valLabel.paint(canvas, Offset(x + barW / 2 - valLabel.width / 2, y - 13));
      }
    }
  }

  @override
  bool shouldRepaint(WeeklyEarningsChartPainter old) =>
      old.weeklyEarnings != weeklyEarnings;
}
```

---

#### 3. `RadarMapPainter` — Worker job ping proximity map

The most visually distinct widget in the app. Shown full-screen on the Worker ping screen as the background illustration. Shows concentric distance rings, the worker's position at center, the incoming job ping dot (animated), and other nearby available workers.

```dart
// lib/core/widgets/painters/radar_map_painter.dart
class RadarMapPainter extends CustomPainter {
  final double pingAnimValue; // 0.0 → 1.0, drives the pulse ring animation

  RadarMapPainter({required this.pingAnimValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Distance rings: 1km, 3km, 5km
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (final r in [size.width * 0.18, size.width * 0.36, size.width * 0.48]) {
      canvas.drawCircle(Offset(cx, cy), r, ringPaint);
    }

    // Crosshair lines
    final crossPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), crossPaint);
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), crossPaint);

    // Ring distance labels
    _drawLabel(canvas, '1 km', Offset(cx + size.width * 0.19, cy - 10),
        Colors.white.withOpacity(0.35), 9);
    _drawLabel(canvas, '3 km', Offset(cx + size.width * 0.37, cy - 10),
        Colors.white.withOpacity(0.35), 9);

    // Other available workers (dimmed teal dots)
    final otherWorkerPaint = Paint()..color = const Color(0xFF5DCAA5).withOpacity(0.6);
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
      jobPos, pulseR,
      Paint()..color = const Color(0xFFFAC775).withOpacity(1.0 - pingAnimValue * 0.8),
    );
    canvas.drawCircle(jobPos, 9, Paint()..color = const Color(0xFFFAC775));
    canvas.drawCircle(jobPos, 5, Paint()..color = const Color(0xFF633806));

    // Job ping label
    _drawLabel(canvas, 'Job ping', Offset(jobPos.dx - 18, jobPos.dy - 22),
        const Color(0xFFFAC775), 10);

    // Worker dot at center (you)
    canvas.drawCircle(Offset(cx, cy), 8,
        Paint()..color = Colors.white.withOpacity(0.95));
    canvas.drawCircle(Offset(cx, cy), 4,
        Paint()..color = const Color(0xFF0F6E56));
    _drawLabel(canvas, 'You', Offset(cx - 8, cy + 12),
        Colors.white.withOpacity(0.6), 9);

    // Distance line from center to job ping
    canvas.drawLine(
      Offset(cx, cy), jobPos,
      Paint()
        ..color = const Color(0xFFFAC775).withOpacity(0.4)
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(RadarMapPainter old) => old.pingAnimValue != pingAnimValue;
}
```

**Animating the pulse** — wire this into the Worker ping screen:
```dart
class _WorkerPingScreenState extends State<WorkerPingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) => CustomPaint(
        painter: RadarMapPainter(pingAnimValue: _pulseCtrl.value),
        child: SizedBox(width: double.infinity, height: 180),
      ),
    );
  }
}
```

---

#### 4. `YieldDonutPainter` — Site manager crop grade breakdown

A donut chart rendered with `CustomPainter` using `canvas.drawArc()`. Shows Grade A / B / Tender split for the current harvest. The center displays total unit count.

```dart
// lib/core/widgets/painters/yield_donut_painter.dart
class YieldDonutPainter extends CustomPainter {
  final int gradeA;
  final int gradeB;
  final int tender;

  YieldDonutPainter({required this.gradeA, required this.gradeB, required this.tender});

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
        rect, startAngle, sweep - 0.02, false,
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
      ('Tender',  '$tender units', const Color(0xFFDDEFD0)),
    ];
    final lx = size.width * 0.58;
    for (int i = 0; i < legendItems.length; i++) {
      final ly = cy - 22.0 + i * 22.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(lx, ly, 10, 10), const Radius.circular(2)),
        Paint()..color = legendItems[i].$3,
      );
      _drawText(canvas, Offset(lx + 14, ly - 1), legendItems[i].$1,
          const Color(0xFF444441), 11, FontWeight.w500);
      _drawText(canvas, Offset(lx + 14, ly + 12), legendItems[i].$2,
          const Color(0xFF888888), 10, FontWeight.w400);
    }
  }

  void _drawCenteredText(Canvas canvas, Offset center, String text,
      Color color, double size, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color, fontWeight: weight)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawText(Canvas canvas, Offset pos, String text,
      Color color, double size, FontWeight weight) {
    (TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color, fontWeight: weight)),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, pos);
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
```

---

#### 5. `SavingsBarChartPainter` — B2B savings per crop

Shows the percentage saved vs. wholesale price for each crop type available on the platform. Used on the B2B Business Dashboard. The tallest bar (best saving) is rendered in `green600`; others in `green100`.

```dart
// lib/core/widgets/painters/savings_bar_chart_painter.dart
class SavingsBarChartPainter extends CustomPainter {
  final Map<String, double> savingsPercent;
  // e.g. {'Coconut': 14, 'Mango': 10, 'Pepper': 8, 'Jackfruit': 20}

  SavingsBarChartPainter({required this.savingsPercent});

  @override
  void paint(Canvas canvas, Size size) {
    final entries = savingsPercent.entries.toList();
    final maxVal  = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final chartH  = size.height - 22;
    final barUnit = (size.width - 30) / entries.length;
    final barW    = barUnit * 0.55;

    // Dashed reference lines at 10% and 20%
    final dashPaint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..strokeWidth = 0.5;
    for (final pct in [10.0, 20.0]) {
      final y = chartH - (pct / maxVal) * chartH * 0.9;
      _drawDashedLine(canvas, Offset(28, y), Offset(size.width, y), dashPaint);
      (TextPainter(
        text: TextSpan(text: '${pct.toInt()}%',
            style: const TextStyle(fontSize: 9, color: Color(0xFFAAAAAA))),
        textDirection: TextDirection.ltr,
      )..layout()).paint(canvas, Offset(0, y - 6));
    }

    for (int i = 0; i < entries.length; i++) {
      final val  = entries[i].value;
      final barH = (val / maxVal) * chartH * 0.9;
      final x    = 30 + i * barUnit + (barUnit - barW) / 2;
      final y    = chartH - barH;
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
      )..layout()).paint(canvas, Offset(x + barW / 2 - 8, y - 13));

      // Crop name label
      (TextPainter(
        text: TextSpan(text: entries[i].key,
            style: const TextStyle(fontSize: 8, color: Color(0xFF888888))),
        textDirection: TextDirection.ltr,
      )..layout()).paint(canvas, Offset(x - 2, chartH + 4));
    }

    // Baseline
    canvas.drawLine(Offset(28, chartH), Offset(size.width, chartH),
        Paint()..color = const Color(0xFFEEEEEE)..strokeWidth = 0.5);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLen = 4.0;
    const gapLen  = 3.0;
    final dx = end.dx - start.dx;
    final total = dx;
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
```

---

### Custom Composite Widgets (Flutter Widget classes)

These wrap the painters above into full reusable `Widget` objects with surrounding UI.

---

#### `HeroLandscapeWidget`

```dart
// lib/core/widgets/hero_landscape_widget.dart
class HeroLandscapeWidget extends StatelessWidget {
  final String greeting;
  final String subtitle;

  const HeroLandscapeWidget({
    required this.greeting,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: KeralaLandscapePainter(),
          child: const SizedBox(width: double.infinity, height: 140),
        ),
        Positioned(
          left: 16, top: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AgriColors.green100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(greeting,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF27500A), fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF173404), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

#### `CropInventoryRow`

Horizontal scrollable row of crop chips shown in the hero area. Each chip shows the crop name and count/quantity.

```dart
class CropInventoryRow extends StatelessWidget {
  final List<CropSummary> crops;

  const CropInventoryRow({required this.crops, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: crops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AgriColors.green100, width: 0.5),
          ),
          child: Row(
            children: [
              Text(crops[i].icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(crops[i].name,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF3B6D11), fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Text(crops[i].quantity,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF639922))),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

#### `JobStatusCard`

Used on the Homeowner home screen for active and scheduled jobs. Uses a `LinearProgressIndicator` for the in-progress state.

```dart
class JobStatusCard extends StatelessWidget {
  final String title;
  final JobStatus status;
  final String detail;
  final String rightDetail;
  final double? progress; // 0.0–1.0, null if not in-progress

  const JobStatusCard({
    required this.title,
    required this.status,
    required this.detail,
    required this.rightDetail,
    this.progress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgriColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              JobStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(detail, style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
              const Spacer(),
              Text(rightDetail, style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: AgriColors.green50,
                color: AgriColors.green400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

#### `JobPingFullScreen` (Worker)

The most critical conversion screen. Should feel urgent. `RadarMapPainter` fills the background; the job details card, countdown timer, and action buttons sit on top.

```dart
class JobPingFullScreen extends ConsumerStatefulWidget {
  final JobPing ping;
  const JobPingFullScreen({required this.ping, super.key});

  @override
  ConsumerState<JobPingFullScreen> createState() => _JobPingFullScreenState();
}

class _JobPingFullScreenState extends ConsumerState<JobPingFullScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Timer _countdown;
  int _seconds = 45;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        ref.read(jobServiceProvider).timeoutPing(widget.ping.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F6E56),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => CustomPaint(
              painter: RadarMapPainter(pingAnimValue: _pulse.value),
              child: SizedBox(width: double.infinity, height: 220),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildJobCard(),
                _buildCountdownTimer(),
                const Spacer(),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ... _buildHeader, _buildJobCard, _buildCountdownTimer, _buildActionButtons
}
```

---

#### `OnSiteChecklistWidget` (Site Manager)

A stateful checklist that writes each step's timestamp to Firestore as the Site Manager taps through. Visual states: done (green), active (amber), pending (gray).

```dart
class OnSiteChecklistWidget extends ConsumerWidget {
  final String jobId;
  const OnSiteChecklistWidget({required this.jobId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = ref.watch(jobStepsProvider(jobId));
    return Column(
      children: steps.map((step) => ChecklistItem(
        step: step,
        onTap: step.status == StepStatus.active
            ? () => ref.read(jobServiceProvider).completeStep(jobId, step.id)
            : null,
      )).toList(),
    );
  }
}
```

---

#### `BroadcastPingButton` (Site Manager)

Animated button that, when tapped, sends the FCM broadcast to all nearby processors. Shows real-time incoming Accept responses as a stream of worker chips below the button.

```dart
class BroadcastPingButton extends ConsumerWidget {
  final String jobId;
  const BroadcastPingButton({required this.jobId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pingState = ref.watch(broadcastPingProvider(jobId));
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: pingState.isBroadcasting
          ? _buildLiveResponses(pingState.responses)
          : _buildTriggerButton(context, ref),
    );
  }

  Widget _buildTriggerButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(jobServiceProvider).broadcastProcessorPing(jobId),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AgriColors.green50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AgriColors.green100, width: 0.5),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AgriColors.green400, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.broadcast_on_personal, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Ping processors now',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF173404))),
            Text('${pingState.nearbyCount} workers within 3 km',
                style: const TextStyle(fontSize: 10, color: Color(0xFF3B6D11))),
          ]),
        ]),
      ),
    );
  }
}
```

---

#### `LiveInventoryTile` (B2B)

Each crop listing in the B2B inventory browser. Shows the savings badge prominently — it is the primary conversion hook.

```dart
class LiveInventoryTile extends StatelessWidget {
  final CropListing listing;
  final VoidCallback onPreBook;

  const LiveInventoryTile({required this.listing, required this.onPreBook, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: listing.bgColor, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(listing.icon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(listing.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text('${listing.harvestedLabel} · ${listing.location} · ${listing.quantity}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(listing.priceLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF185FA5))),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AgriColors.green50,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(listing.savingLabel,
                style: const TextStyle(fontSize: 9, color: Color(0xFF27500A))),
          ),
        ]),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onPreBook,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF185FA5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Pre-book',
                style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ),
      ]),
    );
  }
}
```

---

### Updated Repository Structure (with widget layer)

```
lib/
├── core/
│   ├── widgets/
│   │   ├── painters/
│   │   │   ├── kerala_landscape_painter.dart
│   │   │   ├── weekly_earnings_chart_painter.dart
│   │   │   ├── radar_map_painter.dart
│   │   │   ├── yield_donut_painter.dart
│   │   │   └── savings_bar_chart_painter.dart
│   │   ├── hero_landscape_widget.dart
│   │   ├── crop_inventory_row.dart
│   │   ├── job_status_card.dart
│   │   ├── job_status_badge.dart
│   │   ├── broadcast_ping_button.dart
│   │   ├── on_site_checklist_widget.dart
│   │   └── live_inventory_tile.dart
│   ├── models/
│   ├── services/
│   └── utils/
├── features/
│   ├── homeowner/
│   │   └── screens/
│   │       ├── home_screen.dart        ← uses HeroLandscapeWidget, WeeklyEarningsChartPainter
│   │       ├── book_harvest_screen.dart
│   │       ├── job_tracker_screen.dart
│   │       ├── yield_report_screen.dart
│   │       └── amc_screen.dart
│   ├── worker/
│   │   └── screens/
│   │       ├── worker_home_screen.dart
│   │       ├── job_ping_screen.dart    ← uses RadarMapPainter (animated)
│   │       ├── navigation_screen.dart
│   │       └── earnings_screen.dart    ← uses WeeklyEarningsChartPainter
│   ├── site_manager/
│   │   └── screens/
│   │       ├── job_queue_screen.dart
│   │       ├── on_site_screen.dart     ← uses OnSiteChecklistWidget, YieldDonutPainter
│   │       ├── yield_weigh_screen.dart
│   │       └── byproduct_screen.dart
│   └── b2b/
│       └── screens/
│           ├── inventory_screen.dart   ← uses LiveInventoryTile
│           ├── order_screen.dart
│           └── dashboard_screen.dart  ← uses SavingsBarChartPainter
```

---

### Updated Package List (add to existing)

| Package | Purpose |
|---|---|
| `flutter_animate` | Micro-animations on cards, ping screen entrance |
| `lottie` | Loading states and success animations (harvest complete, payment done) |
| `shimmer` | Skeleton loading placeholders while Firestore data loads |
| `cached_network_image` | Profile photos and crop images — cache to avoid reload flicker |
| `badges` | Notification count badges on bottom nav items |
| `flutter_svg` | Render any SVG assets (icons, logos) that can't be done with CustomPainter |
| `percent_indicator` | Circular progress for worker reliability score display |
| `smooth_page_indicator` | Screen dots indicator on onboarding flow |
| `auto_size_text` | Prevent text overflow in tight card layouts |

---

### Animation Specifications

| Widget | Animation type | Duration | Trigger |
|---|---|---|---|
| Radar ping pulse | `AnimationController.repeat()` scale + opacity | 1.4s loop | Worker ping screen open |
| Job ping screen entrance | Slide up from bottom | 300ms | FCM notification received |
| Broadcast ping button | Scale bounce on tap | 180ms | Tap |
| Checklist item completion | Cross-fade done state | 250ms | Step marked complete |
| Bar chart draw-in | Height tween from 0 to value | 600ms staggered | Screen mount |
| Donut chart draw-in | Sweep angle tween from 0 | 800ms ease-out | Screen mount |
| Inventory tile pre-book | Button scale press | 100ms | Tap |
| Payment success | Lottie confetti | 2s once | Payment confirmed |

---

---

### Missing Widget Definitions

These widgets are referenced throughout the screen code above but need their own explicit definitions.

---

#### `JobStatusBadge`

Colored pill label used on every job card. Status drives color automatically.

```dart
// lib/core/widgets/job_status_badge.dart
enum JobStatus { assigned, enRoute, inProgress, processing, complete, scheduled }

extension JobStatusStyle on JobStatus {
  String get label => switch (this) {
    JobStatus.assigned    => 'Assigned',
    JobStatus.enRoute     => 'En route',
    JobStatus.inProgress  => 'In progress',
    JobStatus.processing  => 'Processing',
    JobStatus.complete    => 'Complete',
    JobStatus.scheduled   => 'Scheduled',
  };
  Color get bg => switch (this) {
    JobStatus.inProgress  => const Color(0xFFFAEEDA),
    JobStatus.enRoute     => const Color(0xFFE6F1FB),
    JobStatus.complete    => const Color(0xFFEAF3DE),
    JobStatus.scheduled   => const Color(0xFFEAF3DE),
    JobStatus.assigned    => const Color(0xFFEEEDFE),
    JobStatus.processing  => const Color(0xFFFAEEDA),
  };
  Color get text => switch (this) {
    JobStatus.inProgress  => const Color(0xFF633806),
    JobStatus.enRoute     => const Color(0xFF0C447C),
    JobStatus.complete    => const Color(0xFF27500A),
    JobStatus.scheduled   => const Color(0xFF27500A),
    JobStatus.assigned    => const Color(0xFF3C3489),
    JobStatus.processing  => const Color(0xFF633806),
  };
}

class JobStatusBadge extends StatelessWidget {
  final JobStatus status;
  const JobStatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: status.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status.label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: status.text)),
    );
  }
}
```

---

#### `StatCard`

Metric summary card. Used in pairs on the Homeowner and Worker home screens.

```dart
// lib/core/widgets/stat_card.dart
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const StatCard({
    required this.value,
    required this.label,
    this.valueColor = const Color(0xFF3B6D11),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AgriColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: valueColor)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
        ],
      ),
    );
  }
}
```

Usage on homeowner home screen:
```dart
Row(children: [
  Expanded(child: StatCard(value: '₹4,280', label: 'Yield earned')),
  const SizedBox(width: 8),
  Expanded(child: StatCard(
    value: '0.8 kg',
    label: 'Weight saved vs before',
    valueColor: AgriColors.amber600,
  )),
])
```

---

#### `CountdownTimerWidget`

Used on the Worker ping screen. Shows a live decrementing countdown with a "Respond within" label.

```dart
// lib/core/widgets/countdown_timer_widget.dart
class CountdownTimerWidget extends StatelessWidget {
  final int seconds;

  const CountdownTimerWidget({required this.seconds, super.key});

  Color get _urgencyColor {
    if (seconds > 20) return Colors.white;
    if (seconds > 10) return const Color(0xFFFAC775);
    return const Color(0xFFF09595);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Respond within',
                  style: TextStyle(fontSize: 10, color: Color(0xFF9FE1CB))),
              const SizedBox(height: 2),
              Text('${seconds}s',
                  style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w500, color: _urgencyColor,
                  )),
            ],
          ),
          const Spacer(),
          // Three dot pulse indicator
          Row(
            children: List.generate(3, (i) =>
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF5DCAA5)
                      .withOpacity(1.0 - i * 0.35),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

#### `WorkerJobDetailRow`

A single row in the job detail card on the Worker ping screen. Icon + label + right-aligned value.

```dart
// lib/core/widgets/worker_job_detail_row.dart
class WorkerJobDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const WorkerJobDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFEAF3DE), width: 0.5)),
      ),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: AgriColors.green50,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 14, color: AgriColors.green600),
        ),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF3B6D11))),
        const Spacer(),
        Text(value,
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF173404),
            )),
      ]),
    );
  }
}
```

---

#### `WorkerAvailabilityToggle`

Online/Offline toggle on the Worker home screen. Writes availability status to Firestore so the job matching function knows who to ping.

```dart
// lib/core/widgets/worker_availability_toggle.dart
class WorkerAvailabilityToggle extends ConsumerWidget {
  const WorkerAvailabilityToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(workerAvailabilityProvider);
    return GestureDetector(
      onTap: () => ref.read(workerAvailabilityProvider.notifier).toggle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isOnline ? AgriColors.green50 : AgriColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isOnline ? AgriColors.green100 : AgriColors.border,
            width: 0.5,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AgriColors.green400 : const Color(0xFFB4B2A9),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isOnline ? AgriColors.green600 : const Color(0xFF5F5E5A),
            ),
          ),
        ]),
      ),
    );
  }
}
```

---

#### `SavingsBandWidget` (B2B)

The green savings banner shown at the top of the B2B inventory screen. Displays total cumulative savings vs. wholesale prices for the current month.

```dart
// lib/core/widgets/savings_band_widget.dart
class SavingsBandWidget extends StatelessWidget {
  final double savingsAmount;
  const SavingsBandWidget({required this.savingsAmount, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AgriColors.blue50,
      child: Row(
        children: [
          Text('Your savings vs wholesale this month',
              style: const TextStyle(fontSize: 10, color: Color(0xFF185FA5))),
          const Spacer(),
          Text(
            '₹${savingsAmount.toStringAsFixed(0)} saved',
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0C447C),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### Data Models

All models use `freezed` + `json_serializable` for immutability and Firestore serialization.

```dart
// lib/core/models/crop_summary.dart
@freezed
class CropSummary with _$CropSummary {
  const factory CropSummary({
    required String name,
    required String icon,
    required String quantity,      // "×24", "×8", "~2 kg"
    required DateTime nextHarvest,
  }) = _CropSummary;
}

// lib/core/models/job_model.dart
@freezed
class HarvestJob with _$HarvestJob {
  const factory HarvestJob({
    required String id,
    required String homeownerId,
    required String siteManagerId,
    required List<String> workerIds,
    required List<String> cropTypes,
    required JobStatus status,
    required GeoPoint location,
    required DateTime scheduledAt,
    DateTime? completedAt,
    double? yieldKg,
    int? gradeA,
    int? gradeB,
    int? tender,
    double? earningsAmount,
  }) = _HarvestJob;
}

// lib/core/models/job_ping.dart
@freezed
class JobPing with _$JobPing {
  const factory JobPing({
    required String id,
    required String jobId,
    required String cropType,
    required double payoutAmount,
    required double distanceKm,
    required double estimatedHours,
    required String siteManagerName,
    required double siteManagerRating,
    required GeoPoint jobLocation,
    required DateTime expiresAt,
  }) = _JobPing;
}

// lib/core/models/crop_listing.dart (B2B)
@freezed
class CropListing with _$CropListing {
  const factory CropListing({
    required String id,
    required String name,
    required String grade,         // "Grade A", "Alphonso", "dry"
    required String icon,
    required Color bgColor,
    required String harvestedLabel,
    required String location,
    required String quantity,
    required String priceLabel,    // "₹18/pc"
    required String savingLabel,   // "↓12% vs market"
    required double savingPercent,
  }) = _CropListing;
}

// lib/core/models/job_step.dart (Site Manager checklist)
@freezed
class JobStep with _$JobStep {
  const factory JobStep({
    required String id,
    required String title,
    required StepStatus status,
    DateTime? completedAt,
    String? note,
  }) = _JobStep;
}

enum StepStatus { done, active, pending }
```

---

### Key Riverpod Providers

```dart
// lib/core/providers/auth_provider.dart
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// lib/core/providers/job_provider.dart
final activeJobProvider = StreamProvider.family<HarvestJob?, String>((ref, userId) {
  return ref.watch(jobServiceProvider).watchActiveJob(userId);
});

final jobStepsProvider = StreamProvider.family<List<JobStep>, String>((ref, jobId) {
  return FirebaseFirestore.instance
      .collection('jobs/$jobId/steps')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map((d) => JobStep.fromJson(d.data())).toList());
});

// lib/core/providers/worker_provider.dart
final workerAvailabilityProvider =
    StateNotifierProvider<WorkerAvailabilityNotifier, bool>((ref) {
  return WorkerAvailabilityNotifier(ref.watch(authServiceProvider).currentUserId);
});

class WorkerAvailabilityNotifier extends StateNotifier<bool> {
  final String userId;
  WorkerAvailabilityNotifier(this.userId) : super(false);

  Future<void> toggle() async {
    state = !state;
    await FirebaseFirestore.instance
        .collection('workers')
        .doc(userId)
        .update({'isOnline': state, 'lastSeen': FieldValue.serverTimestamp()});
  }
}

// lib/core/providers/b2b_provider.dart
final liveInventoryProvider = StreamProvider<List<CropListing>>((ref) {
  return FirebaseFirestore.instance
      .collection('inventory')
      .where('available', isEqualTo: true)
      .orderBy('harvestedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => CropListing.fromJson(d.data())).toList());
});

final monthlySavingsProvider = FutureProvider<double>((ref) async {
  final uid = ref.watch(authStateProvider).value?.uid;
  final snap = await FirebaseFirestore.instance
      .collection('b2b_orders')
      .where('buyerId', isEqualTo: uid)
      .where('createdAt', isGreaterThan: DateTime.now().subtract(const Duration(days: 30)))
      .get();
  return snap.docs.fold(0.0, (sum, d) => sum + (d['savingsAmount'] as num));
});

// lib/core/providers/broadcast_provider.dart
final broadcastPingProvider =
    StateNotifierProvider.family<BroadcastPingNotifier, BroadcastPingState, String>(
        (ref, jobId) => BroadcastPingNotifier(jobId));
```

---

### Screen Assembly Code

Full screen compositions showing how all the widgets fit together.

---

#### Homeowner Home Screen

```dart
// lib/features/homeowner/screens/home_screen.dart
class HomeownerHomeScreen extends ConsumerWidget {
  const HomeownerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user    = ref.watch(authStateProvider).value;
    final activeJob = ref.watch(activeJobProvider(user!.uid));
    final earnings  = ref.watch(monthlyEarningsProvider(user.uid));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Hero landscape illustration with greeting
            HeroLandscapeWidget(
              greeting: 'Good morning, ${user.firstName}',
              subtitle: 'Your harvest is ready to schedule',
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  const SizedBox(height: 8),

                  // Crop chip inventory row
                  const CropInventoryRow(crops: [...]),

                  const SizedBox(height: 14),

                  // Stats row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(children: [
                      Expanded(child: StatCard(
                        value: earnings.when(
                          data: (v) => '₹${v.toStringAsFixed(0)}',
                          loading: () => '...',
                          error: (_, __) => '--',
                        ),
                        label: 'Yield earned',
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: StatCard(
                        value: '0.8 kg',
                        label: 'Weight saved vs before',
                        valueColor: AgriColors.amber600,
                      )),
                    ]),
                  ),

                  const SizedBox(height: 14),

                  // Weekly earnings chart
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('This month',
                          style: TextStyle(fontSize: 10, color: Color(0xFF888888),
                              fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: CustomPaint(
                      painter: WeeklyEarningsChartPainter(
                        weeklyEarnings: [2100, 2800, 1900, 3200, 4100, 4280],
                      ),
                      child: const SizedBox(width: double.infinity, height: 85),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Active job section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Active job',
                          style: TextStyle(fontSize: 10, color: Color(0xFF888888),
                              fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 6),

                  activeJob.when(
                    data: (job) => job != null
                        ? JobStatusCard(
                            title: '${job.cropTypes.join(' + ')} harvest',
                            status: job.status,
                            detail: 'Site Manager: Arjun K.',
                            rightDetail: '2.1 km away',
                            progress: 0.60,
                          )
                        : const SizedBox.shrink(),
                    loading: () => const ShimmerJobCard(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const HomeownerBottomNav(currentIndex: 0),
    );
  }
}
```

---

#### Worker Ping Screen (full composition)

```dart
// lib/features/worker/screens/job_ping_screen.dart
class JobPingScreen extends ConsumerStatefulWidget {
  final JobPing ping;
  const JobPingScreen({required this.ping, super.key});

  @override
  ConsumerState<JobPingScreen> createState() => _JobPingScreenState();
}

class _JobPingScreenState extends ConsumerState<JobPingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Timer _countdown;
  int _seconds = 45;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        ref.read(jobServiceProvider).timeoutPing(widget.ping.id);
        context.pop();
      }
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _countdown.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F6E56),
      body: SafeArea(
        child: Column(children: [

          // Radar map background
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => CustomPaint(
              painter: RadarMapPainter(pingAnimValue: _pulse.value),
              child: const SizedBox(width: double.infinity, height: 200),
            ),
          ),

          // Ping header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('NEW JOB PING',
                  style: TextStyle(color: Color(0xFF5DCAA5), fontSize: 10,
                      fontWeight: FontWeight.w500, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text('${widget.ping.cropType} needed',
                  style: const TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w500)),
              Text(widget.ping.locationName,
                  style: const TextStyle(color: Color(0xFF9FE1CB), fontSize: 11)),
            ]),
          ),

          // Job details card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              WorkerJobDetailRow(
                icon: Icons.payments_outlined,
                label: 'Payout',
                value: '₹${widget.ping.payoutAmount.toStringAsFixed(0)}',
              ),
              WorkerJobDetailRow(
                icon: Icons.access_time_outlined,
                label: 'Est. duration',
                value: '~${widget.ping.estimatedHours}h',
              ),
              WorkerJobDetailRow(
                icon: Icons.location_on_outlined,
                label: 'Distance',
                value: '${widget.ping.distanceKm.toStringAsFixed(1)} km',
              ),
              WorkerJobDetailRow(
                icon: Icons.grass_outlined,
                label: 'Crop',
                value: widget.ping.cropType,
              ),
              WorkerJobDetailRow(
                icon: Icons.star_outline,
                label: 'Site Manager',
                value: '${widget.ping.siteManagerName} ⭐${widget.ping.siteManagerRating}',
                isLast: true,
              ),
            ]),
          ),

          const SizedBox(height: 10),

          // Countdown timer
          CountdownTimerWidget(seconds: _seconds),

          const Spacer(),

          // Accept / Decline buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(jobServiceProvider).declinePing(widget.ping.id);
                    context.pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    ref.read(jobServiceProvider).acceptPing(widget.ping.id);
                    context.pushReplacement('/worker/navigate/${widget.ping.jobId}');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F6E56),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Accept job', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
```

---

#### Site Manager On-Site Screen (full composition)

```dart
// lib/features/site_manager/screens/on_site_screen.dart
class OnSiteScreen extends ConsumerWidget {
  final String jobId;
  const OnSiteScreen({required this.jobId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(jobByIdProvider(jobId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [

          // Header
          Container(
            color: AgriColors.green50,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: job.when(
              data: (j) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('On-site: ${j.homeownerName}\'s property',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                        color: Color(0xFF173404))),
                Text('${j.cropTypes.join(' harvest · ')} · Started ${j.startTime}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF3B6D11))),
              ]),
              loading: () => const ShimmerText(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [

                // Checklist
                OnSiteChecklistWidget(jobId: jobId),

                const SizedBox(height: 4),

                // Yield donut chart
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Consumer(
                    builder: (_, ref, __) {
                      final yield_ = ref.watch(yieldDataProvider(jobId));
                      return yield_.when(
                        data: (y) => Column(children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Yield logged so far',
                                style: TextStyle(fontSize: 10, color: Color(0xFF888888),
                                    fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AgriColors.green600,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(children: [
                              Text('${y.totalKg.toStringAsFixed(1)} kg',
                                  style: const TextStyle(color: Colors.white, fontSize: 26,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 12),
                              CustomPaint(
                                painter: YieldDonutPainter(
                                  gradeA: y.gradeA,
                                  gradeB: y.gradeB,
                                  tender: y.tender,
                                ),
                                child: const SizedBox(width: double.infinity, height: 120),
                              ),
                            ]),
                          ),
                        ]),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                  ),
                ),

                // Broadcast ping button
                BroadcastPingButton(jobId: jobId),
                const SizedBox(height: 14),
              ]),
            ),
          ),

          const SiteManagerBottomNav(currentIndex: 0),
        ]),
      ),
    );
  }
}
```

---

#### B2B Inventory Screen (full composition)

```dart
// lib/features/b2b/screens/inventory_screen.dart
class B2BInventoryScreen extends ConsumerWidget {
  const B2BInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(liveInventoryProvider);
    final savings   = ref.watch(monthlySavingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [

          // Dark blue header
          Container(
            color: const Color(0xFF042C53),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Live produce inventory',
                  style: TextStyle(color: Colors.white, fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text('Fresh from source · ${DateTime.now().day} ${_monthName()}',
                  style: const TextStyle(color: Color(0xFF85B7EB), fontSize: 11)),
            ]),
          ),

          // Savings band
          savings.when(
            data: (s) => SavingsBandWidget(savingsAmount: s),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Savings bar chart
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: CustomPaint(
              painter: SavingsBarChartPainter(
                savingsPercent: const {
                  'Coconut': 14, 'Mango': 10, 'Pepper': 8, 'Jackfruit': 20,
                },
              ),
              child: const SizedBox(width: double.infinity, height: 95),
            ),
          ),

          // Section label
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Available now',
                  style: TextStyle(fontSize: 10, color: Color(0xFF888888),
                      fontWeight: FontWeight.w500, letterSpacing: 0.5)),
            ),
          ),

          // Live inventory list
          Expanded(
            child: inventory.when(
              data: (items) => ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => LiveInventoryTile(
                  listing: items[i],
                  onPreBook: () => context.push('/b2b/prebook/${items[i].id}'),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Could not load inventory')),
            ),
          ),

          const B2BBottomNav(currentIndex: 0),
        ]),
      ),
    );
  }
}
```

---

### pubspec.yaml (complete dependencies)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Routing
  go_router: ^13.0.0

  # State management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Firebase
  firebase_core: ^2.27.0
  firebase_auth: ^4.19.0
  cloud_firestore: ^4.17.0
  firebase_storage: ^11.7.0
  firebase_messaging: ^14.9.0
  firebase_crashlytics: ^3.5.0
  firebase_analytics: ^10.10.0

  # Data / serialization
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

  # Maps & location
  google_maps_flutter: ^2.6.0
  geolocator: ^11.0.0
  geocoding: ^3.0.0

  # Payments
  razorpay_flutter: ^1.3.5

  # Local storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Charts / painters
  fl_chart: ^0.67.0

  # UI & animations
  flutter_animate: ^4.5.0
  lottie: ^3.1.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.1
  badges: ^3.1.2
  flutter_svg: ^2.0.10
  percent_indicator: ^4.2.3
  smooth_page_indicator: ^1.1.0
  auto_size_text: ^3.0.0

  # Utilities
  flutter_image_compress: ^2.2.0
  image_picker: ^1.1.0
  share_plus: ^9.0.0
  url_launcher: ^6.3.0
  intl: ^0.19.0
  flutter_dotenv: ^5.1.0

  # Localisation
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mocktail: ^1.0.3
```

---

## Phase 1 — Foundation (Week 1–3)

### 1.1 Project Setup
- [ ] Initialize Flutter project with null safety enabled
- [ ] Configure Firebase project (separate dev and prod environments)
- [ ] Set up GoRouter for role-based navigation
- [ ] Implement Riverpod as global state manager
- [ ] Set up Hive for local offline storage
- [ ] Configure flavors: `dev`, `staging`, `production`

### 1.2 Design System & Widget Library (build in this order)

**Colors & theme**
- [ ] Add `AgriColors` class to `lib/app/theme.dart` with all hex values from the color token table
- [ ] Define `ThemeData` with `ColorScheme.fromSeed` using `AgriColors.green400` as seed
- [ ] Set `fontFamily` to Poppins for headings, system sans fallback

**CustomPainters** — build these first, they have no dependencies
- [ ] `KeralaLandscapePainter`
- [ ] `WeeklyEarningsChartPainter`
- [ ] `RadarMapPainter` (with `pingAnimValue` animation param)
- [ ] `YieldDonutPainter`
- [ ] `SavingsBarChartPainter`

**Primitive widgets** — pure UI, no business logic
- [ ] `StatCard`, `JobStatusBadge`, `WorkerJobDetailRow`
- [ ] `CountdownTimerWidget`, `SavingsBandWidget`, `WorkerAvailabilityToggle`

**Composite widgets** — assemble primitives + painters
- [ ] `HeroLandscapeWidget`, `CropInventoryRow`, `JobStatusCard`
- [ ] `OnSiteChecklistWidget`, `BroadcastPingButton`, `LiveInventoryTile`

**Shared UI**
- [ ] `AppButton` (primary / secondary / ghost), `AppTextField`, `UserAvatarWidget`
- [ ] `ShimmerJobCard` / `ShimmerText` — loading skeletons
- [ ] Role-specific bottom nav bars: `HomeownerBottomNav`, `WorkerBottomNav`, `SiteManagerBottomNav`, `B2BBottomNav`

### 1.3 Authentication Flow (Shared Across All Roles)
- [ ] Phone number input screen with country code picker
- [ ] Firebase OTP verification screen (6-digit input with auto-read on Android)
- [ ] Role selection screen (shown only on first login)
- [ ] User profile creation screen (name, photo, district, role-specific fields)
- [ ] Token-based session persistence using Firebase Auth state listener

```dart
// Role-based routing logic (router.dart)
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    redirect: (context, state) {
      if (authState.isLoading) return '/splash';
      if (!authState.isAuthenticated) return '/login';
      return switch (authState.user?.role) {
        UserRole.homeowner => '/homeowner/home',
        UserRole.worker => '/worker/home',
        UserRole.siteManager => '/manager/home',
        UserRole.b2b => '/b2b/home',
        _ => '/login',
      };
    },
    routes: [...],
  );
});
```

---

## Phase 2 — Homeowner App (Week 4–6)

### Screens
- **Home Dashboard**
  - Tree inventory summary (count by type, next harvest due dates)
  - Active job status card (real-time updates via Firestore listener)
  - Quick-book CTA

- **Book a Harvest**
  - Select crop type(s) from tree inventory
  - Select preferred date (respects seasonal crop calendar)
  - Optional notes (ripe vs. unripe preference, access instructions)
  - Estimated yield and price preview
  - Confirm booking → triggers Site Manager assignment

- **Live Job Tracker**
  - Real-time status: `Assigned → Site Manager En Route → In Progress → Processing → Complete`
  - Live map showing Site Manager and assigned worker locations
  - Photo updates from the site (uploaded by Site Manager mid-job)

- **Yield Report**
  - Post-harvest summary: weight harvested, crop grade breakdown, weight lost if any
  - Byproduct generated and routed (e.g., "12 kg husks sent to Ravi Coir Factory")
  - Total earnings if homeowner is selling yield through the platform

- **Payments**
  - Razorpay integration for service fee payment
  - UPI deep-link support (GPay, PhonePe, Paytm)
  - Transaction history

- **AMC Subscription**
  - View active subscription plan
  - Upcoming auto-dispatches calendar view
  - Upgrade / renew subscription

### Key Firestore Collections
```
/users/{userId}
/homeowners/{homeownerId}/trees/{treeId}
/jobs/{jobId}
/jobs/{jobId}/statusUpdates/{updateId}
```

---

## Phase 3 — Worker App (Week 7–9)

### Screens
- **Home Dashboard**
  - Today's earnings
  - Upcoming confirmed jobs
  - Reliability score display (stars/percentage)
  - Availability toggle (Online / Offline)

- **Live Job Ping Screen** *(Most Critical Feature)*
  - Full-screen alert when a job ping arrives within 5 km radius
  - Shows: crop type, distance, estimated duration, payout amount
  - Accept / Decline buttons with 45-second countdown timer
  - If declined or timeout → ping sent to next available worker

- **Navigation to Site**
  - Google Maps embedded navigation
  - Site Manager contact (tap-to-call)
  - Job details and special instructions

- **Job Completion Flow**
  - Photo upload: before/after crop photos
  - Quantity logged (entered by Site Manager, confirmed by worker)
  - Digital signature / OTP confirmation from Site Manager to mark complete
  - Instant UPI payout trigger on completion

- **Earnings & History**
  - Daily/weekly/monthly earnings chart (fl_chart package)
  - Complete job history with ratings received
  - Tax-ready annual income summary (important for gig workers)

### Real-Time Job Matching Logic (Cloud Function)
```typescript
// functions/src/jobMatching.ts
export const broadcastJobPing = functions.firestore
  .document('jobs/{jobId}')
  .onCreate(async (snap, context) => {
    const job = snap.data();
    const nearbyWorkers = await findWorkersWithinRadius(
      job.location,
      5000, // 5km radius in meters
      job.requiredSkill
    );
    for (const worker of nearbyWorkers) {
      await sendFCMPing(worker.fcmToken, {
        jobId: context.params.jobId,
        cropType: job.cropType,
        payout: job.workerPayout,
        distance: worker.distanceKm,
      });
    }
  });
```

---

## Phase 4 — Site Manager App (Week 10–11)

> This is the operational core. The most feature-dense role.

### Screens
- **Daily Job Queue**
  - All jobs assigned for the day, sorted by time
  - Map view of all job locations

- **On-Site Operations Dashboard** *(Active Job View)*
  - Checklist: Arrival confirmed → Workers verified → Harvest started → Yield weighed → Graded → Byproducts sorted → Yard cleaned → Report submitted
  - Each checklist item is timestamped and logged to Firestore

- **Yield Weighing Tool**
  - Manual weight entry with photo of weighing scale
  - Crop grading selector (Grade A / B / C or Raw / Ripe for mangoes)
  - Calculates estimated value at current market rate

- **"Broadcast Ping" Button**
  - After harvest is complete, one-tap triggers processor job ping
  - Shows incoming Accept responses in real-time
  - Confirms the processor assignment

- **Byproduct Routing**
  - Select byproduct types generated (husks, shells, jackfruit rags)
  - Auto-suggests nearest registered buyer based on GPS
  - Confirm routing → logs to job record

- **Harvest Report Generator**
  - Auto-generates a PDF-style summary of the completed harvest
  - Sent to homeowner via in-app notification and WhatsApp share

---

## Phase 5 — B2B Portal (Week 12–13)

### Screens
- **Live Inventory Browser**
  - Real-time listings of available crops by district
  - Filters: crop type, grade, quantity, distance
  - Price shown is below wholesale midpoint (platform's core value prop)

- **Pre-Book Flow**
  - Select crop, quantity, preferred delivery date
  - Estimated price lock (valid for 24 hours)
  - Confirmation with estimated pickup/delivery window

- **Order Tracking**
  - Track order from harvest → processing → dispatch → delivered
  - Contact site manager or driver directly

- **Business Dashboard**
  - Order history and total savings vs. wholesale price (display this prominently — it's their ROI)
  - Subscription option for weekly/monthly standing orders

---

## Phase 6 — Testing & Hardening (Week 14–15)

### Unit Tests (Dart test package)
- [ ] Auth service — OTP flow, role assignment, session persistence
- [ ] Job service — creation, assignment, status transitions, edge cases
- [ ] Payment service — success, failure, retry logic
- [ ] Job matching radius calculation accuracy

### Widget Tests
- [ ] All form validation flows (empty fields, invalid phone numbers)
- [ ] Job ping screen countdown timer behavior
- [ ] Yield report generation output

### Integration Tests (flutter_test + integration_test)
- [ ] Full homeowner booking → worker acceptance → job completion flow
- [ ] Payment trigger on job completion
- [ ] FCM ping delivery and response capture

### Performance
- [ ] Firestore query index optimization (avoid full collection scans)
- [ ] Image compression before Firebase Storage upload (flutter_image_compress)
- [ ] Offline mode: worker can complete job flow with no internet, syncs on reconnect (Hive + sync queue)

---

## Phase 7 — Launch Preparation (Week 16)

### Pre-Launch Checklist
- [ ] Google Play Store listing prepared (screenshots, description in English and Malayalam)
- [ ] Firebase App Distribution set up for pilot tester builds
- [ ] Crashlytics integrated for production error tracking
- [ ] Analytics events mapped (Firebase Analytics) — key funnel steps tracked
- [ ] App size optimized (target: under 30 MB for low-storage Android devices)
- [ ] Tested on low-end Android devices (₹8,000–12,000 range — your actual user base)
- [ ] Malayalam language support (l10n package) — at least UI labels and error messages

### Rollout Strategy
1. **Week 16**: Internal TestFlight/Play Internal Testing with 10 pilot workers + 5 homeowners
2. **Week 17–18**: Closed beta with full pilot zone cohort
3. **Month 5**: Public Play Store release (Android only)
4. **Month 10**: iOS release (after revenue justifies Apple Developer account cost)

---

## Recommended Flutter Packages

> The complete `pubspec.yaml` with pinned versions is defined in the "Screen Assembly Code" section above. Below is a quick reference grouped by purpose.

| Group | Packages |
|---|---|
| Routing | `go_router` |
| State | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` |
| Firebase | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`, `firebase_crashlytics`, `firebase_analytics` |
| Data | `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation` |
| Maps | `google_maps_flutter`, `geolocator`, `geocoding` |
| Payments | `razorpay_flutter` |
| Storage | `hive`, `hive_flutter` |
| Charts | `fl_chart` |
| Animation | `flutter_animate`, `lottie`, `shimmer` |
| Images | `cached_network_image`, `flutter_image_compress`, `image_picker`, `flutter_svg` |
| UI helpers | `badges`, `percent_indicator`, `smooth_page_indicator`, `auto_size_text` |
| Utils | `share_plus`, `url_launcher`, `intl`, `flutter_dotenv` |
| Dev | `build_runner`, `mocktail`, `integration_test` |

---

## Estimated Development Timeline

| Phase | Duration | Deliverable |
|---|---|---|
| Foundation + Auth | 3 weeks | Working login, role routing |
| Homeowner App | 3 weeks | Full booking + payment flow |
| Worker App | 3 weeks | Job ping + completion flow |
| Site Manager App | 2 weeks | On-site ops tools |
| B2B Portal | 2 weeks | Inventory + ordering |
| Testing | 2 weeks | Test coverage, bug fixes |
| Launch Prep | 1 week | Store listing, beta release |
| **Total** | **~16 weeks** | **v1.0 Production App** |

> If building solo: add 50% buffer to each phase. If 2-person team (one Flutter dev + one backend): timeline holds.

---

## Post-Launch Priorities (Month 5 onwards)

- **Rating system** for workers and Site Managers (two-way, like Uber)
- **Crop price feed** integration (connect to Kerala government market price API or agmarknet.gov.in)
- **WhatsApp Business API** integration — harvest report delivery, booking confirmations
- **Worker financial profile** — exportable income history for bank loan applications
- **Predictive harvest scheduling** — ML model trained on your own transaction data to predict optimal harvest windows per tree age and variety
