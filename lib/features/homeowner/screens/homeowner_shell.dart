import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/design_tokens.dart';
import '../../../app/router.dart';
import '../../../core/models/harvest_job.dart';
import '../../../core/models/tree_inventory.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/homeowner_providers.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/job_status_badge.dart';
import '../widgets/home_widgets.dart';
import 'home_screen.dart';
import 'yield_report_screen.dart';

/// Homeowner app shell — owns the bottom nav and switches between the four
/// tabs (Home · Schedule · Reports · Profile). This makes the nav functional.
class HomeownerShell extends StatefulWidget {
  const HomeownerShell({super.key});

  @override
  State<HomeownerShell> createState() => _HomeownerShellState();
}

class _HomeownerShellState extends State<HomeownerShell> {
  int _index = 0;

  static const _tabs = [
    HomeownerHomeScreen(),
    _ScheduleTab(),
    YieldReportScreen(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ─────────────────────────── Schedule tab ───────────────────────────

class _ScheduleTab extends ConsumerWidget {
  const _ScheduleTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final jobsAsync = ref.watch(homeownerJobsProvider(uid));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Schedule')),
      body: jobsAsync.when(
        data: (jobs) {
          final upcoming = jobs.where((j) => j.isActive).toList();
          final past = jobs.where((j) => j.isComplete).toList();
          if (jobs.isEmpty) {
            return _empty('No harvests scheduled yet.');
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter, 12, AppSpace.gutter, 20),
            children: [
              if (upcoming.isNotEmpty) ...[
                _eyebrow('UPCOMING'),
                for (final j in upcoming) _JobRow(job: j),
                const SizedBox(height: 18),
              ],
              if (past.isNotEmpty) ...[
                _eyebrow('PAST HARVESTS'),
                for (final j in past) _JobRow(job: j),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _empty('Could not load your schedule.'),
      ),
    );
  }

  Widget _eyebrow(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: AppText.overline().copyWith(letterSpacing: 1)),
      );

  Widget _empty(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(msg,
              textAlign: TextAlign.center,
              style: AppText.bodySm().copyWith(color: AppColors.fg3)),
        ),
      );
}

class _JobRow extends StatelessWidget {
  final HarvestJob job;
  const _JobRow({required this.job});

  @override
  Widget build(BuildContext context) {
    final crop =
        CropType.fromString(job.cropTypes.isEmpty ? null : job.cropTypes.first) ??
            CropType.coconut;
    final when = job.completedAt ?? job.scheduledAt;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CropPalette.tint(crop),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CropGlyph(crop, size: 24, color: CropPalette.fg(crop)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title,
                    style: AppText.title().copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                    job.isComplete && job.earningsAmount != null
                        ? '₹${job.earningsAmount!.toStringAsFixed(0)}'
                        : (job.district ?? 'Your property'),
                    style: AppText.caption().copyWith(fontSize: 12.5)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(when == null ? '' : _fmt(when),
                  style: AppText.caption().copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.fg1)),
              const SizedBox(height: 5),
              JobStatusBadge(status: job.badgeStatus),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[d.month - 1]} ${d.day}';
  }
}

// ─────────────────────────── Profile tab ───────────────────────────

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final uid = user?.uid ?? '';
    final name = [user?.firstName, user?.lastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');
    final trees = ref.watch(treeInventoryProvider(uid)).maybeWhen(
        data: (t) => t.fold<int>(0, (a, b) => a + b.count), orElse: () => 0);
    final lang = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.gutter, 12, AppSpace.gutter, 20),
        children: [
          // Header
          Container(
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
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.greenSage500, AppColors.brand],
                    ),
                  ),
                  child: Text(
                      (name.isNotEmpty ? name[0] : 'T').toUpperCase(),
                      style: AppText.displayNum(24, color: Colors.white)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.isEmpty ? 'ThengaPari user' : name,
                          style: AppText.h3()),
                      const SizedBox(height: 2),
                      Text(
                          '${user?.district ?? 'Kerala'} · $trees trees',
                          style: AppText.caption().copyWith(fontSize: 12.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Items
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.sm,
            ),
            child: Column(
              children: [
                _item(context, 'tree', 'My grove', '$trees trees',
                    onTap: () => context.push(AppRoutes.homeownerTreeSetup)),
                _item(context, 'wallet', 'Payouts & payment', '',
                    onTap: () => context.push(AppRoutes.homeownerPayment)),
                _item(context, 'recycle', 'AMC subscription', '',
                    onTap: () => context.push(AppRoutes.homeownerAmc)),
                _item(context, 'globe', 'Language',
                    lang == AppLang.ml ? 'മലയാളം' : 'English',
                    onTap: () => ref.read(localeProvider.notifier).toggle()),
                _item(context, 'shield', 'Help & support', '',
                    onTap: () => _showHelp(context)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => ref.read(authServiceProvider).signOut(),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: AppColors.borderStrong, width: 1.5),
              ),
              child: Text('Sign out',
                  style: AppText.button().copyWith(color: AppColors.statusErrorFg)),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Help & support'),
        content: const Text(
            'Call ThengaPari support at 1800-123-4567 (8am–8pm), or email '
            'help@thengapari.in. We typically reply within a day.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String icon, String label, String meta,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceSunk,
              borderRadius: BorderRadius.circular(11),
            ),
            child: AppIcon(icon, size: 20, color: AppColors.brand),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(label,
                style: AppText.bodySm().copyWith(
                    fontSize: 15, color: AppColors.fg1)),
          ),
          if (meta.isNotEmpty)
            Text(meta, style: AppText.caption().copyWith(fontSize: 12.5)),
          const SizedBox(width: 6),
          AppIcon('chevron-right', size: 18, color: AppColors.fg3),
        ],
      ),
      ),
    );
  }
}
