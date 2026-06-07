import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/design_tokens.dart';
import '../../../app/router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/worker_providers.dart';
import '../theme/worker_theme.dart';
import 'jobs_screen.dart';
import 'profile_screen.dart';
import 'wallet_screen.dart';

import 'package:go_router/go_router.dart';

/// Worker daily command center. Online toggle, today's stats, reliability
/// score, confirmed jobs, and the weekly earnings chart. Matches
/// `Designs/ThengaPari Worker App/screen-home.jsx`.
class WorkerHomeScreen extends ConsumerStatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  ConsumerState<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends ConsumerState<WorkerHomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final uid = user?.uid ?? '';

    // Seed the availability toggle from the live profile, once.
    ref.listen(workerProfileProvider(uid), (_, next) {
      final p = next.value;
      if (p != null) {
        ref.read(workerAvailabilityProvider.notifier).seed(p.isOnline);
      }
    });

    return Scaffold(
      backgroundColor: WColors.bg,
      body: IndexedStack(
        index: _tab,
        children: [
          _HomeTab(uid: uid, name: user?.firstName ?? 'there'),
          const WorkerJobsTab(),
          const WorkerWalletTab(),
          const WorkerProfileTab(),
        ],
      ),
      bottomNavigationBar: _WorkerBottomNav(
        index: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

// ───────────────────────────── Home tab ─────────────────────────────

class _HomeTab extends ConsumerWidget {
  final String uid;
  final String name;
  const _HomeTab({required this.uid, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(workerAvailabilityProvider);
    final profile = ref.watch(workerProfileProvider(uid)).value;
    final stats = ref.watch(workerDayStatsProvider(uid)).value ??
        const WorkerDayStats();
    final jobs =
        ref.watch(workerConfirmedJobsProvider(uid)).value ?? const [];
    final week =
        ref.watch(workerWeeklyEarningsProvider(uid)).value ??
            const [0.0, 0, 0, 0, 0, 0, 0];
    final reliability = (profile?.reliabilityScore ?? 100).round();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          _header(online),
          const SizedBox(height: 18),
          _BigToggle(
            online: online,
            onToggle: () =>
                ref.read(workerAvailabilityProvider.notifier).toggle(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: "Today's earnings",
                  accent: true,
                  value: '₹${_inr(stats.earningsToday)}',
                  sub: '+₹380 last job',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Jobs completed',
                  value: '${stats.jobsCompletedToday}',
                  sub: '2 climbs · 2 husks',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ReliabilityCard(score: reliability),
          const SizedBox(height: 22),
          _SectionHead(
            title: "Today's confirmed jobs",
            trailing: _Pill(text: '${jobs.length}'),
          ),
          if (jobs.isEmpty)
            _emptyJobs()
          else
            for (final j in jobs) ...[
              _JobCard(job: j),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 22),
          _WeeklyCard(week: week),
          const SizedBox(height: 20),
          _demoPingButton(context),
        ],
      ),
    );
  }

  Widget _demoPingButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.workerPing),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: WColors.lineStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt, size: 15, color: WColors.accent2),
            const SizedBox(width: 8),
            Text('Demo · trigger a job ping',
                style: AppText.bodySm().copyWith(color: WColors.fg3)),
          ],
        ),
      ),
    );
  }

  Widget _header(bool online) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.displayNum(22, color: WColors.fg1),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 14, color: WColors.teal300),
                  const SizedBox(width: 5),
                  Text('Ollur, Thrissur',
                      style: AppText.bodySm().copyWith(color: WColors.fg2)),
                ],
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [WColors.glowTop, WColors.bg2],
                ),
                border: Border.all(color: WColors.lineStrong),
              ),
              child: Text(
                (name.isNotEmpty ? name[0] : 'W').toUpperCase(),
                style: AppText.displayNum(19, color: WColors.teal100),
              ),
            ),
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: online ? WColors.good : WColors.fg3,
                  border: Border.all(color: WColors.bg, width: 3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _emptyJobs() => Container(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
        decoration: BoxDecoration(
          color: WColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: WColors.line),
        ),
        child: Center(
          child: Text('No confirmed jobs today.\nGo online to receive pings.',
              textAlign: TextAlign.center,
              style: AppText.bodySm().copyWith(color: WColors.fg3)),
        ),
      );

  static String _greeting(String name) {
    final h = DateTime.now().hour;
    final part = h < 12
        ? 'Good morning'
        : h < 17
            ? 'Good afternoon'
            : 'Good evening';
    return '$part, $name';
  }

  static String _inr(double v) {
    final s = v.round().toString();
    if (s.length <= 3) return s;
    final head = s.substring(0, s.length - 3);
    final tail = s.substring(s.length - 3);
    final buf = StringBuffer();
    for (int i = 0; i < head.length; i++) {
      final fromEnd = head.length - i;
      buf.write(head[i]);
      if (fromEnd > 1 && fromEnd % 2 == 1) buf.write(',');
    }
    return '$buf,$tail';
  }
}

// ───────────────────────────── Big toggle ─────────────────────────────

class _BigToggle extends StatelessWidget {
  final bool online;
  final VoidCallback onToggle;
  const _BigToggle({required this.online, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          gradient: online
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [WColors.glowTop, WColors.surface2],
                )
              : null,
          color: online ? null : WColors.surface2,
          border: Border.all(
              color: online ? const Color(0x4D6FB6AB) : WColors.line),
          boxShadow: online
              ? [
                  BoxShadow(
                      color: WColors.teal500.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10)),
                ]
              : null,
        ),
        child: Row(
          children: [
            _PulseDot(online: online),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(online ? "You're online" : "You're offline",
                      style: AppText.h3().copyWith(color: WColors.fg1)),
                  const SizedBox(height: 2),
                  Text(online ? 'Receiving job pings' : 'Go online to earn',
                      style: AppText.bodySm().copyWith(
                          color: online ? WColors.teal300 : WColors.fg3)),
                ],
              ),
            ),
            _Switch(online: online),
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final bool online;
  const _PulseDot({required this.online});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.online)
            AnimatedBuilder(
              animation: _c,
              builder: (_, _) {
                final t = _c.value;
                return Container(
                  width: 14 + t * 12,
                  height: 14 + t * 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: WColors.good.withValues(alpha: (1 - t) * 0.5),
                  ),
                );
              },
            ),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.online ? WColors.good : WColors.fg3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool online;
  const _Switch({required this.online});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: online ? WColors.accent : const Color(0x2ED6ECE7),
        boxShadow: online
            ? [
                BoxShadow(
                    color: WColors.accent.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 4)),
              ]
            : null,
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: online ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Color(0x4D000000),
                    blurRadius: 6,
                    offset: Offset(0, 2)),
              ],
            ),
            child: online
                ? const Icon(Icons.bolt, size: 16, color: WColors.accentPress)
                : null,
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── Stat card ─────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final bool accent;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: accent
            ? const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0x29F4A52A), Color(0x0AF4A52A)],
              )
            : null,
        color: accent ? null : WColors.surface,
        border: Border.all(color: accent ? const Color(0x47F4A52A) : WColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent ? WColors.accent2 : WColors.teal300),
              const SizedBox(width: 7),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption()
                        .copyWith(color: WColors.fg2, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: AppText.displayNum(30, color: WColors.fg1)),
          const SizedBox(height: 7),
          Text(sub, style: AppText.caption().copyWith(color: WColors.fg3)),
        ],
      ),
    );
  }
}

// ─────────────────────────── Reliability ───────────────────────────

class _ReliabilityCard extends StatelessWidget {
  final int score;
  const _ReliabilityCard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: WColors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: CustomPaint(
              painter: _RingPainter(score / 100),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$score',
                        style: AppText.displayNum(24, color: WColors.fg1)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text('%',
                          style: AppText.caption().copyWith(
                              color: WColors.fg3, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        size: 17, color: WColors.accent2),
                    const SizedBox(width: 7),
                    Text('Reliability score',
                        style: AppText.title()
                            .copyWith(fontSize: 16, color: WColors.fg1)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Top 8% of climbers in Thrissur',
                    style: AppText.bodySm().copyWith(color: WColors.fg2)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _metric('47/50', 'on time'),
                    const SizedBox(width: 14),
                    _metric('0', 'no-shows'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String value, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: AppText.caption().copyWith(
                  color: WColors.teal100,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
          const SizedBox(width: 4),
          Text(label, style: AppText.caption().copyWith(color: WColors.fg3)),
        ],
      );
}

class _RingPainter extends CustomPainter {
  final double value; // 0..1
  _RingPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0x24D6ECE7);
    canvas.drawCircle(center, radius, track);

    final color = value >= 0.8
        ? WColors.accent
        : value >= 0.6
            ? WColors.accent2
            : const Color(0xFFF08A6A);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value.clamp(0, 1),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}

// ───────────────────────────── Job card ─────────────────────────────

class _JobCard extends StatelessWidget {
  final WorkerConfirmedJob job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final (h, ampm) = _time(job.scheduledAt);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: WColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: WColors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Column(
              children: [
                Text(h,
                    style: AppText.displayNum(17, color: WColors.fg1)),
                const SizedBox(height: 3),
                Text(ampm, style: AppText.caption().copyWith(color: WColors.fg3)),
              ],
            ),
          ),
          Container(
              width: 1, height: 40, color: WColors.line, margin: const EdgeInsets.symmetric(horizontal: 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title().copyWith(fontSize: 16, color: WColors.fg1)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 13, color: WColors.fg3),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text('${job.place} · ${job.distance}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodySm().copyWith(color: WColors.fg2)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${job.payout.round()}',
                  style: AppText.displayNum(18, color: WColors.fg1)),
              const SizedBox(height: 6),
              _Tag(
                text: job.isNext ? 'UP NEXT' : 'SCHEDULED',
                fg: job.isNext ? WColors.accent2 : WColors.teal300,
                bg: job.isNext ? const Color(0x29F4A52A) : const Color(0x246FB6AB),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static (String, String) _time(DateTime d) {
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    return ('$hour12:$mm', d.hour < 12 ? 'AM' : 'PM');
  }
}

// ─────────────────────────── Weekly chart ───────────────────────────

class _WeeklyCard extends StatelessWidget {
  final List<double> week;
  const _WeeklyCard({required this.week});

  @override
  Widget build(BuildContext context) {
    final total = week.fold<double>(0, (a, b) => a + b);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: WColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: WColors.line),
      ),
      child: Column(
        children: [
          _SectionHead(
            title: 'This week',
            dense: true,
            trailing: Text('₹${(total / 1000).toStringAsFixed(1)}k',
                style: AppText.displayNum(17, color: WColors.teal100)),
          ),
          SizedBox(
            height: 132,
            child: _WeeklyChart(week: week),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<double> week;
  const _WeeklyChart({required this.week});

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final max = week.fold<double>(1, math.max);
    final todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < 7; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == 6 ? 0 : 8),
              child: _bar(week[i], max, _labels[i], i == todayIdx),
            ),
          ),
      ],
    );
  }

  Widget _bar(double v, double max, String label, bool isToday) {
    final h = math.max(8.0, (v / max) * 96);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          v == 0
              ? '—'
              : v >= 1000
                  ? '${(v / 1000).toStringAsFixed(1)}k'
                  : v.round().toString(),
          style: AppText.caption().copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isToday ? WColors.accent2 : WColors.fg3),
        ),
        const SizedBox(height: 7),
        Container(
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isToday
                  ? const [WColors.accent2, WColors.accent]
                  : const [WColors.teal500, WColors.glowTop],
            ),
            boxShadow: isToday
                ? [
                    BoxShadow(
                        color: WColors.accent.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4)),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 7),
        Text(label,
            style: AppText.caption().copyWith(
                fontSize: 11,
                color: isToday ? WColors.fg1 : WColors.fg3,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500)),
      ],
    );
  }
}

// ─────────────────────────── Small atoms ───────────────────────────

class _SectionHead extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool dense;
  const _SectionHead({required this.title, this.trailing, this.dense = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: dense ? 10 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.h3().copyWith(color: WColors.fg1)),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x24F4A52A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: AppText.caption().copyWith(
              color: WColors.accent2, fontWeight: FontWeight.w700)),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;
  const _Tag({required this.text, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style: AppText.overline()
              .copyWith(color: fg, fontSize: 10, letterSpacing: 0.5)),
    );
  }
}

// ─────────────────────────── Bottom nav ───────────────────────────

class _WorkerBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _WorkerBottomNav({required this.index, required this.onTap});

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.work_outline, Icons.work, 'Jobs'),
    (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Wallet'),
    (Icons.person_outline, Icons.person, 'You'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: WColors.bgDeep,
        border: Border(top: BorderSide(color: WColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < _items.length; i++)
                _navItem(i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i) {
    final on = i == index;
    final (off, active, label) = _items[i];
    final color = on ? WColors.accent2 : WColors.fg3;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(i),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(on ? active : off, size: 23, color: color),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10.5,
                    color: color,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Placeholder tabs ───────────────────────────

