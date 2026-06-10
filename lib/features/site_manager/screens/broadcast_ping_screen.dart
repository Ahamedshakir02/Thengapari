import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/design_tokens.dart';
import '../../../core/models/harvest_job.dart';
import '../../../core/models/job_step.dart';
import '../../../core/models/processor_response.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/site_manager_providers.dart';
import '../widgets/sm_widgets.dart';

/// One-tap broadcast to nearby processors + a live stream of Accept responses.
/// This closes the weight-loss gap — it must fire the instant yield is weighed.
/// Matches `Designs/ThengaPari Site Manager App/screen4.jsx`.
class BroadcastPingScreen extends ConsumerStatefulWidget {
  final HarvestJob job;
  const BroadcastPingScreen({super.key, required this.job});

  @override
  ConsumerState<BroadcastPingScreen> createState() =>
      _BroadcastPingScreenState();
}

class _BroadcastPingScreenState extends ConsumerState<BroadcastPingScreen> {
  bool _live = false;
  bool _broadcasting = false;
  String? _assignedId;

  Future<void> _broadcast() async {
    setState(() => _broadcasting = true);
    final job = widget.job;
    final loc = job.location;
    try {
      await ref.read(siteManagerServiceProvider).broadcastProcessorPing(
            jobId: job.id,
            cropType: job.cropTypes.isEmpty ? 'coconut' : job.cropTypes.first,
            yieldKg: job.actualYieldKg ?? 0,
            lat: loc?.latitude ?? 10.0,
            lng: loc?.longitude ?? 76.3,
          );
    } catch (_) {
      // Broadcast is fire-and-forget; responses still stream in via Firestore.
    }
    if (!mounted) return;
    setState(() {
      _broadcasting = false;
      _live = true;
    });
  }

  Future<void> _assign(ProcessorResponse r) async {
    setState(() => _assignedId = r.id);
    final uid = ref.read(authStateProvider).value?.uid ?? '';
    try {
      final svc = ref.read(siteManagerServiceProvider);
      await svc.assignProcessor(
          jobId: widget.job.id, pingId: r.id, workerId: r.workerId);
      await svc.completeStep(
          jobId: widget.job.id, uid: uid, kind: ManagerStepKind.pingSent);
    } catch (_) {/* keep optimistic assignment */}
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SmPaperHeader(
            title: 'Broadcast ping',
            subtitle:
                '${_homeowner(job)} · ${(job.actualYieldKg ?? 0).toStringAsFixed(1)} kg ready',
            trailing: _live
                ? const SmSpill('Live', kind: SmSpillKind.error)
                : null,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpace.s4),
              children: [
                _urgencyBanner(),
                const SizedBox(height: AppSpace.s4),
                if (!_live)
                  ..._readyPhase()
                else
                  _LiveResponses(
                    jobId: job.id,
                    assignedId: _assignedId,
                    onAssign: _assign,
                  ),
              ],
            ),
          ),
          if (_assignedId != null) _confirmBar(),
        ],
      ),
    );
  }

  Widget _urgencyBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: AppColors.amber100,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.amber200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppRadii.md)),
            child: const Icon(Icons.bolt,
                size: 22, color: AppColors.greenForest900),
          ),
          const SizedBox(width: AppSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Time-sensitive · fresh yield',
                    style: AppText.title().copyWith(
                        fontSize: 16, color: AppColors.statusInprogressFg)),
                const SizedBox(height: 2),
                Text(
                    'Fresh yield grades best within 4 hours. Broadcast to nearby processors now.',
                    style: AppText.bodySm().copyWith(color: AppColors.fg2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _readyPhase() {
    return [
      SmCard(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        child: Column(
          children: [
            _avatarStack(),
            const SizedBox(height: 12),
            Text('18', style: AppText.displayNum(44, color: AppColors.brandInk)),
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: 'processors active within ',
                  style: AppText.body().copyWith(color: AppColors.fg2)),
              TextSpan(
                  text: '3 km',
                  style: AppText.body().copyWith(
                      color: AppColors.fg1, fontWeight: FontWeight.w700)),
            ])),
          ],
        ),
      ),
      const SizedBox(height: AppSpace.s4),
      SmButton(
        label: 'Broadcast to 18 processors',
        icon: Icons.podcasts,
        kind: SmButtonKind.accent,
        large: true,
        loading: _broadcasting,
        onTap: _broadcast,
      ),
      const SizedBox(height: 10),
      Center(
        child: Text(
            'They get yield, grade & location. You assign the best responder.',
            textAlign: TextAlign.center,
            style: AppText.caption().copyWith(color: AppColors.fg3)),
      ),
    ];
  }

  Widget _avatarStack() {
    const colors = [
      AppColors.greenForest700,
      AppColors.greenSage500,
      AppColors.teal500,
      AppColors.amber500,
      AppColors.green600,
    ];
    const letters = ['A', 'F', 'D', 'M', '+'];
    return SizedBox(
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < colors.length; i++)
            Transform.translate(
              offset: Offset((i - 2) * 26.0, 0),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2.5),
                ),
                child: Text(letters[i],
                    style: AppText.displayNum(13, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _confirmBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.s4, AppSpace.s3, AppSpace.s4, AppSpace.s3),
          child: SmButton(
            label: 'Confirm pickup & return to job',
            icon: Icons.check,
            kind: SmButtonKind.brand,
            large: true,
            onTap: () => context.pop(),
          ),
        ),
      ),
    );
  }

  static String _homeowner(HarvestJob job) =>
      job.notes.isNotEmpty ? job.notes : (job.address ?? 'Homeowner');
}

/// Live status strip + streamed Accept responses (`pingResponsesProvider`).
class _LiveResponses extends ConsumerWidget {
  final String jobId;
  final String? assignedId;
  final void Function(ProcessorResponse) onAssign;
  const _LiveResponses(
      {required this.jobId, required this.assignedId, required this.onAssign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responses =
        ref.watch(pingResponsesProvider(jobId)).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _stat('Sent', '18', AppColors.fg1),
            const SizedBox(width: AppSpace.s2),
            _stat('Viewing', '11', AppColors.accent),
            const SizedBox(width: AppSpace.s2),
            _stat('Accepted', '${responses.length}', AppColors.green600),
          ],
        ),
        const SizedBox(height: AppSpace.s4),
        const SmOverline('Incoming responses'),
        const SizedBox(height: AppSpace.s3),
        if (responses.isEmpty)
          SmCard(
            padding: const EdgeInsets.symmetric(vertical: 26),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppColors.accent, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('Waiting for processors to accept…',
                      style: AppText.body().copyWith(color: AppColors.fg3)),
                ],
              ),
            ),
          )
        else
          for (final r in responses) ...[
            _ResponseCard(
              response: r,
              assigned: assignedId == r.id,
              anyAssigned: assignedId != null,
              onAssign: () => onAssign(r),
            ),
            const SizedBox(height: AppSpace.s3),
          ],
      ],
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: SmCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(value, style: AppText.displayNum(24, color: color)),
            SmOverline(label),
          ],
        ),
      ),
    );
  }
}

class _ResponseCard extends StatelessWidget {
  final ProcessorResponse response;
  final bool assigned;
  final bool anyAssigned;
  final VoidCallback onAssign;
  const _ResponseCard({
    required this.response,
    required this.assigned,
    required this.anyAssigned,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final dim = anyAssigned && !assigned;
    return Opacity(
      opacity: dim ? 0.5 : 1,
      child: SmCard(
        border: Border.all(
            color: assigned ? AppColors.green600 : AppColors.border,
            width: assigned ? 2 : 1),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: AppColors.greenLeaf100, shape: BoxShape.circle),
                  child: Text(_initials(response.name),
                      style: AppText.displayNum(18,
                          color: AppColors.greenForest700)),
                ),
                const SizedBox(width: AppSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(response.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.title().copyWith(
                                    fontSize: 16, color: AppColors.fg1)),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star,
                              size: 14, color: AppColors.accent),
                          const SizedBox(width: 2),
                          Text(response.rating.toStringAsFixed(1),
                              style: AppText.caption().copyWith(
                                  color: AppColors.fg1,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text('${response.typeLabel} · ${response.jobsCompleted} jobs',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppText.caption().copyWith(color: AppColors.fg3)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.s3),
            Row(
              children: [
                SmChip('${response.distanceKm.toStringAsFixed(1)} km',
                    icon: Icons.place_outlined, kind: SmChipKind.line),
                const SizedBox(width: AppSpace.s2),
                SmChip('${response.etaMin} min',
                    icon: Icons.schedule, kind: SmChipKind.line),
                const Spacer(),
                if (assigned)
                  const SmSpill('Assigned', kind: SmSpillKind.done)
                else
                  GestureDetector(
                    onTap: onAssign,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.brand,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Text('Assign',
                          style: AppText.button().copyWith(
                              color: AppColors.onBrand, fontSize: 15)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final s = parts.map((p) => p.isEmpty ? '' : p[0]).join();
    return s.length <= 2 ? s.toUpperCase() : s.substring(0, 2).toUpperCase();
  }
}
