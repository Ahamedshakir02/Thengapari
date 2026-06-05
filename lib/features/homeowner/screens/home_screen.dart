import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/models/crop_summary.dart';
import '../../../core/models/tree_inventory.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/homeowner_providers.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/crop_inventory_row.dart';
import '../../../core/widgets/hero_landscape_widget.dart';
import '../../../core/widgets/job_status_card.dart';
import '../../../core/widgets/painters/weekly_earnings_chart_painter.dart';
import '../../../core/widgets/role_nav_bars.dart';
import '../../../core/widgets/shimmer_job_card.dart';
import '../../../core/widgets/stat_card.dart';

/// Homeowner dashboard. Hero greeting, live crop chips, earnings stats, weekly
/// chart, and the real-time active-job card. Matches app-screens-home.jsx.
class HomeownerHomeScreen extends ConsumerWidget {
  const HomeownerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final uid = user?.uid ?? '';
    final greeting = _greetingForNow();
    final firstName = (user?.firstName?.trim().isNotEmpty ?? false)
        ? user!.firstName!
        : 'there';

    return Scaffold(
      backgroundColor: AgriColors.surface,
      bottomNavigationBar: const HomeownerBottomNav(currentIndex: 0),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          HeroLandscapeWidget(
            greeting: '$greeting,',
            subtitle: firstName,
            topInset: MediaQuery.of(context).padding.top,
          ),
          const SizedBox(height: 16),

          // ---- Your crops ----
          _SectionLabel('Your crops'),
          const SizedBox(height: 8),
          _CropChips(uid: uid),
          const SizedBox(height: 16),

          // ---- Stats ----
          _StatsRow(uid: uid),
          const SizedBox(height: 14),

          // ---- Weekly earnings ----
          _WeeklyEarningsCard(uid: uid),
          const SizedBox(height: 14),

          // ---- Active job ----
          _SectionLabel('Active job'),
          const SizedBox(height: 8),
          _ActiveJob(uid: uid),
          const SizedBox(height: 16),

          // ---- Book CTA ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: AppButton(
              label: 'Book a harvest',
              icon: Icons.add,
              onPressed: () => context.push(AppRoutes.homeownerBook),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _greetingForNow() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6E6B60),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

/// Live crop chips from the tree inventory stream.
class _CropChips extends ConsumerWidget {
  final String uid;
  const _CropChips({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trees = ref.watch(treeInventoryProvider(uid));
    return trees.when(
      data: (list) {
        if (list.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text('No trees yet — add them from your profile.',
                style: TextStyle(fontSize: 12, color: Color(0xFF908C7E))),
          );
        }
        final crops = [
          for (final t in list)
            CropSummary(
              name: t.type.label,
              icon: t.type.emoji,
              quantity: t.type == CropType.pepper ? '~${t.count} kg' : '×${t.count}',
            ),
        ];
        return CropInventoryRow(crops: crops);
      },
      loading: () => const SizedBox(
          height: 40,
          child: Center(
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)))),
      error: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Text('Could not load your crops.',
            style: TextStyle(fontSize: 12, color: Color(0xFF908C7E))),
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              value: earnings.when(
                data: (v) => '₹${v.toStringAsFixed(0)}',
                loading: () => '…',
                error: (_, _) => '--',
              ),
              label: 'Yield earned',
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: StatCard(
              value: '0.8 kg',
              label: 'Weight saved vs before',
              valueColor: AgriColors.amber600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyEarningsCard extends ConsumerWidget {
  final String uid;
  const _WeeklyEarningsCard({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekly = ref.watch(weeklyEarningsProvider(uid));
    final data = weekly.maybeWhen(
      data: (list) =>
          list.any((v) => v > 0) ? list : const <double>[0, 0, 0, 0, 0, 0],
      orElse: () => const <double>[0, 0, 0, 0, 0, 0],
    );
    final total = data.fold<double>(0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AgriColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Weekly earnings',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF173404))),
                const Spacer(),
                Text('₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AgriColors.green800)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 85,
              child: CustomPaint(
                painter: WeeklyEarningsChartPainter(weeklyEarnings: data),
                child: const SizedBox(width: double.infinity),
              ),
            ),
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
    return job.when(
      data: (j) {
        if (j == null) return const _NoActiveJob();
        return GestureDetector(
          onTap: () =>
              context.push('${AppRoutes.homeownerTracker}?jobId=${j.id}'),
          child: JobStatusCard(
            title: j.title,
            status: j.badgeStatus,
            detail: j.siteManagerId != null
                ? 'Site Manager assigned'
                : 'Finding a site manager…',
            rightDetail: j.district ?? '',
            progress: j.progress,
          ),
        );
      },
      loading: () => const ShimmerJobCard(),
      error: (_, _) => const _NoActiveJob(),
    );
  }
}

class _NoActiveJob extends StatelessWidget {
  const _NoActiveJob();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgriColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AgriColors.green50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco_outlined,
                color: AgriColors.green600, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('No active harvest. Book one to get started.',
                style: TextStyle(fontSize: 13, color: Color(0xFF4A4840))),
          ),
        ],
      ),
    );
  }
}
