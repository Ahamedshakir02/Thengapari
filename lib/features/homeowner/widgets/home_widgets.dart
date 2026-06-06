import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/design_tokens.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/tree_inventory.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/app_icon.dart';

const _gut = AppSpace.gutter;

// ─────────────────────────── Hero ───────────────────────────

/// Home hero: the real Kerala landscape SVG with scrim, brand chip + language
/// toggle on top, and the greeting at the bottom. Matches `.hero`.
class HomeHero extends StatelessWidget {
  final String greetingSmall;
  final String name;
  final String sub;
  final double topInset;

  const HomeHero({
    required this.greetingSmall,
    required this.name,
    required this.sub,
    this.topInset = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(AppRadii.xl),
        bottomRight: Radius.circular(AppRadii.xl),
      ),
      child: SizedBox(
        height: 212 + topInset,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset(
              'assets/images/illustration-kerala-landscape.svg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, 0.24), // object-position 50% 62%
            ),
            // scrim — darker at the top so the white brand chip + language
            // toggle stay legible over the light sky.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.28, 0.6, 1],
                  colors: [
                    Color(0xB315331F),
                    Color(0x0015331F),
                    Color(0x1415331F),
                    Color(0xAD15331F),
                  ],
                ),
              ),
            ),
            // top: brand chip + lang toggle
            Positioned(
              top: 10 + topInset,
              left: _gut,
              right: _gut,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [_BrandChip(), _LangToggle()],
              ),
            ),
            // greeting
            Positioned(
              left: _gut,
              right: _gut,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greetingSmall,
                      style: AppText.body().copyWith(
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.92))),
                  const SizedBox(height: 3),
                  Text(name,
                      style: AppText.displayNum(27,
                              color: Colors.white, weight: FontWeight.w700)
                          .copyWith(height: 1.15, shadows: const [
                        Shadow(color: Color(0x6615331F), blurRadius: 12)
                      ])),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon('leaf',
                          size: 15,
                          color: Colors.white.withValues(alpha: 0.92),
                          strokeWidth: 1.8),
                      const SizedBox(width: 6),
                      Text(sub,
                          style: AppText.caption().copyWith(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.9))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 6, 12, 6),
      decoration: BoxDecoration(
        color: const Color(0x4D15331F),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: SvgPicture.asset('assets/images/logo-mark.svg',
                width: 26, height: 26),
          ),
          const SizedBox(width: 8),
          Text('ThengaPari',
              style: AppText.h3().copyWith(
                  fontSize: 14, height: 1, color: Colors.white)),
        ],
      ),
    );
  }
}

/// Language toggle (EN / മല) — switches the app language via [localeProvider].
class _LangToggle extends ConsumerWidget {
  const _LangToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    final notifier = ref.read(localeProvider.notifier);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0x4D15331F),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg('EN', lang == AppLang.en, () => notifier.set(AppLang.en)),
          _seg('മല', lang == AppLang.ml, () => notifier.set(AppLang.ml)),
        ],
      ),
    );
  }

  Widget _seg(String label, bool on, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: on ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(label,
            style: AppText.caption().copyWith(
                fontWeight: FontWeight.w700,
                color: on ? AppColors.brandInk : Colors.white.withValues(alpha: 0.78))),
      ),
    );
  }
}

// ─────────────────────────── Section head ───────────────────────────

class SectionHead extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHead(this.title, {this.action, this.onAction, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_gut, 0, _gut, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(title, style: AppText.h3())),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: AppText.caption().copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brand)),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Crop chip ───────────────────────────

class HomeCropChip extends ConsumerWidget {
  final CropType type;
  final String count;
  final VoidCallback? onTap;

  const HomeCropChip(
      {required this.type, required this.count, this.onTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 7, 14, 7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CropPalette.tint(type),
                shape: BoxShape.circle,
              ),
              child: CropGlyph(type, size: 22, color: CropPalette.fg(type)),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cropName(type, lang),
                    style: AppText.bodySm().copyWith(
                        fontWeight: FontWeight.w600, color: AppColors.fg1)),
                const SizedBox(height: 1),
                Text(count, style: AppText.caption()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Stat card ───────────────────────────

class HomeStatCard extends StatelessWidget {
  final String iconName;
  final Color iconBg;
  final Color iconFg;
  final String value;
  final String label;
  final String trend;
  final IconData trendIcon;
  final Color trendBg;
  final Color trendFg;

  const HomeStatCard({
    required this.iconName,
    required this.iconBg,
    required this.iconFg,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendIcon,
    required this.trendBg,
    required this.trendFg,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: AppIcon(iconName, size: 20, color: iconFg),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppText.displayNum(24)),
          const SizedBox(height: 4),
          Text(label, style: AppText.caption().copyWith(fontSize: 12.5)),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: trendBg,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(trendIcon, size: 12, color: trendFg),
                const SizedBox(width: 3),
                Text(trend,
                    style: AppText.caption().copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: trendFg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Weekly bar chart ───────────────────────────

class WeeklyBarChart extends StatelessWidget {
  /// (label, value) per bar, e.g. ('M', 2100).
  final List<(String, double)> data;

  const WeeklyBarChart({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final maxVal =
        data.fold<double>(1, (m, e) => e.$2 > m ? e.$2 : m);
    return SizedBox(
      height: 116,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (label, value) in data)
            Expanded(
              child: _BarCol(
                label: label,
                value: value,
                fraction: value / maxVal,
                isPeak: value == maxVal && value > 0,
              ),
            ),
        ],
      ),
    );
  }
}

class _BarCol extends StatelessWidget {
  final String label;
  final double value;
  final double fraction;
  final bool isPeak;

  const _BarCol({
    required this.label,
    required this.value,
    required this.fraction,
    required this.isPeak,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fraction.clamp(0.04, 1),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 26),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isPeak
                            ? AppColors.accent
                            : AppColors.greenLeaf300,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(7),
                          bottom: Radius.circular(4),
                        ),
                        boxShadow: isPeak ? AppShadows.accent : null,
                      ),
                    ),
                    if (isPeak)
                      Positioned(
                        top: -19,
                        left: 0,
                        right: 0,
                        child: Text(
                          '₹${(value / 1000).toStringAsFixed(1)}k',
                          textAlign: TextAlign.center,
                          style: AppText.caption().copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandInk),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: AppText.caption().copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isPeak ? AppColors.statusInprogressFg : AppColors.fg3)),
      ],
    );
  }
}

// ─────────────────────────── Active job card ───────────────────────────

class ActiveJobCard extends StatelessWidget {
  final CropType thumbCrop;
  final String title;
  final String meta;
  final double progress;
  final String etaText;
  final String managerInitials;
  final VoidCallback? onTrack;

  const ActiveJobCard({
    required this.thumbCrop,
    required this.title,
    required this.meta,
    required this.progress,
    required this.etaText,
    required this.managerInitials,
    this.onTrack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: CropPalette.tint(thumbCrop),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: CropGlyph(thumbCrop,
                      size: 26, color: CropPalette.fg(thumbCrop)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppText.title().copyWith(fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(meta,
                          style: AppText.caption().copyWith(fontSize: 12.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: Stack(
                    children: [
                      Container(height: 9, color: AppColors.mist200),
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0, 1),
                        child: Container(
                          height: 9,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                              AppColors.greenSage500,
                              AppColors.brand
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.brand,
                        shape: BoxShape.circle,
                      ),
                      child: Text(managerInitials,
                          style: AppText.caption().copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(etaText,
                          style: AppText.caption().copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.fg2)),
                    ),
                    if (onTrack != null) _TrackButton(onTap: onTrack!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _TrackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: AppShadows.accent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Track',
                style: AppText.bodySm().copyWith(
                    fontWeight: FontWeight.w600, color: AppColors.onAccent)),
            const SizedBox(width: 6),
            AppIcon('arrow-right',
                size: 16, color: AppColors.onAccent, strokeWidth: 2.2),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Bottom nav ───────────────────────────

class HomeBottomNav extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const HomeBottomNav({this.currentIndex = 0, this.onTap, super.key});

  static const _items = [
    ('home', 'nav_home'),
    ('calendar', 'nav_schedule'),
    ('report', 'nav_reports'),
    ('profile', 'nav_profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: _items[i].$1,
                    label: tr(_items[i].$2, lang),
                    on: i == currentIndex,
                    onTap: onTap == null ? null : () => onTap!(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool on;
  final VoidCallback? onTap;

  const _NavItem(
      {required this.icon,
      required this.label,
      required this.on,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = on ? AppColors.brand : AppColors.fg3;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 7, bottom: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? AppColors.greenLeaf100 : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: AppIcon(icon,
                  size: 22, color: color, strokeWidth: on ? 2.2 : 1.9),
            ),
            const SizedBox(height: 3),
            Text(label,
                style: AppText.caption().copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: on ? AppColors.brandInk : AppColors.fg3)),
          ],
        ),
      ),
    );
  }
}
