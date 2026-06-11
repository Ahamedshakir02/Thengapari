import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../core/models/inventory_listing.dart';

/// ────────────────────────────────────────────────────────────────────────
/// B2B Portal shared widgets — a Flutter port of
/// `Designs/ThengaPari B2B Portal App/app.css` (deep-blue theme, green savings
/// band, amber CTAs). Colours/typography come from the locked theme tokens.
/// ────────────────────────────────────────────────────────────────────────

/// Indian-grouped rupee integer (e.g. 142800 → "1,42,800").
String b2bInr(num value) {
  final s = value.round().toString();
  if (s.length <= 3) return s;
  final head = s.substring(0, s.length - 3);
  final tail = s.substring(s.length - 3);
  final buf = StringBuffer();
  for (int i = 0; i < head.length; i++) {
    final fromEnd = head.length - i;
    buf.write(head[i]);
    if (fromEnd > 1 && fromEnd % 2 == 1) buf.write(',');
  }
  return '$buf,$tail';
}

const _blueGradient = LinearGradient(
  begin: Alignment(0, -1),
  end: Alignment(0.3, 1),
  colors: [AppColors.blue700, AppColors.blue900],
);

const _moneyGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1F8A4D), Color(0xFF146C3A)],
);

/// Deep-blue app header (`.appbar`).
class B2bAppBar extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? sub;
  final bool live;
  final Widget? action;
  const B2bAppBar({
    super.key,
    required this.eyebrow,
    required this.title,
    this.sub,
    this.live = false,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: _blueGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (live) ...[
                          const _LiveDot(),
                          const SizedBox(width: 7),
                        ],
                        Text(eyebrow.toUpperCase(),
                            style: AppText.overline()
                                .copyWith(color: AppColors.blue300)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(title,
                        style: AppText.h2().copyWith(color: Colors.white)),
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(sub!,
                          style: AppText.bodySm()
                              .copyWith(color: AppColors.blue300)),
                    ],
                  ],
                ),
              ),
              ?action,
            ],
          ),
        ),
      ),
    );
  }
}

/// Round translucent header icon button (`.icon-btn`).
class B2bIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const B2bIconBtn({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Icon(icon, size: 19, color: Colors.white),
      ),
    );
  }
}

/// Blue back bar for subscreens (`.backbar`).
class B2bBackBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget? action;
  const B2bBackBar({super.key, required this.title, required this.onBack, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: _blueGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(children: [
                    const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                    const SizedBox(width: 2),
                    Text('Back', style: AppText.button().copyWith(color: Colors.white)),
                  ]),
                ),
              ),
              Expanded(
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: AppText.title().copyWith(color: Colors.white)),
              ),
              SizedBox(width: 64, child: action == null ? null : Align(alignment: Alignment.centerRight, child: action)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: const Color(0xFF4ED07A),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ED07A)
                  .withValues(alpha: (1 - _c.value) * 0.5),
              blurRadius: 0,
              spreadRadius: _c.value * 6,
            ),
          ],
        ),
      ),
    );
  }
}

/// Green savings banner (`.savings-band`).
class SavingsBand extends StatelessWidget {
  final double amount;
  final double avgPercent;
  final int orders;
  final String? bestDeal;
  const SavingsBand({
    super.key,
    required this.amount,
    required this.avgPercent,
    required this.orders,
    this.bestDeal,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          gradient: _moneyGradient,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: const [
            BoxShadow(
                color: Color(0x4D146C3A), blurRadius: 22, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YOUR SAVINGS VS WHOLESALE · THIS MONTH',
                style: AppText.caption().copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    letterSpacing: 0.7)),
            const SizedBox(height: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹', style: AppText.displayNum(24, color: Colors.white)),
                Text(b2bInr(amount),
                    style: AppText.displayNum(36, color: Colors.white)),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('saved',
                      style: AppText.bodySm().copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.trending_up, size: 14, color: Color(0xFFB6F0C9)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                      'Avg ${avgPercent.toStringAsFixed(0)}% below market across $orders pre-books',
                      style: AppText.bodySm()
                          .copyWith(color: const Color(0xFFB6F0C9))),
                ),
              ],
            ),
            if (bestDeal != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.16)))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Best deal today',
                        style: AppText.caption().copyWith(
                            color: Colors.white.withValues(alpha: 0.8))),
                    Text(bestDeal!,
                        style: AppText.bodySm().copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Green "↓12% vs market" badge (`.save-badge`).
class SaveBadge extends StatelessWidget {
  final double percent;
  final bool small;
  const SaveBadge({super.key, required this.percent, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 9, vertical: small ? 4 : 5),
      decoration: BoxDecoration(
        color: AppColors.statusCompleteBg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.south, size: small ? 11 : 12, color: AppColors.statusCompleteFg),
          const SizedBox(width: 3),
          Text('${percent.toStringAsFixed(0)}% vs market',
              style: AppText.caption().copyWith(
                  color: AppColors.statusCompleteFg,
                  fontWeight: FontWeight.w700,
                  fontSize: small ? 11 : 12)),
        ],
      ),
    );
  }
}

/// Section header (overline title + optional action text).
class B2bSectionHead extends StatelessWidget {
  final String title;
  final String? action;
  final Color? actionColor;
  const B2bSectionHead({super.key, required this.title, this.action, this.actionColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title.toUpperCase(),
                style: AppText.overline().copyWith(color: AppColors.fg3)),
          ),
          if (action != null)
            Text(action!,
                style: AppText.caption().copyWith(
                    color: actionColor ?? AppColors.blue500,
                    fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// White card (`.card`).
class B2bCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const B2bCard({super.key, required this.child, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: child,
    );
  }
}

/// Amber primary CTA (`.btn-primary`).
class B2bButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool ghost;
  final bool loading;
  final VoidCallback? onTap;
  const B2bButton({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.ghost = false,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null || loading;
    if (ghost) {
      return GestureDetector(
        onTap: disabled ? null : onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.blue300, width: 1.5),
          ),
          child: Text(label,
              style: AppText.button()
                  .copyWith(color: AppColors.blue700, fontWeight: FontWeight.w700)),
        ),
      );
    }
    return Opacity(
      opacity: disabled && !loading ? 0.5 : 1,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: AppShadows.accent,
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.4, color: AppColors.onAccent))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: AppColors.onAccent),
                      const SizedBox(width: 8),
                    ],
                    Text(label,
                        style: AppText.button().copyWith(
                            color: AppColors.onAccent,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailingIcon, size: 19, color: AppColors.onAccent),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

/// Cyclable filter chip (`.chip`).
class B2bFilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const B2bFilterChip({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.blue700 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
              color: active ? AppColors.blue700 : AppColors.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? Colors.white : AppColors.fg2),
            const SizedBox(width: 6),
            Text(label,
                style: AppText.bodySm().copyWith(
                    color: active ? Colors.white : AppColors.fg2,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down,
                size: 14, color: active ? Colors.white : AppColors.fg2),
          ],
        ),
      ),
    );
  }
}

/// Blue grade pill (`.grade-tag`).
class GradeTag extends StatelessWidget {
  final String grade;
  const GradeTag(this.grade, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.blue100,
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      child: Text(grade,
          style: AppText.caption().copyWith(
              color: AppColors.blue700, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }
}

/// Bottom nav (`.tabbar`) — Market / Orders / Savings.
class B2bBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const B2bBottomNav({super.key, required this.index, required this.onTap});

  static const _items = [
    (Icons.storefront_outlined, Icons.storefront, 'Market'),
    (Icons.receipt_long_outlined, Icons.receipt_long, 'Orders'),
    (Icons.bar_chart_outlined, Icons.bar_chart, 'Savings'),
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
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++) Expanded(child: _item(i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i) {
    final on = i == index;
    final (off, active, label) = _items[i];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(i),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? AppColors.blue100 : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Icon(on ? active : off,
                  size: 22, color: on ? AppColors.blue700 : AppColors.fg3),
            ),
            const SizedBox(height: 3),
            Text(label,
                style: AppText.caption().copyWith(
                    color: on ? AppColors.blue700 : AppColors.fg3,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Horizontal savings-by-crop bar list (`.savechart`). Each row shows a crop
/// glyph, name, an animated track, and either a % or ₹ value.
class SavingsByCropChart extends StatelessWidget {
  /// (crop, value, displayLabel). [value] drives bar width; max → full bar.
  final List<(B2BCrop, double, String)> rows;
  const SavingsByCropChart({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final max = rows.fold<double>(1, (m, r) => r.$2 > m ? r.$2 : m);
    return B2bCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        children: [
          for (final (crop, value, label) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Row(
                children: [
                  CropGlyphBox(crop: crop, size: 34, radius: 10, glyphSize: 22),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 70,
                    child: Text(crop.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodySm().copyWith(
                            color: AppColors.fg1, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Container(height: 16, color: AppColors.greenLeaf50),
                          FractionallySizedBox(
                            widthFactor: (value / max).clamp(0.0, 1.0),
                            child: Container(
                              height: 16,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  AppColors.greenSage500,
                                  AppColors.green600
                                ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 48,
                    child: Text(label,
                        textAlign: TextAlign.right,
                        style: AppText.displayNum(15, color: AppColors.green600)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Tinted rounded box containing a [CropGlyph].
class CropGlyphBox extends StatelessWidget {
  final B2BCrop crop;
  final double size;
  final double radius;
  final double glyphSize;
  const CropGlyphBox({
    super.key,
    required this.crop,
    this.size = 52,
    this.radius = 14,
    double? glyphSize,
  }) : glyphSize = glyphSize ?? size * 0.62;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: crop.tint,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: CropGlyph(crop: crop, size: glyphSize),
    );
  }
}

/// Flat painted crop glyph approximating the SVGs in `crops.jsx`.
class CropGlyph extends StatelessWidget {
  final B2BCrop crop;
  final double size;
  const CropGlyph({super.key, required this.crop, this.size = 30});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _CropGlyphPainter(crop));
}

class _CropGlyphPainter extends CustomPainter {
  final B2BCrop crop;
  _CropGlyphPainter(this.crop);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 32; // glyphs are drawn on a 32×32 grid
    Paint fill(Color c) => Paint()
      ..color = c
      ..isAntiAlias = true;
    Offset p(double x, double y) => Offset(x * s, y * s);
    double r(double v) => v * s;

    switch (crop) {
      case B2BCrop.coconut:
      case B2BCrop.arecanut:
        canvas.drawCircle(p(16, 17), r(11), fill(const Color(0xFF7B4A24)));
        canvas.drawCircle(p(12.5, 15), r(1.7), fill(const Color(0xFF3A2210)));
        canvas.drawCircle(p(19.5, 15), r(1.7), fill(const Color(0xFF3A2210)));
        canvas.drawCircle(p(16, 20.5), r(1.7), fill(const Color(0xFF3A2210)));
      case B2BCrop.mango:
        final mango = Path()
          ..addOval(Rect.fromCenter(center: p(16, 17), width: r(20), height: r(24)));
        canvas.save();
        canvas.translate(p(16, 17).dx, p(16, 17).dy);
        canvas.rotate(-0.4);
        canvas.translate(-p(16, 17).dx, -p(16, 17).dy);
        canvas.drawPath(mango, fill(const Color(0xFFF4A52A)));
        canvas.restore();
        // leaf
        canvas.drawPath(
          Path()
            ..moveTo(p(21, 7).dx, p(21, 7).dy)
            ..quadraticBezierTo(p(25, 5).dx, p(25, 5).dy, p(26, 7).dx, p(26, 7).dy)
            ..quadraticBezierTo(p(23, 9).dx, p(23, 9).dy, p(21, 7).dx, p(21, 7).dy)
            ..close(),
          fill(const Color(0xFF2E6B3E)),
        );
      case B2BCrop.jackfruit:
        canvas.drawOval(
            Rect.fromCenter(center: p(16, 18), width: r(20), height: r(24)),
            fill(const Color(0xFF7FA63C)));
        for (var rr = 0; rr < 5; rr++) {
          for (var c = 0; c < 4; c++) {
            canvas.drawCircle(
                p(9 + c * 4.6, 9 + rr * 4.5), r(1.4), fill(const Color(0xFF5E7E2A)));
          }
        }
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(p(14.5, 3).dx, p(14.5, 3).dy, r(3), r(4)),
                Radius.circular(r(1.5))),
            fill(const Color(0xFF5E3618)));
      case B2BCrop.banana:
        final banana = Path()
          ..moveTo(p(7, 9).dx, p(7, 9).dy)
          ..cubicTo(p(8, 18).dx, p(8, 18).dy, p(14, 25).dx, p(14, 25).dy,
              p(24, 25).dx, p(24, 25).dy)
          ..cubicTo(p(25.6, 25).dx, p(25.6, 25).dy, p(26.4, 24.6).dx,
              p(27, 24).dy, p(27, 24).dx, p(27, 24).dy)
          ..cubicTo(p(18, 24).dx, p(18, 24).dy, p(12, 18).dx, p(12, 18).dy,
              p(11, 9).dx, p(11, 9).dy)
          ..close();
        canvas.drawPath(banana, fill(const Color(0xFFF4C430)));
      case B2BCrop.pepper:
        canvas.drawPath(
          Path()
            ..moveTo(p(16, 5).dx, p(16, 5).dy)
            ..cubicTo(p(16, 9).dx, p(16, 9).dy, p(15, 12).dx, p(15, 12).dy,
                p(15, 17).dx, p(15, 17).dy),
          Paint()
            ..color = const Color(0xFF4C7A3C)
            ..strokeWidth = r(2)
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
        const dots = [
          (11.0, 14.0, 0xFF2B2A24),
          (17.0, 12.0, 0xFF3A2210),
          (14.0, 19.0, 0xFF2B2A24),
          (20.0, 18.0, 0xFF3A2210),
          (17.0, 24.0, 0xFF2B2A24),
        ];
        for (final (x, y, c) in dots) {
          canvas.drawCircle(p(x, y), r(3.1), fill(Color(c)));
        }
      case B2BCrop.ginger:
        canvas.drawPath(
          Path()
            ..addRRect(RRect.fromRectAndRadius(
                Rect.fromCenter(center: p(16, 16), width: r(18), height: r(14)),
                Radius.circular(r(7)))),
          fill(const Color(0xFFD8A559)),
        );
    }
  }

  @override
  bool shouldRepaint(_CropGlyphPainter old) => old.crop != crop;
}
