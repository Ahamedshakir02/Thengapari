import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:core/app/design_tokens.dart';
import 'package:core/core/models/yield_data.dart';

/// ────────────────────────────────────────────────────────────────────────
/// Site Manager ("Kera") shared widgets — a faithful Flutter port of
/// `Designs/ThengaPari Site Manager App/app.css` + `components.jsx`. The Site
/// Manager app uses the light "paper" palette with a deep brand-ink header.
/// Everything pulls colours/typography from the locked theme tokens.
/// ────────────────────────────────────────────────────────────────────────

/// Deep brand-ink header bar (`.hdr`) — white text on forest green. Pass any
/// [child] (rows of title/elapsed/etc.). Use [SmPaperHeader] for subscreens.
class SmBrandHeader extends StatelessWidget {
  final Widget child;
  const SmBrandHeader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.brandInk,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.s4, AppSpace.s4, AppSpace.s4, AppSpace.s4),
          child: child,
        ),
      ),
    );
  }
}

/// White subscreen header with a circular back button (`.hdr--paper`).
class SmPaperHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBack;
  const SmPaperHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.s4, AppSpace.s3, AppSpace.s4, AppSpace.s3),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceSunk,
                  ),
                  child: const Icon(Icons.arrow_back,
                      size: 22, color: AppColors.fg1),
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppText.title().copyWith(color: AppColors.fg1)),
                    if (subtitle != null)
                      Text(subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption()
                              .copyWith(color: AppColors.fg3)),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 10), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// White rounded card (`.card`).
class SmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BoxBorder? border;
  const SmCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.s4),
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: border ?? Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: child,
    );
  }
}

/// Overline label (`.over`).
class SmOverline extends StatelessWidget {
  final String text;
  final Color? color;
  const SmOverline(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppText.overline().copyWith(color: color ?? AppColors.fg3),
      );
}

enum SmChipKind { leaf, amber, line }

/// Pill chip (`.chip`).
class SmChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final SmChipKind kind;
  const SmChip(this.label,
      {super.key, this.icon, this.kind = SmChipKind.leaf});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (kind) {
      SmChipKind.leaf => (AppColors.greenLeaf100, AppColors.greenForest800, null),
      SmChipKind.amber => (AppColors.amber100, AppColors.statusInprogressFg, null),
      SmChipKind.line => (AppColors.surface, AppColors.fg2, AppColors.borderStrong),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
          ],
          Text(label,
              style: AppText.caption()
                  .copyWith(color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

enum SmSpillKind { progress, done, scheduled, error }

/// Status pill with a leading dot (`.spill`).
class SmSpill extends StatelessWidget {
  final String label;
  final SmSpillKind kind;
  const SmSpill(this.label, {super.key, this.kind = SmSpillKind.progress});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      SmSpillKind.progress => (AppColors.statusInprogressBg, AppColors.statusInprogressFg),
      SmSpillKind.done => (AppColors.statusCompleteBg, AppColors.statusCompleteFg),
      SmSpillKind.scheduled => (AppColors.statusScheduledBg, AppColors.statusScheduledFg),
      SmSpillKind.error => (AppColors.statusErrorBg, AppColors.statusErrorFg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label.toUpperCase(),
              style: AppText.overline().copyWith(color: fg, letterSpacing: 0.7)),
        ],
      ),
    );
  }
}

enum SmButtonKind { brand, accent, ghost, soft }

/// Primary action button (`.btn`). [large] matches `.btn-lg`.
class SmButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final SmButtonKind kind;
  final bool large;
  final bool loading;
  final bool pulse;
  final VoidCallback? onTap;
  const SmButton({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.kind = SmButtonKind.brand,
    this.large = false,
    this.loading = false,
    this.pulse = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border, shadow) = switch (kind) {
      SmButtonKind.brand => (AppColors.brand, AppColors.onBrand, null, AppShadows.sm),
      SmButtonKind.accent => (AppColors.accent, AppColors.onAccent, null, AppShadows.accent),
      SmButtonKind.ghost => (AppColors.surface, AppColors.brand, AppColors.borderStrong, null),
      SmButtonKind.soft => (AppColors.greenLeaf100, AppColors.greenForest800, null, null),
    };
    final disabled = onTap == null || loading;
    return Opacity(
      opacity: disabled && !loading ? 0.55 : 1,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: large ? 60 : 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(large ? AppRadii.lg : AppRadii.md),
            border: border == null ? null : Border.all(color: border, width: 1.5),
            boxShadow: shadow,
          ),
          child: loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: large ? 24 : 20, color: fg),
                      const SizedBox(width: 9),
                    ],
                    Text(label,
                        style: AppText.button().copyWith(
                            color: fg,
                            fontSize: large ? 18 : 16,
                            fontWeight: kind == SmButtonKind.accent
                                ? FontWeight.w700
                                : FontWeight.w600)),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailingIcon, size: large ? 22 : 20, color: fg),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

/// List / Map segmented toggle (`.seg`).
class SmSegmented extends StatelessWidget {
  final int index;
  final List<({IconData icon, String label})> items;
  final ValueChanged<int> onTap;
  const SmSegmented(
      {super.key,
      required this.index,
      required this.items,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunk,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(right: i == items.length - 1 ? 0 : 4),
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    boxShadow: i == index ? AppShadows.sm : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(items[i].icon,
                          size: 18,
                          color: i == index ? AppColors.brand : AppColors.fg2),
                      const SizedBox(width: 6),
                      Text(items[i].label,
                          style: AppText.button().copyWith(
                              fontSize: 15,
                              color: i == index
                                  ? AppColors.brand
                                  : AppColors.fg2)),
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

/// Bottom nav (`.bnav`) — Today / On-site / Earnings / Profile.
class SmBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const SmBottomNav({super.key, required this.index, required this.onTap});

  static const _items = [
    (Icons.today_outlined, Icons.today, 'Today'),
    (Icons.location_on_outlined, Icons.location_on, 'On-site'),
    (Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet, 'Earnings'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++)
                Expanded(child: _item(i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i) {
    final on = i == index;
    final (off, active, label) = _items[i];
    final color = on ? AppColors.brand : AppColors.fg3;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(i),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(on ? active : off, size: 25, color: color),
            const SizedBox(height: 3),
            Text(label,
                style: AppText.caption().copyWith(
                    color: color,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

/// Grade-split donut (`<Donut>`): coloured ring segments with a [center] child.
/// Drives the live yield breakdown on OnSiteScreen + YieldWeighScreen.
class GradeDonut extends StatelessWidget {
  final int gradeA;
  final int gradeB;
  final int tender;
  final double size;
  final double thickness;
  final Widget center;
  const GradeDonut({
    super.key,
    required this.gradeA,
    required this.gradeB,
    required this.tender,
    this.size = 128,
    this.thickness = 20,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(
              gradeA: gradeA,
              gradeB: gradeB,
              tender: tender,
              thickness: thickness,
            ),
          ),
          Center(child: center),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int gradeA;
  final int gradeB;
  final int tender;
  final double thickness;
  const _DonutPainter({
    required this.gradeA,
    required this.gradeB,
    required this.tender,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..color = AppColors.surfaceSunk,
    );

    final total = gradeA + gradeB + tender;
    if (total == 0) return;

    final segs = <(int, Color)>[
      (gradeA, CropGrade.gradeA.color),
      (gradeB, CropGrade.gradeB.color),
      (tender, CropGrade.tender.color),
    ];
    var start = -math.pi / 2;
    for (final (count, color) in segs) {
      if (count == 0) continue;
      final sweep = (count / total) * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep - 0.03,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.butt
          ..color = color,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.gradeA != gradeA || old.gradeB != gradeB || old.tender != tender;
}

/// Legend row (colour swatch · label · value) used beside [GradeDonut].
class SmLegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const SmLegendRow(
      {super.key,
      required this.color,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: AppText.bodySm().copyWith(color: AppColors.fg2)),
          ),
          Text(value,
              style: AppText.title().copyWith(fontSize: 15, color: AppColors.fg1)),
        ],
      ),
    );
  }
}

/// Live elapsed timer (HH:MM:SS / MM:SS) ticking from [since].
class ElapsedTimer extends StatefulWidget {
  final DateTime since;
  final TextStyle style;
  const ElapsedTimer({super.key, required this.since, required this.style});

  @override
  State<ElapsedTimer> createState() => _ElapsedTimerState();
}

class _ElapsedTimerState extends State<ElapsedTimer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = DateTime.now().difference(widget.since).inSeconds.clamp(0, 1 << 30);
    final hh = s ~/ 3600, mm = (s % 3600) ~/ 60, ss = s % 60;
    String p2(int n) => n.toString().padLeft(2, '0');
    final text = hh > 0 ? '$hh:${p2(mm)}:${p2(ss)}' : '${p2(mm)}:${p2(ss)}';
    return Text(text, style: widget.style);
  }
}

/// A small +/- stepper counter (`Counter` in screen3.jsx).
class SmStepperCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onDelta;
  const SmStepperCounter(
      {super.key, required this.value, required this.onDelta});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(Icons.remove, () => onDelta(-1), plus: false),
        SizedBox(
          width: 48,
          child: Text('$value',
              textAlign: TextAlign.center,
              style: AppText.displayNum(24, color: AppColors.fg1)),
        ),
        _btn(Icons.add, () => onDelta(1), plus: true),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, {required bool plus}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: plus ? AppColors.greenLeaf100 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
              color: plus ? AppColors.greenLeaf300 : AppColors.borderStrong,
              width: 1.5),
        ),
        child: Icon(icon,
            size: 22,
            color: plus ? AppColors.greenForest800 : AppColors.fg1),
      ),
    );
  }
}
