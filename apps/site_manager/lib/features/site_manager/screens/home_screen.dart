import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:site_manager/router.dart';
import 'package:core/core/models/harvest_job.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/site_manager_providers.dart';
import '../widgets/sm_widgets.dart';
import 'daily_queue_screen.dart';
import 'navigation_to_site_screen.dart';
import 'on_site_screen.dart';

/// Site Manager shell: the four bottom-nav destinations (Today / On-site /
/// Earnings / Profile). Tab selection is driven by [managerTabProvider] so
/// pushed flows (e.g. check-in) can jump straight to On-site.
class SiteManagerHomeScreen extends ConsumerWidget {
  const SiteManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(managerTabProvider);
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final jobs = ref.watch(todayJobsProvider(uid)).value ?? const <HarvestJob>[];
    final active = _activeJob(jobs);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: tab,
        children: [
          DailyQueueScreen(
            onOpenJob: (_) => ref.read(managerTabProvider.notifier).state = 1,
            onNavigate: (job) => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => NavigationToSiteScreen(job: job)),
            ),
          ),
          active != null
              ? OnSiteScreen(key: ValueKey(active.id), job: active)
              : const _NoActiveJob(),
          const _EarningsTab(),
          const _ProfileTab(),
        ],
      ),
      bottomNavigationBar: SmBottomNav(
        index: tab,
        onTap: (i) => ref.read(managerTabProvider.notifier).state = i,
      ),
    );
  }

  static HarvestJob? _activeJob(List<HarvestJob> jobs) {
    const activeStatuses = {
      'in_progress',
      'harvesting',
      'processing',
      'byproducts_routed',
    };
    for (final j in jobs) {
      if (activeStatuses.contains(j.status)) return j;
    }
    return jobs.isNotEmpty ? jobs.first : null;
  }
}

class _NoActiveJob extends StatelessWidget {
  const _NoActiveJob();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SmBrandHeader(
          child: Text('On-site',
              style: AppText.h2().copyWith(color: Colors.white)),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 56, color: AppColors.borderStrong),
                  const SizedBox(height: 14),
                  Text('No active job',
                      style: AppText.title().copyWith(color: AppColors.fg2)),
                  const SizedBox(height: 6),
                  Text('Open a job from Today to start the on-site checklist.',
                      textAlign: TextAlign.center,
                      style: AppText.bodySm().copyWith(color: AppColors.fg3)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EarningsTab extends StatelessWidget {
  const _EarningsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SmBrandHeader(
          child: Text('Earnings',
              style: AppText.h2().copyWith(color: Colors.white)),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpace.s4),
            children: [
              Row(
                children: [
                  Expanded(
                    child: SmCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SmOverline('This week'),
                          const SizedBox(height: 8),
                          Text('₹4,820',
                              style:
                                  AppText.displayNum(28, color: AppColors.fg1)),
                          Text('6 jobs supervised',
                              style: AppText.caption()
                                  .copyWith(color: AppColors.fg3)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s3),
                  Expanded(
                    child: SmCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SmOverline('Avg rating'),
                          const SizedBox(height: 8),
                          Text('4.8',
                              style: AppText.displayNum(28,
                                  color: AppColors.green600)),
                          Text('from homeowners',
                              style: AppText.caption()
                                  .copyWith(color: AppColors.fg3)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s4),
              SmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SmOverline('Payouts'),
                    const SizedBox(height: 12),
                    Text('Per-job payouts land in your UPI after each harvest is marked complete.',
                        style:
                            AppText.bodySm().copyWith(color: AppColors.fg2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final uid = user?.uid ?? '';
    final profile = ref.watch(siteManagerProfileProvider(uid)).value;
    final name = [user?.firstName, user?.lastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');

    return Column(
      children: [
        SmBrandHeader(
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle),
                child: Text(
                    (name.isNotEmpty ? name[0] : 'S').toUpperCase(),
                    style: AppText.displayNum(22, color: Colors.white)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isEmpty ? 'Site Manager' : name,
                        style: AppText.h3().copyWith(color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(profile?.collegeName ?? 'Student supervisor',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodySm()
                            .copyWith(color: AppColors.greenLeaf200)),
                  ],
                ),
              ),
              if (profile?.verified ?? false)
                const Icon(Icons.verified, color: AppColors.accent, size: 24),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpace.s4),
            children: [
              Row(
                children: [
                  Expanded(
                      child: _stat('Rating',
                          (profile?.rating ?? 0).toStringAsFixed(1))),
                  const SizedBox(width: AppSpace.s3),
                  Expanded(
                      child: _stat(
                          'Jobs done', '${profile?.jobsCompleted ?? 0}')),
                ],
              ),
              const SizedBox(height: AppSpace.s4),
              _tile(Icons.school_outlined, 'Training',
                  profile?.trainingComplete ?? false
                      ? 'Certified'
                      : 'Finish to unlock dispatch',
                  () => context.push(AppRoutes.managerTraining)),
              _tile(Icons.verified_user_outlined, 'Verification',
                  profile?.verified ?? false ? 'Verified' : 'Pending review',
                  () => context.push(AppRoutes.managerVerification)),
              _tile(Icons.help_outline, 'Help & support', 'FAQs and contact',
                  () {}),
              const SizedBox(height: AppSpace.s4),
              SmButton(
                label: 'Sign out',
                icon: Icons.logout,
                kind: SmButtonKind.ghost,
                onTap: () => ref.read(authServiceProvider).signOut(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value) => SmCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SmOverline(label),
            const SizedBox(height: 6),
            Text(value, style: AppText.displayNum(26, color: AppColors.fg1)),
          ],
        ),
      );

  Widget _tile(IconData icon, String title, String sub, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s3),
      child: GestureDetector(
        onTap: onTap,
        child: SmCard(
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.brand),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppText.title()
                            .copyWith(fontSize: 16, color: AppColors.fg1)),
                    Text(sub,
                        style:
                            AppText.caption().copyWith(color: AppColors.fg3)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.fg3),
            ],
          ),
        ),
      ),
    );
  }
}
