import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../app/design_tokens.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/onboarding_illustrations.dart';

/// First-run onboarding: 3 swipeable slides. "Skip" / final "Get started"
/// writes the one-time flag (Hive) so it never shows again, then hands off to
/// the router (→ Welcome). Matches the `Onboarding` design (`.tp-ob`).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  static const _slides = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() => _controller.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );

  Future<void> _finish() async {
    // Flipping the flag re-runs the router redirect, which sends a signed-out,
    // onboarded user on to Welcome (or a role home if already signed in).
    await ref.read(onboardingSeenProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final last = _index == _slides - 1;
    final headlines = ['onb1_h', 'onb2_h', 'onb3_h'];
    final subs = ['onb1_s', 'onb2_s', 'onb3_s'];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // top bar: brand + language toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 18, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [BrandRow(), LanguageToggle()],
              ),
            ),
            // swipeable slides
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _Slide(
                  index: i,
                  headline: tr(headlines[i], lang),
                  sub: tr(subs[i], lang),
                  malayalam: lang == AppLang.ml,
                ),
              ),
            ),
            // footer: dots + skip/next
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 18, 30, 22),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _slides,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      expansionFactor: 3.25,
                      activeDotColor: AppColors.amber500,
                      dotColor: AppColors.greenLeaf300,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (!last)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: TextButton(
                            onPressed: _finish,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.fg3,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              textStyle: AppText.button(),
                            ),
                            child: Text(tr('auth_skip', lang)),
                          ),
                        ),
                      Expanded(
                        child: AuthCtaButton(
                          label: tr(last ? 'auth_get_started' : 'auth_next', lang),
                          showArrow: true,
                          onPressed: last ? _finish : _next,
                        ),
                      ),
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

class _Slide extends StatelessWidget {
  final int index;
  final String headline;
  final String sub;
  final bool malayalam;

  const _Slide({
    required this.index,
    required this.headline,
    required this.sub,
    required this.malayalam,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
              child: OnboardingIllustration(index: index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              children: [
                Text(
                  headline,
                  textAlign: TextAlign.center,
                  style: AppText.h1().copyWith(
                    color: AppColors.brandInk,
                    fontSize: malayalam ? 27 : 32,
                    height: malayalam ? 1.32 : 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    sub,
                    textAlign: TextAlign.center,
                    style: AppText.bodyLg(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
