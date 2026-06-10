import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/design_tokens.dart';
import '../../../core/models/harvest_job.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/site_manager_providers.dart';
import '../widgets/sm_widgets.dart';

/// Morning overview: every job assigned for today, list or map. Matches
/// `Designs/ThengaPari Site Manager App/screen1.jsx`.
class DailyQueueScreen extends ConsumerStatefulWidget {
  /// Open the (active) job's on-site dashboard.
  final void Function(HarvestJob job) onOpenJob;

  /// Start navigation to a scheduled job's site.
  final void Function(HarvestJob job) onNavigate;

  const DailyQueueScreen(
      {super.key, required this.onOpenJob, required this.onNavigate});

  @override
  ConsumerState<DailyQueueScreen> createState() => _DailyQueueScreenState();
}

class _DailyQueueScreenState extends ConsumerState<DailyQueueScreen> {
  int _view = 0; // 0 = list, 1 = map

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final jobsAsync = ref.watch(todayJobsProvider(uid));
    final jobs = jobsAsync.value ?? const <HarvestJob>[];
    final now = DateTime.now();

    return Column(
      children: [
        SmBrandHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SmOverline(DateFormat('EEEE · d MMMM').format(now),
                            color: AppColors.greenSage400),
                        const SizedBox(height: 3),
                        Text(
                            'Today · ${jobs.length} ${jobs.length == 1 ? "job" : "jobs"}',
                            style: AppText.h2().copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadii.md)),
                    child: const Icon(Icons.eco, color: Colors.white, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s4),
              _statusStrip(jobs),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.s4, AppSpace.s4, AppSpace.s4, AppSpace.s2),
          child: SmSegmented(
            index: _view,
            items: const [
              (icon: Icons.format_list_bulleted, label: 'List'),
              (icon: Icons.map_outlined, label: 'Map'),
            ],
            onTap: (i) => setState(() => _view = i),
          ),
        ),
        Expanded(
          child: jobsAsync.isLoading
              ? const Center(child: CircularProgressIndicator())
              : jobs.isEmpty
                  ? _empty()
                  : _view == 0
                      ? _list(jobs)
                      : _map(jobs),
        ),
      ],
    );
  }

  Widget _statusStrip(List<HarvestJob> jobs) {
    final done = jobs.where((j) => j.isComplete).length;
    final active = jobs.where((j) => j.status == 'in_progress' ||
        j.status == 'harvesting' ||
        j.status == 'processing' ||
        j.status == 'byproducts_routed').length;
    final upcoming = jobs.length - done - active;
    final items = [
      ('$done done', AppColors.greenSage400),
      ('$active active', AppColors.accent),
      ('$upcoming upcoming', AppColors.greenSage400),
    ];
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadii.md)),
              child: Row(
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: items[i].$2, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(items[i].$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption().copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          if (i < items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _list(List<HarvestJob> jobs) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.s4, AppSpace.s2, AppSpace.s4, AppSpace.s6),
      itemCount: jobs.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpace.s3),
      itemBuilder: (_, i) => _QueueJobCard(
        job: jobs[i],
        onOpen: () => widget.onOpenJob(jobs[i]),
        onNavigate: () => widget.onNavigate(jobs[i]),
      ),
    );
  }

  Widget _map(List<HarvestJob> jobs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.s4, AppSpace.s2, AppSpace.s4, AppSpace.s6),
      child: _QueueMapView(jobs: jobs),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_available_outlined,
                size: 56, color: AppColors.borderStrong),
            const SizedBox(height: 14),
            Text('No jobs assigned today',
                style: AppText.title().copyWith(color: AppColors.fg2)),
            const SizedBox(height: 6),
            Text('New assignments arrive as homeowners book harvests.',
                textAlign: TextAlign.center,
                style: AppText.bodySm().copyWith(color: AppColors.fg3)),
          ],
        ),
      ),
    );
  }
}

class _QueueJobCard extends StatelessWidget {
  final HarvestJob job;
  final VoidCallback onOpen;
  final VoidCallback onNavigate;
  const _QueueJobCard(
      {required this.job, required this.onOpen, required this.onNavigate});

  bool get _isActive =>
      job.status == 'in_progress' ||
      job.status == 'harvesting' ||
      job.status == 'processing' ||
      job.status == 'byproducts_routed';

  @override
  Widget build(BuildContext context) {
    final (time, ampm) = _time(job.scheduledAt);
    return Stack(
      children: [
        SmCard(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.s4),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 58,
                      child: Column(
                        children: [
                          Text(time,
                              style: AppText.h3().copyWith(
                                  color: _isActive
                                      ? AppColors.brand
                                      : AppColors.fg1)),
                          const SizedBox(height: 3),
                          SmOverline(ampm),
                        ],
                      ),
                    ),
                    Container(
                        width: 1,
                        height: 56,
                        color: AppColors.border,
                        margin: const EdgeInsets.symmetric(horizontal: 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(_homeownerName(job),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.title()
                                        .copyWith(color: AppColors.fg1)),
                              ),
                              if (_isActive)
                                const SmSpill('Active',
                                    kind: SmSpillKind.progress)
                              else
                                Row(
                                  children: [
                                    const Icon(Icons.place_outlined,
                                        size: 14, color: AppColors.fg3),
                                    const SizedBox(width: 3),
                                    Text(_distance(job),
                                        style: AppText.caption()
                                            .copyWith(color: AppColors.fg3)),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.place_outlined,
                                  size: 14, color: AppColors.fg3),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                    '${job.district ?? "Site"} · ${job.cropTypes.length} crop${job.cropTypes.length == 1 ? "" : "s"}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.bodySm()
                                        .copyWith(color: AppColors.fg3)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final c in job.cropTypes)
                                SmChip(_cap(c),
                                    icon: Icons.eco,
                                    kind: c.toLowerCase() == 'tender'
                                        ? SmChipKind.amber
                                        : SmChipKind.leaf),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.s4),
                if (_isActive)
                  SmButton(
                    label: 'Open job',
                    trailingIcon: Icons.chevron_right,
                    onTap: onOpen,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: SmButton(
                          label: 'Navigate',
                          icon: Icons.navigation_outlined,
                          kind: SmButtonKind.ghost,
                          onTap: onNavigate,
                        ),
                      ),
                      const SizedBox(width: AppSpace.s2),
                      Expanded(
                        child: SmButton(
                          label: 'Details',
                          kind: SmButtonKind.soft,
                          onTap: onNavigate,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (_isActive)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 5,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(AppRadii.lg)),
              ),
            ),
          ),
      ],
    );
  }

  static String _homeownerName(HarvestJob job) {
    if (job.notes.isNotEmpty) return job.notes;
    return job.address ?? "Homeowner's property";
  }

  static String _distance(HarvestJob job) => job.district ?? '—';

  static String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static (String, String) _time(DateTime? d) {
    if (d == null) return ('—', '');
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return ('$h12:${d.minute.toString().padLeft(2, '0')}',
        d.hour < 12 ? 'AM' : 'PM');
  }
}

/// Faux green map with road lines + job pins (Google Maps stand-in for review).
class _QueueMapView extends StatelessWidget {
  final List<HarvestJob> jobs;
  const _QueueMapView({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapPainter())),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SmCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.navigation_outlined,
                      size: 20, color: AppColors.brand),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: 'Total route ',
                          style: AppText.bodySm()
                              .copyWith(color: AppColors.fg2)),
                      TextSpan(
                          text: '${(jobs.length * 3.0).toStringAsFixed(1)} km',
                          style: AppText.bodySm().copyWith(
                              color: AppColors.fg1,
                              fontWeight: FontWeight.w700)),
                      TextSpan(
                          text: ' · ~${jobs.length * 8} min drive',
                          style: AppText.bodySm()
                              .copyWith(color: AppColors.fg2)),
                    ])),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Leaf-green gradient base
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.greenLeaf100, AppColors.greenLeaf300],
        ).createShader(rect),
    );
    // grid
    final grid = Paint()
      ..color = AppColors.greenSage400.withValues(alpha: 0.4)
      ..strokeWidth = 2;
    for (double y = 0.15; y < 1; y += 0.28) {
      canvas.drawLine(Offset(0, y * h), Offset(w, y * h), grid);
    }
    for (double x = 0.25; x < 1; x += 0.3) {
      canvas.drawLine(Offset(x * w, 0), Offset(x * w, h), grid);
    }
    // roads
    final road = Paint()
      ..color = AppColors.paper50
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final p1 = Path()
      ..moveTo(-10, 0.28 * h)
      ..quadraticBezierTo(0.3 * w, 0.2 * h, 0.55 * w, 0.38 * h)
      ..quadraticBezierTo(0.8 * w, 0.5 * h, w + 10, 0.36 * h);
    final p2 = Path()
      ..moveTo(0.18 * w, -10)
      ..quadraticBezierTo(0.28 * w, 0.4 * h, 0.2 * w, 0.7 * h)
      ..quadraticBezierTo(0.16 * w, 0.95 * h, 0.34 * w, h + 10);
    canvas.drawPath(p1, road);
    canvas.drawPath(p2, road);

    // pins
    final pins = [
      (Offset(0.46 * w, 0.34 * h), true, 'now'),
      (Offset(0.24 * w, 0.6 * h), false, '11:30'),
      (Offset(0.74 * w, 0.74 * h), false, '2:15'),
    ];
    for (final (pos, active, _) in pins) {
      final color = active ? AppColors.accent : AppColors.brand;
      canvas.drawCircle(pos.translate(0, -4), 13, Paint()..color = color);
      final tail = Path()
        ..moveTo(pos.dx - 8, pos.dy - 2)
        ..lineTo(pos.dx + 8, pos.dy - 2)
        ..lineTo(pos.dx, pos.dy + 10)
        ..close();
      canvas.drawPath(tail, Paint()..color = color);
      canvas.drawCircle(pos.translate(0, -5), 5,
          Paint()..color = active ? AppColors.greenForest900 : Colors.white);
    }
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => false;
}
