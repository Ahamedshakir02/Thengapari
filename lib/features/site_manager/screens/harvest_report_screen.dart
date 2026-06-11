import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/design_tokens.dart';
import '../../../app/router.dart';
import '../../../core/models/harvest_job.dart';
import '../../../core/models/job_step.dart';
import '../../../core/models/yield_data.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/site_manager_providers.dart';
import '../widgets/sm_widgets.dart';

/// Generate + share the final harvest report and mark the job complete. Marking
/// complete triggers `markJobComplete` (payouts to worker + site manager, and
/// the "Harvest complete" notification to the homeowner).
class HarvestReportScreen extends ConsumerStatefulWidget {
  final HarvestJob job;
  const HarvestReportScreen({super.key, required this.job});

  @override
  ConsumerState<HarvestReportScreen> createState() =>
      _HarvestReportScreenState();
}

class _HarvestReportScreenState extends ConsumerState<HarvestReportScreen> {
  bool _signed = false;
  bool _generating = false;
  bool _completing = false;
  String? _pdfUrl;

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      final url = await ref
          .read(siteManagerServiceProvider)
          .generateHarvestReport(widget.job.id);
      if (!mounted) return;
      setState(() {
        _pdfUrl = url;
        _generating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _generating = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not generate: $e')));
    }
  }

  Future<void> _share() async {
    await SharePlus.instance.share(ShareParams(
      text: 'ThengaPari harvest report: ${_pdfUrl ?? ''}',
    ));
  }

  Future<void> _markComplete() async {
    final uid = ref.read(authStateProvider).value?.uid ?? '';
    setState(() => _completing = true);
    try {
      final svc = ref.read(siteManagerServiceProvider);
      await svc.completeStep(
          jobId: widget.job.id,
          uid: uid,
          kind: ManagerStepKind.reportSubmitted);
      await svc.markJobComplete(
          jobId: widget.job.id, reportUrl: _pdfUrl ?? '');
      if (!mounted) return;
      ref.read(managerTabProvider.notifier).state = 0; // back to Today
      context.go(AppRoutes.managerHome);
    } catch (e) {
      if (!mounted) return;
      setState(() => _completing = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not complete: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final y = ref.watch(yieldDataProvider(job.id)).value ?? const YieldData();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SmPaperHeader(
            title: 'Harvest report',
            subtitle: '${_homeowner(job)} · ${job.title}',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpace.s4),
              children: [
                _previewCard(job, y),
                const SizedBox(height: AppSpace.s4),
                _signoffCard(),
                const SizedBox(height: AppSpace.s4),
                if (_pdfUrl == null)
                  SmButton(
                    label: 'Generate report PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    kind: SmButtonKind.brand,
                    large: true,
                    loading: _generating,
                    onTap: _signed ? _generate : null,
                  )
                else ...[
                  _readyCard(),
                  const SizedBox(height: AppSpace.s3),
                  Row(
                    children: [
                      Expanded(
                        child: SmButton(
                          label: 'WhatsApp',
                          icon: Icons.chat_outlined,
                          kind: SmButtonKind.soft,
                          onTap: _share,
                        ),
                      ),
                      const SizedBox(width: AppSpace.s2),
                      Expanded(
                        child: SmButton(
                          label: 'Share',
                          icon: Icons.ios_share,
                          kind: SmButtonKind.ghost,
                          onTap: _share,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (_pdfUrl != null) _completeBar(),
        ],
      ),
    );
  }

  Widget _previewCard(HarvestJob job, YieldData y) {
    final est = YieldData.estimate(y.gradeA, y.gradeB, y.tender);
    return SmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SmOverline('Report preview'),
              const Spacer(),
              SmChip(job.cropTypes.isEmpty ? 'Harvest' : _cap(job.cropTypes.first),
                  icon: Icons.eco),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              GradeDonut(
                gradeA: y.gradeA,
                gradeB: y.gradeB,
                tender: y.tender,
                size: 104,
                thickness: 17,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(y.totalKg.toStringAsFixed(1),
                        style: AppText.displayNum(22, color: AppColors.fg1)),
                    const SmOverline('kg'),
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
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22, color: AppColors.border),
          _line('Total yield', '${y.totalKg.toStringAsFixed(1)} kg · ${y.totalNuts} nuts'),
          _line('Estimated earnings', '₹${_inr(est)}'),
          _line('Byproducts', 'Husk · shell routed'),
          _line('Site Manager', ref.read(authStateProvider).value?.firstName ?? '—'),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
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

  Widget _signoffCard() {
    return SmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SmOverline('Homeowner sign-off'),
          const SizedBox(height: 10),
          Text('Confirm the homeowner has reviewed the on-site totals.',
              style: AppText.bodySm().copyWith(color: AppColors.fg2)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _signed = !_signed),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _signed ? AppColors.green600 : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.xs),
                    border: Border.all(
                        color: _signed
                            ? AppColors.green600
                            : AppColors.borderStrong,
                        width: 1.5),
                  ),
                  child: _signed
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Confirmed in person / via OTP',
                      style: AppText.bodySm().copyWith(
                          color: AppColors.fg1, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _readyCard() {
    return SmCard(
      color: AppColors.statusCompleteBg,
      border: Border.all(color: AppColors.green600.withValues(alpha: 0.4)),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, size: 26, color: AppColors.green600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report ready',
                    style: AppText.title()
                        .copyWith(fontSize: 16, color: AppColors.fg1)),
                Text('PDF generated with QR + digital record',
                    style: AppText.caption().copyWith(color: AppColors.fg2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _completeBar() {
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
            label: 'Mark job complete & pay out',
            icon: Icons.verified_outlined,
            kind: SmButtonKind.accent,
            large: true,
            loading: _completing,
            onTap: _markComplete,
          ),
        ),
      ),
    );
  }

  static String _homeowner(HarvestJob job) =>
      job.notes.isNotEmpty ? job.notes : (job.address ?? 'Homeowner');

  static String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

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
