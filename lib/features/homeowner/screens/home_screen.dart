import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/design_tokens.dart';
import '../../../app/router.dart';
import '../../../core/models/tree_inventory.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/homeowner_providers.dart';
import '../../../core/widgets/app_icon.dart';
import '../widgets/home_widgets.dart';

/// Homeowner dashboard, matched to `app-screens-home.jsx` / `app.css`:
/// landscape hero + greeting, live crop chips, two stat cards, weekly-earnings
/// bar chart, real-time active-job card, and the Book CTA.
class HomeownerHomeScreen extends ConsumerWidget {
  const HomeownerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final uid = user?.uid ?? '';
    final firstName = (user?.firstName?.trim().isNotEmpty ?? false)
        ? user!.firstName!
        : 'there';

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const HomeBottomNav(currentIndex: 0),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          HomeHero(
            greetingSmall: '${_greeting()},',
            name: firstName,
            sub: 'Your grove is looking healthy',
            topInset: MediaQuery.of(context).padding.top,
          ),
          const SizedBox(height: 16),

          const SectionHead('Your crops'),
          const SizedBox(height: 10),
          _CropChips(uid: uid),
          const SizedBox(height: 16),

          _StatsRow(uid: uid),
          const SizedBox(height: 14),

          _WeeklyEarnings(uid: uid),
          const SizedBox(height: 14),

          const SectionHead('Active job'),
          const SizedBox(height: 8),
          _ActiveJob(uid: uid),
          const SizedBox(height: 18),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
            child: FilledButton(
              onPressed: () => context.push(AppRoutes.homeownerBook),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon('plus',
                      size: 20, color: AppColors.onBrand, strokeWidth: 2.2),
                  const SizedBox(width: 9),
                  Text('Book a harvest', style: AppText.button()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _CropChips extends ConsumerWidget {
  final String uid;
  const _CropChips({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trees = ref.watch(treeInventoryProvider(uid));
    return trees.when(
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
            child: Text('No trees yet — add them from your profile.',
                style: AppText.caption()),
          );
        }
        return SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(AppSpace.gutter, 0, AppSpace.gutter, 0),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final t = list[i];
              final count =
                  t.type == CropType.pepper ? '~${t.count} kg' : '×${t.count}';
              return Center(child: HomeCropChip(type: t.type, count: count));
            },
          ),
        );
      },
      loading: () => const SizedBox(
          height: 56,
          child: Center(
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)))),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
        child: Text('Could not load your crops.', style: AppText.caption()),
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  final String uid;
  const _StatsRow({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earnings = ref.watch(monthlyEarningsProvider(uid));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
      child: Row(
        children: [
          Expanded(
            child: HomeStatCard(
              iconName: 'rupee',
              iconBg: AppColors.greenLeaf100,
              iconFg: AppColors.brand,
              value: earnings.when(
                data: (v) => '₹${v.toStringAsFixed(0)}',
                loading: () => '…',
                error: (_, _) => '--',
              ),
              label: 'Yield earned',
              trend: '+12% this season',
              trendIcon: Icons.trending_up,
              trendBg: AppColors.statusCompleteBg,
              trendFg: AppColors.statusCompleteFg,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: HomeStatCard(
              iconName: 'feather',
              iconBg: AppColors.amber100,
              iconFg: AppColors.statusInprogressFg,
              value: '0.8 kg',
              label: 'Weight saved',
              trend: 'vs market',
              trendIcon: Icons.straighten,
              trendBg: AppColors.amber100,
              trendFg: AppColors.statusInprogressFg,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyEarnings extends ConsumerWidget {
  final String uid;
  const _WeeklyEarnings({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekly = ref.watch(weeklyEarningsProvider(uid));
    final values = weekly.maybeWhen(
      data: (list) =>
          list.any((v) => v > 0) ? list : const <double>[0, 0, 0, 0, 0, 0],
      orElse: () => const <double>[0, 0, 0, 0, 0, 0],
    );
    final labels = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6'];
    final data = <(String, double)>[
      for (int i = 0; i < values.length && i < labels.length; i++)
        (labels[i], values[i]),
    ];
    final total = values.fold<double>(0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: Text('Weekly earnings', style: AppText.h3())),
                Text('₹${total.toStringAsFixed(0)}',
                    style: AppText.caption().copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandInk)),
              ],
            ),
            const SizedBox(height: 14),
            WeeklyBarChart(data: data),
          ],
        ),
      ),
    );
  }
}

class _ActiveJob extends ConsumerWidget {
  final String uid;
  const _ActiveJob({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(activeJobProvider(uid));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
      child: job.when(
        data: (j) {
          if (j == null) return const _NoActiveJob();
          final crop =
              CropType.fromString(j.cropTypes.isEmpty ? null : j.cropTypes.first) ??
                  CropType.coconut;
          return ActiveJobCard(
            thumbCrop: crop,
            title: j.title,
            meta: j.siteManagerId != null
                ? 'Site Manager assigned'
                : 'Finding a site manager…',
            progress: j.progress ?? 0.1,
            etaText: 'Site Manager · ${j.district ?? 'nearby'}',
            managerInitials: 'SM',
            onTrack: () =>
                context.push('${AppRoutes.homeownerTracker}?jobId=${j.id}'),
          );
        },
        loading: () => const _JobSkeleton(),
        error: (_, _) => const _NoActiveJob(),
      ),
    );
  }
}

class _JobSkeleton extends StatelessWidget {
  const _JobSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))),
    );
  }
}

class _NoActiveJob extends StatelessWidget {
  const _NoActiveJob();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceSunk,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppIcon('leaf', size: 20, color: AppColors.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('No active harvest. Book one to get started.',
                style: AppText.bodySm().copyWith(color: AppColors.fg2)),
          ),
        ],
      ),
    );
  }
}
