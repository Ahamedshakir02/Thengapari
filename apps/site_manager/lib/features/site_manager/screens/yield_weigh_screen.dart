import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:core/core/models/harvest_job.dart';
import 'package:core/core/models/job_step.dart';
import 'package:core/core/models/yield_data.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/site_manager_providers.dart';
import '../widgets/sm_widgets.dart';

/// Log harvest weight + per-grade counts. Writes `/jobs/{id}/yieldData/current`
/// and mirrors the summary onto the job for the Homeowner live weight card.
/// Matches `Designs/ThengaPari Site Manager App/screen3.jsx`.
class YieldWeighScreen extends ConsumerStatefulWidget {
  final HarvestJob job;
  const YieldWeighScreen({super.key, required this.job});

  @override
  ConsumerState<YieldWeighScreen> createState() => _YieldWeighScreenState();
}

class _YieldWeighScreenState extends ConsumerState<YieldWeighScreen> {
  String _weight = '0';
  int _a = 0, _b = 0, _t = 0;
  bool _scalePhoto = false;
  bool _saving = false;

  double get _weightNum => double.tryParse(_weight) ?? 0;
  int get _total => _a + _b + _t;

  @override
  void initState() {
    super.initState();
    // Pre-fill from any existing yield log.
    final existing = ref.read(yieldDataProvider(widget.job.id)).value;
    if (existing != null && existing.totalNuts > 0) {
      _weight = existing.totalKg.toStringAsFixed(1);
      _a = existing.gradeA;
      _b = existing.gradeB;
      _t = existing.tender;
      _scalePhoto = existing.scalePhotoUrl != null;
    }
  }

  void _press(String k) {
    setState(() {
      if (k == 'del') {
        _weight = _weight.length <= 1 ? '0' : _weight.substring(0, _weight.length - 1);
        return;
      }
      if (k == '.') {
        if (!_weight.contains('.')) _weight = '$_weight.';
        return;
      }
      var next = _weight == '0' ? k : '$_weight$k';
      if (next.contains('.') && next.split('.')[1].length > 1) return;
      if (next.replaceAll('.', '').length > 5) return;
      _weight = next;
    });
  }

  void _grabScale() => setState(() {
        _scalePhoto = true;
        _weight = '47.2';
      });

  Future<void> _save() async {
    final uid = ref.read(authStateProvider).value?.uid ?? '';
    setState(() => _saving = true);
    try {
      final svc = ref.read(siteManagerServiceProvider);
      await svc.saveYield(
        jobId: widget.job.id,
        uid: uid,
        totalKg: _weightNum,
        gradeA: _a,
        gradeB: _b,
        tender: _t,
        scalePhotoUrl: _scalePhoto ? 'pending-upload' : null,
      );
      await svc.completeStep(
        jobId: widget.job.id,
        uid: uid,
        kind: ManagerStepKind.yieldWeighed,
      );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not save yield: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final expected = job.estimatedYieldKg ?? 0;
    final underTarget = expected > 0 && _weightNum > 0 && _weightNum < expected * 0.9;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SmPaperHeader(
            title: 'Weigh & grade',
            subtitle: '${_homeowner(job)} · ${job.title}',
            trailing: const SmSpill('Step 3', kind: SmSpillKind.progress),
            onBack: () => context.pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpace.s4),
              children: [
                _weightDisplay(),
                const SizedBox(height: AppSpace.s3),
                _keypad(),
                if (underTarget) ...[
                  const SizedBox(height: AppSpace.s3),
                  _weightWarning(expected),
                ],
                const SizedBox(height: AppSpace.s3),
                _countsCard(),
              ],
            ),
          ),
          _saveBar(),
        ],
      ),
    );
  }

  Widget _weightDisplay() {
    return SmCard(
      color: AppColors.brandInk,
      border: Border.all(color: AppColors.brandInk),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SmOverline('Total weight', color: AppColors.greenSage400),
              GestureDetector(
                onTap: _grabScale,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _scalePhoto
                        ? AppColors.green600
                        : Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          _scalePhoto
                              ? Icons.check
                              : Icons.photo_camera_outlined,
                          size: 16,
                          color: Colors.white),
                      const SizedBox(width: 6),
                      Text(_scalePhoto ? 'Scale read' : 'Scale photo',
                          style: AppText.caption().copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Design: `700 52px var(--font-mono)`, letter-spacing -.02em.
                  Text(_weight,
                      style: AppText.mono(52, color: Colors.white)
                          .copyWith(letterSpacing: -1.04)),
                  const SizedBox(width: 8),
                  Text('kg',
                      style:
                          AppText.h3().copyWith(color: AppColors.greenSage400)),
                ],
              ),
              const Spacer(),
              // Blinking 2px amber input caret (screen3.jsx:95, blink 1.1s
              // steps(1)).
              SmBlink(
                period: const Duration(milliseconds: 1100),
                hard: true,
                child:
                    Container(width: 2, height: 38, color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keypad() {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'del'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpace.s2,
      crossAxisSpacing: AppSpace.s2,
      childAspectRatio: 2.0,
      children: [
        for (final k in keys)
          GestureDetector(
            onTap: () => _press(k),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                boxShadow: AppShadows.sm,
              ),
              // Design `.kp`: `600 24px var(--font-mono)`.
              child: k == 'del'
                  ? const Icon(Icons.backspace_outlined,
                      size: 22, color: AppColors.fg1)
                  : Text(k,
                      style: AppText.mono(24,
                          weight: FontWeight.w600, color: AppColors.fg1)),
            ),
          ),
      ],
    );
  }

  Widget _weightWarning(double expected) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s3),
      decoration: BoxDecoration(
        color: AppColors.amber100,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.amber200),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 20, color: AppColors.statusInprogressFg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                'Below the ${expected.toStringAsFixed(0)} kg estimate — double-check the scale before saving.',
                style: AppText.bodySm()
                    .copyWith(color: AppColors.statusInprogressFg)),
          ),
        ],
      ),
    );
  }

  Widget _countsCard() {
    return SmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SmOverline('Count by grade'),
          const SizedBox(height: 6),
          _counterRow(CropGrade.gradeA, _a, (d) => setState(() => _a = (_a + d).clamp(0, 9999))),
          const Divider(height: 16, color: AppColors.border),
          _counterRow(CropGrade.gradeB, _b, (d) => setState(() => _b = (_b + d).clamp(0, 9999))),
          const Divider(height: 16, color: AppColors.border),
          _counterRow(CropGrade.tender, _t, (d) => setState(() => _t = (_t + d).clamp(0, 9999))),
          const Divider(height: 20, color: AppColors.border),
          Row(
            children: [
              GradeDonut(
                gradeA: _a,
                gradeB: _b,
                tender: _t,
                size: 96,
                thickness: 16,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Design: `700 22px var(--font-mono)`, line-height 1.
                    Text('$_total',
                        style:
                            AppText.mono(22, color: AppColors.fg1, height: 1)),
                    const SmOverline('nuts'),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SmOverline('Estimated value'),
                    Text(
                        '₹${_inr(YieldData.estimate(_a, _b, _t))}',
                        style: AppText.h1()
                            .copyWith(fontSize: 30, color: AppColors.green600)),
                    Text(
                        '${_weightNum.toStringAsFixed(1)} kg · $_total nuts graded',
                        style:
                            AppText.caption().copyWith(color: AppColors.fg3)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterRow(CropGrade g, int value, ValueChanged<int> onDelta) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s2),
      child: Row(
        children: [
          Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                  color: g.color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.label,
                    style: AppText.title()
                        .copyWith(fontSize: 16, color: AppColors.fg1)),
                Text('₹${g.pricePerNut}/nut',
                    style: AppText.caption().copyWith(color: AppColors.fg3)),
              ],
            ),
          ),
          SmStepperCounter(value: value, onDelta: onDelta),
        ],
      ),
    );
  }

  Widget _saveBar() {
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
            label: 'Save yield & continue',
            trailingIcon: Icons.chevron_right,
            kind: SmButtonKind.brand,
            large: true,
            loading: _saving,
            onTap: _total == 0 && _weightNum == 0 ? null : _save,
          ),
        ),
      ),
    );
  }

  static String _homeowner(HarvestJob job) =>
      job.notes.isNotEmpty ? job.notes : (job.address ?? 'Homeowner');

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
