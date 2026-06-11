import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/design_tokens.dart';
import '../../../app/router.dart';
import '../../../core/models/site_manager_profile.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/site_manager_providers.dart';
import '../widgets/sm_widgets.dart';

/// Admin-approval gate. After the student submits their college ID, this screen
/// blocks all job dispatch until an admin sets `verified: true` on
/// `/site_managers/{uid}`. Once verified, it unlocks the daily queue.
class CollegeVerificationScreen extends ConsumerWidget {
  const CollegeVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final profile = ref.watch(siteManagerProfileProvider(uid)).value;
    final verified = profile?.verified ?? false;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SmBrandHeader(
            child: Row(
              children: [
                Expanded(
                  child: Text('Account verification',
                      style: AppText.h2().copyWith(color: Colors.white)),
                ),
                IconButton(
                  tooltip: 'Sign out',
                  onPressed: () => ref.read(authServiceProvider).signOut(),
                  icon: const Icon(Icons.logout, color: AppColors.greenSage400),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpace.s4),
              children: [
                const SizedBox(height: 12),
                _statusHero(verified),
                const SizedBox(height: AppSpace.s5),
                if (profile != null) _detailsCard(profile),
                const SizedBox(height: AppSpace.s4),
                if (!verified) _stepsCard(),
                const SizedBox(height: AppSpace.s5),
                if (verified)
                  SmButton(
                    label: 'Continue to today\'s jobs',
                    icon: Icons.arrow_forward,
                    kind: SmButtonKind.brand,
                    large: true,
                    onTap: () => context.go(AppRoutes.managerHome),
                  )
                else
                  Center(
                    child: Text(
                      'You\'ll get a notification the moment you\'re approved.',
                      textAlign: TextAlign.center,
                      style:
                          AppText.bodySm().copyWith(color: AppColors.fg3),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusHero(bool verified) {
    final color = verified ? AppColors.green600 : AppColors.accent;
    final bg = verified ? AppColors.statusCompleteBg : AppColors.amber100;
    return SmCard(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(
                verified ? Icons.verified : Icons.hourglass_top_rounded,
                size: 40,
                color: color),
          ),
          const SizedBox(height: 16),
          Text(verified ? 'You\'re verified' : 'Verification pending',
              style: AppText.h2().copyWith(color: AppColors.fg1)),
          const SizedBox(height: 8),
          Text(
            verified
                ? 'Your college ID was approved. You can now receive and run harvest jobs.'
                : 'Our team is reviewing your college ID. Job dispatch unlocks automatically once you\'re approved.',
            textAlign: TextAlign.center,
            style: AppText.body().copyWith(color: AppColors.fg2),
          ),
          const SizedBox(height: 16),
          SmSpill(
            verified ? 'Verified' : 'Awaiting admin review',
            kind: verified ? SmSpillKind.done : SmSpillKind.progress,
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(SiteManagerProfile p) {
    return SmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SmOverline('Submitted details'),
          const SizedBox(height: 12),
          _row(Icons.school_outlined, 'College', p.collegeName),
          _row(Icons.badge_outlined, 'Roll number', p.rollNumber),
          if (p.branch != null)
            _row(Icons.account_tree_outlined, 'Branch', p.branch!.label),
          if (p.yearOfStudy != null)
            _row(Icons.event_outlined, 'Year', p.yearOfStudy!.label),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.greenSage500),
          const SizedBox(width: 10),
          Text(label, style: AppText.bodySm().copyWith(color: AppColors.fg3)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: AppText.bodySm().copyWith(
                    color: AppColors.fg1, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _stepsCard() {
    const steps = [
      ('ID submitted', 'Your college ID is queued for review', true),
      ('Admin review', 'A team member confirms your enrolment', false),
      ('Approved', 'Jobs start arriving in your daily queue', false),
    ];
    return SmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SmOverline('What happens next'),
          const SizedBox(height: 14),
          for (int i = 0; i < steps.length; i++)
            _stepRow(steps[i].$1, steps[i].$2, steps[i].$3,
                last: i == steps.length - 1),
        ],
      ),
    );
  }

  Widget _stepRow(String title, String sub, bool done, {required bool last}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.statusCompleteBg : AppColors.surfaceSunk,
                  border: Border.all(
                      color: done ? AppColors.green600 : AppColors.borderStrong,
                      width: 2),
                ),
                child: done
                    ? const Icon(Icons.check, size: 15, color: AppColors.green600)
                    : null,
              ),
              if (!last)
                Expanded(
                  child: Container(
                      width: 2,
                      color: AppColors.border,
                      margin: const EdgeInsets.symmetric(vertical: 2)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppText.title()
                          .copyWith(fontSize: 15, color: AppColors.fg1)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: AppText.bodySm().copyWith(color: AppColors.fg3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
