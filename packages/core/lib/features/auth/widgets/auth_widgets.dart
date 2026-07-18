import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/design_tokens.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/locale_provider.dart';

/// EN / മല segmented language toggle (matches `.tp-lang` in app.css).
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunk,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _opt(ref, 'EN', lang == AppLang.en, AppLang.en, malayalam: false),
          _opt(ref, 'മല', lang == AppLang.ml, AppLang.ml, malayalam: true),
        ],
      ),
    );
  }

  Widget _opt(WidgetRef ref, String label, bool on, AppLang lang,
      {required bool malayalam}) {
    final style = (malayalam
            ? GoogleFonts.balooChettan2(fontWeight: FontWeight.w700)
            : GoogleFonts.notoSans(fontWeight: FontWeight.w600))
        .copyWith(fontSize: 13, color: on ? AppColors.brandInk : AppColors.fg3);
    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).set(lang),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: on ? AppShadows.sm : null,
        ),
        child: Text(label, style: style),
      ),
    );
  }
}

/// The ThengaPari logo mark (SVG asset) at [size] px.
class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({this.size = 26, super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'packages/core/assets/images/logo-mark.svg',
      width: size,
      height: size,
    );
  }
}

/// Logo mark + "ThengaPari" wordmark row (onboarding top bar brand).
class BrandRow extends StatelessWidget {
  const BrandRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandMark(size: 26),
        const SizedBox(width: 9),
        Text(
          'ThengaPari',
          style: GoogleFonts.balooChettan2(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.brandInk,
          ),
        ),
      ],
    );
  }
}

/// Auth form top bar (matches `.tp-form__bar`): circular back button on the
/// left, [LanguageToggle] on the right. Used by the phone-entry and OTP
/// screens.
class AuthTopBar extends StatelessWidget {
  final VoidCallback onBack;
  const AuthTopBar({required this.onBack, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onBack,
                customBorder: const CircleBorder(),
                highlightColor: AppColors.surfaceSunk,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 22,
                    color: AppColors.fg1,
                  ),
                ),
              ),
            ),
            const Spacer(),
            const LanguageToggle(),
          ],
        ),
      ),
    );
  }
}

/// Full-width pill CTA (matches `.tp-btn--primary`): brand green, white label,
/// soft shadow, optional trailing arrow. Greys out (`.tp-btn--disabled`) when
/// [onPressed] is null.
class AuthCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool showArrow;
  final bool loading;

  const AuthCtaButton({
    required this.label,
    required this.onPressed,
    this.showArrow = false,
    this.loading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: enabled ? AppColors.brand : AppColors.mist200,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        elevation: 0,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: AppText.button().copyWith(
                          color: enabled ? AppColors.onBrand : AppColors.ink400,
                        ),
                      ),
                      if (showArrow) ...[
                        const SizedBox(width: 10),
                        Text(
                          '→',
                          style: TextStyle(
                            fontSize: 20,
                            height: 1,
                            color: enabled ? AppColors.onBrand : AppColors.ink400,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
