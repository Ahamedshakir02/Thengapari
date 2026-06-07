import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/design_tokens.dart';
import '../../../app/router.dart';
import '../theme/worker_theme.dart';

/// Post-job summary — payout confirmation, job summary, and a site-manager star
/// rating. Matches `Designs/ThengaPari Worker App/screen-complete.jsx`.
class JobCompleteScreen extends StatefulWidget {
  const JobCompleteScreen({super.key});

  @override
  State<JobCompleteScreen> createState() => _JobCompleteScreenState();
}

class _JobCompleteScreenState extends State<JobCompleteScreen> {
  int _rating = 5;

  static const _words = {
    1: 'Poor',
    2: 'Unfair',
    3: 'Okay',
    4: 'Good',
    5: 'Excellent',
  };

  void _finish() => context.go(AppRoutes.workerHome);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1),
            radius: 1.0,
            colors: [WColors.glowTop, WColors.bg, WColors.bgDeep],
            stops: [0, 0.5, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 26, 18, 16),
                  children: [
                    _successHeader(),
                    const SizedBox(height: 20),
                    _payoutCard(),
                    const SizedBox(height: 14),
                    _summaryCard(),
                    const SizedBox(height: 14),
                    _ratingCard(),
                  ],
                ),
              ),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _successHeader() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(0, -0.3),
              colors: [WColors.good, Color(0xFF2E8E5C)],
            ),
            boxShadow: [
              BoxShadow(
                  color: WColors.good.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12)),
            ],
          ),
          child: const Icon(Icons.check, size: 44, color: Colors.white),
        ),
        const SizedBox(height: 14),
        Text('Job complete', style: AppText.h1().copyWith(color: Colors.white)),
        const SizedBox(height: 5),
        Text('Paid instantly via UPI',
            style: AppText.body().copyWith(color: WColors.teal300)),
      ],
    );
  }

  Widget _payoutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.paper0,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.lg,
      ),
      child: Column(
        children: [
          Text('PAYOUT',
              style: AppText.overline().copyWith(color: AppColors.ink500, fontSize: 11)),
          const SizedBox(height: 6),
          Text('₹380',
              style: AppText.displayNum(56,
                  color: AppColors.greenForest700, weight: FontWeight.w800)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: AppColors.greenLeaf50,
                borderRadius: BorderRadius.circular(999)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.green600),
                const SizedBox(width: 7),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: 'sent to ',
                      style: AppText.bodySm().copyWith(color: AppColors.ink700)),
                  TextSpan(
                      text: 'ravi@okaxis',
                      style: AppText.bodySm().copyWith(
                          color: AppColors.greenForest800,
                          fontWeight: FontWeight.w700)),
                ])),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: 'UPI ref ', style: AppText.caption().copyWith(color: AppColors.ink500)),
                TextSpan(text: '4072 1183', style: AppText.caption().copyWith(color: AppColors.ink700, fontWeight: FontWeight.w600)),
              ])),
              const SizedBox(width: 12),
              Text('·', style: AppText.caption().copyWith(color: AppColors.ink500)),
              const SizedBox(width: 12),
              Text('9:54 AM', style: AppText.caption().copyWith(color: AppColors.ink500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: WColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: WColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('JOB SUMMARY',
              style: AppText.overline().copyWith(color: WColors.fg3, fontSize: 11)),
          _summaryRow(Icons.spa_outlined, 'Coconut husking', '24 nuts'),
          const Divider(color: WColors.line, height: 1),
          _summaryRow(Icons.schedule, 'Time on site', '1h 28m'),
          const Divider(color: WColors.line, height: 1),
          _summaryRow(Icons.place_outlined, 'Parambil Estate', 'Ollur'),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(icon, size: 18, color: WColors.teal300),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppText.body().copyWith(color: WColors.fg2)),
          ),
          Text(value,
              style: AppText.bodySm().copyWith(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _ratingCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: BoxDecoration(
        color: WColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: WColors.line),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.greenLeaf100),
                child: Text('A',
                    style: AppText.displayNum(15, color: AppColors.greenForest700)),
              ),
              const SizedBox(width: 10),
              Text('Rate the site manager',
                  style: AppText.title().copyWith(fontSize: 16, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 4),
          Text('How was working with Arjun?',
              style: AppText.bodySm().copyWith(color: WColors.fg3)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int n = 1; n <= 5; n++)
                GestureDetector(
                  onTap: () => setState(() => _rating = n),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      n <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 40,
                      color: n <= _rating ? WColors.accent : WColors.lineStrong,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_words[_rating] ?? '',
              style: AppText.button().copyWith(color: WColors.accent2, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: GestureDetector(
        onTap: _finish,
        child: Container(
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: [
              BoxShadow(
                  color: Colors.white.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: Text('Submit & go home',
              style: AppText.button().copyWith(color: WColors.bg, fontSize: 18)),
        ),
      ),
    );
  }
}
