import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:core/app/design_tokens.dart';
import 'package:core/core/i18n/app_strings.dart';

/// Worker palette — the design prototype renders the "Emerald" palette
/// (`app.jsx` PALETTES.Emerald, the default in TWEAK_DEFAULTS and the one
/// every delivered screenshot uses), so these mirror that ramp rather than the
/// alternative Teal CSS set. Shared across every worker screen.
class WColors {
  WColors._();

  static const bg = Color(0xFF07332A); // emerald canvas
  static const bg2 = Color(0xFF0A3E32);
  static const bgDeep = Color(0xFF052A22);
  static const glowTop = Color(0xFF0F6B52);
  static const surface = Color(0xFF0C4A3B); // cards
  static const surface2 = Color(0xFF0A4034);
  static const teal500 = Color(0xFF12876B);
  static const teal300 = Color(0xFF5FC6A2);
  static const teal100 = Color(0xFFCFEFE0);
  static const line = Color(0x22CFEFE0); // rgba(207,239,224,.13)
  static const lineStrong = Color(0x42CFEFE0); // rgba(207,239,224,.26)
  static const fg1 = Color(0xFFFFFFFF);
  static const fg2 = Color(0xFFBCE0D0);
  static const fg3 = Color(0xFF74B7A0);
  static const accent = Color(0xFFF4A52A);
  static const accent2 = Color(0xFFFBBA4D);
  static const accentPress = Color(0xFFDD8413);
  static const good = Color(0xFF5FCF95);
  static const warn = Color(0xFFF4A52A);
  static const bad = Color(0xFFF08A6A);
}

/// Big screen title + optional subtitle, with an optional trailing widget
/// (matches `ScreenHeader` in the worker designs).
class WScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const WScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.displayNum(26, color: WColors.fg1)),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!,
                      style: AppText.bodySm().copyWith(color: WColors.fg3)),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

/// Square icon button used at the top-right of worker screens.
class WHeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const WHeaderIconBtn({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: WColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: WColors.line),
        ),
        child: Icon(icon, size: 21, color: WColors.teal300),
      ),
    );
  }
}

/// Small labelled stat card (icon + label + a value child).
class WMiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  const WMiniStat({
    super.key,
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
      decoration: BoxDecoration(
        color: WColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: WColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: WColors.teal300),
              const SizedBox(width: 7),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption()
                        .copyWith(color: WColors.fg2, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Section heading with an optional trailing widget. When [ml] is provided
/// and the app language is [AppLang.both], a smaller Malayalam secondary line
/// renders under the title (design `SectionHead` in `ui.jsx`).
class WSectionHead extends StatelessWidget {
  final String title;
  final String? ml;
  final Widget? trailing;
  final bool dense;
  const WSectionHead(
      {super.key, required this.title, this.ml, this.trailing, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final showMl = ml != null && gAppLang == AppLang.both;
    return Padding(
      padding: EdgeInsets.only(bottom: dense ? 10 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.h3().copyWith(color: WColors.fg1)),
                if (showMl)
                  Text(ml!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption().copyWith(color: WColors.fg3)),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

/// Rounded amber/teal status tag (e.g. "UP NEXT", "SCHEDULED", skill level).
class WTag extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;
  const WTag({super.key, required this.text, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style: AppText.overline()
              .copyWith(color: fg, fontSize: 11, letterSpacing: 0.5)),
    );
  }
}

/// A rupee amount rendered with the display/number font.
class WRupee extends StatelessWidget {
  final String value;
  final double size;
  final Color color;
  final FontWeight weight;
  const WRupee(this.value,
      {super.key,
      this.size = 24,
      this.color = WColors.fg1,
      this.weight = FontWeight.w700});

  @override
  Widget build(BuildContext context) {
    // Design `Rupee` renders amounts in the mono numeric face.
    return Text('₹$value',
        style: AppText.mono(size, color: color, weight: weight));
  }
}

/// Mon→Sun earnings bar chart. [week] has 7 entries; the bar at [todayIndex]
/// is highlighted amber. Shared by the home + wallet screens.
class WWeeklyChart extends StatelessWidget {
  final List<double> week;
  final int todayIndex;
  const WWeeklyChart({super.key, required this.week, required this.todayIndex});

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final max = week.fold<double>(1, math.max);
    return SizedBox(
      height: 132,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < 7; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 6 ? 0 : 8),
                child: _bar(week[i], max, _labels[i], i == todayIndex),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bar(double v, double max, String label, bool isToday) {
    final h = math.max(8.0, (v / max) * 96);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          v == 0
              ? '—'
              : v >= 1000
                  ? '${(v / 1000).toStringAsFixed(1)}k'
                  : v.round().toString(),
          style: AppText.caption().copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isToday ? WColors.accent2 : WColors.fg3),
        ),
        const SizedBox(height: 7),
        Container(
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isToday
                  ? const [WColors.accent2, WColors.accent]
                  : const [WColors.teal500, WColors.glowTop],
            ),
            boxShadow: isToday
                ? [
                    BoxShadow(
                        color: WColors.accent.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4)),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 7),
        Text(label,
            style: AppText.caption().copyWith(
                fontSize: 11,
                color: isToday ? WColors.fg1 : WColors.fg3,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500)),
      ],
    );
  }
}

/// Format an integer rupee value with Indian digit grouping (e.g. 142800 →
/// "1,42,800").
String inrGroup(num value) {
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
