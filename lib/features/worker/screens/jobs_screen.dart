import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../theme/worker_theme.dart';

/// Worker "Jobs" tab — upcoming work grouped by day + completed history with
/// ratings. Matches `Designs/ThengaPari Worker App/screen-jobs.jsx`.
///
/// Data is demo/static for now (mirrors the design); a later step wires it to
/// `/jobs` filtered by `workerId`.
class WorkerJobsTab extends StatefulWidget {
  const WorkerJobsTab({super.key});

  @override
  State<WorkerJobsTab> createState() => _WorkerJobsTabState();
}

class _UpcomingJob {
  final String time, ampm, title, place, dist, payout;
  final bool isNext;
  const _UpcomingJob(this.time, this.ampm, this.title, this.place, this.dist,
      this.payout, this.isNext);
}

class _HistoryJob {
  final String date, title, place, count, payout;
  final int rating;
  const _HistoryJob(
      this.date, this.title, this.place, this.count, this.payout, this.rating);
}

const _today = <_UpcomingJob>[
  _UpcomingJob('11:00', 'AM', 'Tender coconut climb', 'Maple Grove', '2.4 km', '420', true),
  _UpcomingJob('1:30', 'PM', 'Coconut husking', 'Parambil Estate', '1.8 km', '380', false),
  _UpcomingJob('4:00', 'PM', 'Palm trimming', 'Vadakke Padam', '3.1 km', '300', false),
];

const _tomorrow = <_UpcomingJob>[
  _UpcomingJob('8:30', 'AM', 'Coconut climbing', 'Cheruvath Farm', '4.2 km', '460', false),
  _UpcomingJob('2:00', 'PM', 'Coconut husking', 'Kunnath Grove', '2.0 km', '350', false),
];

const _history = <_HistoryJob>[
  _HistoryJob('Yesterday', 'Coconut husking', 'Parambil Estate', '24 nuts', '380', 5),
  _HistoryJob('Yesterday', 'Palm trimming', 'Vadakke Padam', '6 palms', '300', 4),
  _HistoryJob('Mon 2 Jun', 'Tender coconut climb', 'Maple Grove', '32 nuts', '420', 5),
  _HistoryJob('Sun 1 Jun', 'Coconut climbing', 'Cheruvath Farm', '5 trees', '460', 5),
  _HistoryJob('Sat 31 May', 'Coconut husking', 'Kunnath Grove', '22 nuts', '340', 4),
];

class _WorkerJobsTabState extends State<WorkerJobsTab> {
  bool _upcoming = true;

  @override
  Widget build(BuildContext context) {
    final weekEarned = _history.fold<int>(0, (a, b) => a + int.parse(b.payout)) + 1100;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const WScreenHeader(
            title: 'Your jobs',
            subtitle: 'Upcoming & completed work',
            trailing: WHeaderIconBtn(icon: Icons.calendar_month_outlined),
          ),
          Row(
            children: [
              Expanded(
                child: WMiniStat(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Earned this week',
                  child: WRupee(inrGroup(weekEarned), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WMiniStat(
                  icon: Icons.check_circle_outline,
                  label: 'Jobs this week',
                  child: Text('9', style: AppText.displayNum(24, color: WColors.fg1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _segmented(),
          const SizedBox(height: 18),
          if (_upcoming) ...[
            _dayGroup('TODAY', _today.length),
            for (final j in _today) ...[_upcomingCard(j), const SizedBox(height: 10)],
            const SizedBox(height: 8),
            _dayGroup('TOMORROW', _tomorrow.length),
            for (final j in _tomorrow) ...[_upcomingCard(j), const SizedBox(height: 10)],
          ] else ...[
            for (final j in _history) ...[_historyRow(j), const SizedBox(height: 10)],
            const SizedBox(height: 6),
            Center(
              child: Text('Showing last 7 days',
                  style: AppText.caption().copyWith(color: WColors.fg3)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _segmented() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: WColors.surface2,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: WColors.line),
      ),
      child: Row(
        children: [
          _segBtn('Upcoming', _upcoming, () => setState(() => _upcoming = true)),
          _segBtn('History', !_upcoming, () => setState(() => _upcoming = false)),
        ],
      ),
    );
  }

  Widget _segBtn(String label, bool on, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? WColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: on
                ? [
                    BoxShadow(
                        color: WColors.accent.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4)),
                  ]
                : null,
          ),
          child: Text(label,
              style: AppText.button().copyWith(
                  fontSize: 14,
                  color: on ? WColors.accentPress : WColors.fg2)),
        ),
      ),
    );
  }

  Widget _dayGroup(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Text(label,
              style: AppText.overline().copyWith(
                  color: WColors.fg2, letterSpacing: 1.4, fontSize: 11.5)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0x24F4A52A),
                borderRadius: BorderRadius.circular(999)),
            child: Text('$count',
                style: AppText.caption().copyWith(
                    color: WColors.accent2, fontWeight: FontWeight.w700, fontSize: 11)),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: WColors.line, height: 1)),
        ],
      ),
    );
  }

  Widget _upcomingCard(_UpcomingJob j) {
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
                Text(j.time, style: AppText.displayNum(17, color: WColors.fg1)),
                const SizedBox(height: 3),
                Text(j.ampm, style: AppText.caption().copyWith(color: WColors.fg3)),
              ],
            ),
          ),
          Container(
              width: 1,
              height: 40,
              color: WColors.line,
              margin: const EdgeInsets.symmetric(horizontal: 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(j.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title().copyWith(fontSize: 16, color: WColors.fg1)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 13, color: WColors.fg3),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text('${j.place} · ${j.dist}',
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
              WRupee(j.payout, size: 18),
              const SizedBox(height: 6),
              WTag(
                text: j.isNext ? 'UP NEXT' : 'SCHEDULED',
                fg: j.isNext ? WColors.accent2 : WColors.teal300,
                bg: j.isNext ? const Color(0x29F4A52A) : const Color(0x246FB6AB),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _historyRow(_HistoryJob j) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: WColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: WColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: WColors.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_outline, size: 20, color: WColors.good),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(j.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title().copyWith(fontSize: 16, color: WColors.fg1)),
                const SizedBox(height: 4),
                Text('${j.place} · ${j.count}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption().copyWith(color: WColors.fg3)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              WRupee(j.payout, size: 17),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 13, color: WColors.accent),
                  const SizedBox(width: 3),
                  Text('${j.rating}.0',
                      style: AppText.caption().copyWith(
                          color: WColors.fg2, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
