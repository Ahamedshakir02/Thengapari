import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/design_tokens.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/locale_provider.dart';
import '../widgets/auth_widgets.dart';

/// Welcome screen (design `Welcome`, hero-up layout — `.tp-wel--heroup`):
/// Kerala landscape hero, brand logo + wordmark, tagline, "Get started" pill
/// and terms line. Shown to signed-out users who have finished onboarding;
/// "Get started" moves on to `/login` (phone entry).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Hero: Kerala landscape, rounded bottom corners, toggle overlay ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadii.xl),
                    bottomRight: Radius.circular(AppRadii.xl),
                  ),
                  child: SizedBox(
                    height: 340,
                    width: double.infinity,
                    child: SvgPicture.asset(
                      'assets/images/illustration-kerala-landscape.svg',
                      package: 'core',
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
                const Positioned(
                  top: 8,
                  right: 18,
                  child: LanguageToggle(),
                ),
              ],
            ),
            // ── Body: logo + wordmark + tagline ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const BrandMark(size: 64),
                    const SizedBox(height: 14),
                    Text.rich(
                      TextSpan(
                        text: 'Thenga',
                        style: GoogleFonts.balooChettan2(
                          fontSize: 34,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandInk,
                          letterSpacing: -0.34,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Pari',
                            style: TextStyle(color: AppColors.accent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(
                        tr('welcome_tagline', lang),
                        textAlign: TextAlign.center,
                        style: AppText.bodyLg(),
                      ),
                    ),
                    // Sage Malayalam-flavoured subtitle — hidden when the UI
                    // itself is in Malayalam (matches the design).
                    if (lang != AppLang.ml) ...[
                      const SizedBox(height: 4),
                      Text(
                        tr('welcome_ml', lang),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.balooChettan2(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenSage500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // ── Foot: Get started + terms ──
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 8, 30, 26),
              child: Column(
                children: [
                  AuthCtaButton(
                    label: tr('auth_get_started', lang),
                    onPressed: () => context.go('/login'),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      tr('auth_terms', lang),
                      textAlign: TextAlign.center,
                      style: AppText.caption().copyWith(height: 1.5),
                    ),
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
