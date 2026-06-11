import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:site_manager/router.dart';
import 'package:core/core/models/harvest_job.dart';
import 'package:core/core/models/job_step.dart';
import 'package:core/core/models/yield_data.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/site_manager_providers.dart';
import '../widgets/sm_widgets.dart';

/// The primary on-site operations dashboard: a Firestore-driven checklist with
/// sequential step unlocking, the live yield donut, and the processor-ping CTA.
/// Matches `Designs/ThengaPari Site Manager App/screen2.jsx`. Rendered inside
/// the Site Manager shell's "On-site" tab.
class OnSiteScreen extends ConsumerStatefulWidget {
  final HarvestJob job;
  const OnSiteScreen({super.key, required this.job});

  @override
  ConsumerState<OnSiteScreen> createState() => _OnSiteScreenState();
}

class _OnSiteScreenState extends ConsumerState<OnSiteScreen> {
  // Stable check-in time for the elapsed timer (demo seeds ~38 min in).
  late final DateTime _since =
      DateTime.now().subtract(const Duration(minutes: 38, seconds: 12));

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final steps = ref.watch(jobStepsProvider(job.id)).value ?? const <JobStep>[];
    final yieldData =
        ref.watch(yieldDataProvider(job.id)).value ?? const YieldData();

    final pingStep = steps.where((s) => s.kind == ManagerStepKind.pingSent);
    final pingActive =
        pingStep.isNotEmpty && pingStep.first.status == StepStatus.active;
    final pingDone =
        pingStep.isNotEmpty && pingStep.first.status == StepStatus.done;

    return Column(
      children: [
        _header(job),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpace.s4),
            children: [
              _yieldCard(yieldData),
              const SizedBox(height: AppSpace.s4),
              SmButton(
                label: pingDone ? 'View broadcast · live' : 'Ping processors now',
                icon: Icons.podcasts,
                kind: SmButtonKind.accent,
                large: true,
                onTap: (pingActive || pingDone)
                    ? () => context.push(AppRoutes.managerBroadcast, extra: job)
                    : null,
              ),
              const SizedBox(height: AppSpace.s4),
              _checklistCard(steps),
              const SizedBox(height: AppSpace.s4),
              _quickActions(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header(HarvestJob job) {
    return SmBrandHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SmSpill('On site', kind: SmSpillKind.progress),
              const SizedBox(width: 10),
              Text('Job #${_shortId(job.id)}',
                  style:
                      AppText.caption().copyWith(color: AppColors.greenSage400)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_homeownerName(job),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.h2().copyWith(color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('${job.title} · started ${_fmt(_since)}',
                        style: AppText.bodySm()
                            .copyWith(color: AppColors.greenLeaf200)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SmOverline('Elapsed', color: AppColors.greenSage400),
                  const SizedBox(height: 2),
                  ElapsedTimer(
                    since: _since,
                    style: AppText.displayNum(26, color: AppColors.accent),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _yieldCard(YieldData y) {
    final total = y.totalNuts;
    return SmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SmOverline('Yield logged'),
              SmChip(total == 0 ? 'Awaiting' : 'Grading',
                  icon: Icons.check, kind: SmChipKind.leaf),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              GradeDonut(
                gradeA: y.gradeA,
                gradeB: y.gradeB,
                tender: y.tender,
                size: 124,
                thickness: 19,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(y.totalKg.toStringAsFixed(1),
                        style: AppText.displayNum(26, color: AppColors.fg1)),
                    const SmOverline('kg total'),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.s4),
              Expanded(
                child: Column(
                  children: [
                    SmLegendRow(
                        color: CropGrade.gradeA.color,
                        label: CropGrade.gradeA.label,
                        value: '${y.gradeA}'),
                    SmLegendRow(
                        color: CropGrade.gradeB.color,
                        label: CropGrade.gradeB.label,
                        value: '${y.gradeB}'),
                    SmLegendRow(
                        color: CropGrade.tender.color,
                        label: CropGrade.tender.label,
                        value: '${y.tender}'),
                    const Divider(height: 14, color: AppColors.border),
                    Row(
                      children: [
                        Expanded(
                          child: Text('$total nuts · est.',
                              style: AppText.bodySm()
                                  .copyWith(color: AppColors.fg3)),
                        ),
                        Text('₹${_inr(YieldData.estimate(y.gradeA, y.gradeB, y.tender))}',
                            style: AppText.title().copyWith(
                                fontSize: 16, color: AppColors.green600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _checklistCard(List<JobStep> steps) {
    return SmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SmOverline('Site checklist'),
          const SizedBox(height: AppSpace.s4),
          for (int i = 0; i < steps.length; i++)
            _StepTile(
              step: steps[i],
              isLast: i == steps.length - 1,
              onTap: () => _handleStepTap(steps[i]),
            ),
        ],
      ),
    );
  }

  void _handleStepTap(JobStep step) {
    if (step.status != StepStatus.active) return;
    final job = widget.job;
    switch (step.kind) {
      case ManagerStepKind.yieldWeighed:
        context.push(AppRoutes.managerWeigh, extra: job);
      case ManagerStepKind.pingSent:
        context.push(AppRoutes.managerBroadcast, extra: job);
      case ManagerStepKind.byproductsRouted:
        context.push(AppRoutes.managerByproduct, extra: job);
      case ManagerStepKind.reportSubmitted:
        context.push(AppRoutes.managerReport, extra: job);
      default:
        _completeManualStep(step.kind);
    }
  }

  Future<void> _completeManualStep(ManagerStepKind kind) async {
    final uid = ref.read(authStateProvider).value?.uid ?? '';
    final status = switch (kind) {
      ManagerStepKind.harvestStarted => 'harvesting',
      _ => null,
    };
    try {
      await ref.read(siteManagerServiceProvider).completeStep(
            jobId: widget.job.id,
            uid: uid,
            kind: kind,
            jobStatus: status,
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not update: $e')));
    }
  }

  Widget _quickActions() {
    return Row(
      children: [
        _action(Icons.photo_camera_outlined, 'Photo'),
        const SizedBox(width: AppSpace.s2),
        _action(Icons.edit_note_outlined, 'Note worker'),
        const SizedBox(width: AppSpace.s2),
        _action(Icons.emergency_outlined, 'Emergency'),
      ],
    );
  }

  Widget _action(IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('$label — coming soon'))),
        child: SmCard(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, size: 22, color: AppColors.brand),
              const SizedBox(height: 6),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption().copyWith(color: AppColors.fg2)),
            ],
          ),
        ),
      ),
    );
  }

  static String _shortId(String id) {
    final s = id.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    return s.length <= 6 ? s : s.substring(0, 6);
  }

  static String _homeownerName(HarvestJob job) =>
      job.notes.isNotEmpty ? job.notes : (job.address ?? 'Homeowner');

  static String _fmt(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '$h12:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? "AM" : "PM"}';
  }

  static String _inr(num v) {
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

/// One checklist row: timeline rail (done/active/pending) + label + time + CTA.
class _StepTile extends StatelessWidget {
  final JobStep step;
  final bool isLast;
  final VoidCallback onTap;
  const _StepTile(
      {required this.step, required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = step.status == StepStatus.active;
    final done = step.status == StepStatus.done;
    final (ringBg, ringBorder) = switch (step.status) {
      StepStatus.done => (AppColors.statusCompleteBg, AppColors.green600),
      StepStatus.active => (AppColors.amber100, AppColors.accent),
      StepStatus.pending => (AppColors.surfaceSunk, AppColors.borderStrong),
    };
    return GestureDetector(
      onTap: active ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ringBg,
                    border: Border.all(color: ringBorder, width: 2.5),
                    boxShadow: active
                        ? [
                            BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.35),
                                blurRadius: 10,
                                spreadRadius: 1)
                          ]
                        : null,
                  ),
                  child: done
                      ? const Icon(Icons.check,
                          size: 20, color: AppColors.green600)
                      : Icon(step.kind.icon,
                          size: 18,
                          color: active
                              ? AppColors.statusInprogressFg
                              : AppColors.ink400),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: done ? AppColors.greenSage400 : AppColors.border,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpace.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(step.label,
                              style: AppText.title().copyWith(
                                  fontSize: 16,
                                  color: step.status == StepStatus.pending
                                      ? AppColors.fg3
                                      : AppColors.fg1)),
                        ),
                        if (done && step.completedAt != null)
                          Text(_fmtTime(step.completedAt!),
                              style: AppText.caption().copyWith(
                                  color: AppColors.green600,
                                  fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(step.kind.sub,
                        style:
                            AppText.bodySm().copyWith(color: AppColors.fg3)),
                    if (active) ...[
                      const SizedBox(height: AppSpace.s3),
                      SmButton(
                        label: step.kind.cta ?? 'Mark done',
                        trailingIcon: Icons.chevron_right,
                        kind: SmButtonKind.accent,
                        onTap: onTap,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtTime(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '$h12:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? "AM" : "PM"}';
  }
}
