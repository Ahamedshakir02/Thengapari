import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import '../widgets/sm_widgets.dart';

class _Module {
  final String title;
  final String sub;
  final IconData icon;
  const _Module(this.title, this.sub, this.icon);
}

const _modules = <_Module>[
  _Module('Crop grading standards', 'Grade A / B / Tender criteria',
      Icons.workspace_premium_outlined),
  _Module('Accurate weighing', 'Scale setup, tare & recording',
      Icons.monitor_weight_outlined),
  _Module('Safety on site', 'Climber safety & first aid',
      Icons.health_and_safety_outlined),
  _Module('Handling worker disputes', 'De-escalation & fair pay',
      Icons.handshake_outlined),
  _Module('Byproduct routing', 'Husk, shell & waste value chains',
      Icons.recycling_outlined),
  _Module('Using the app', 'Checklist, ping & report flow',
      Icons.smartphone_outlined),
];

/// In-app training modules. Job dispatch stays blocked until all modules are
/// complete (`/site_managers/{uid}.trainingComplete`). Each module has a short
/// video + quiz; a certificate badge unlocks at 100%.
class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  final Set<int> _done = {0, 1};

  bool get _allDone => _done.length == _modules.length;

  @override
  Widget build(BuildContext context) {
    final pct = _done.length / _modules.length;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SmPaperHeader(
            title: 'Training',
            subtitle: '${_done.length}/${_modules.length} modules complete',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpace.s4),
              children: [
                _progressCard(pct),
                const SizedBox(height: AppSpace.s4),
                const SmOverline('Modules'),
                const SizedBox(height: AppSpace.s3),
                for (int i = 0; i < _modules.length; i++) ...[
                  _moduleCard(i),
                  const SizedBox(height: AppSpace.s3),
                ],
                if (_allDone) ...[
                  const SizedBox(height: AppSpace.s2),
                  _certificate(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard(double pct) {
    return SmCard(
      color: AppColors.brandInk,
      border: Border.all(color: AppColors.brandInk),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.accent),
                ),
                Text('${(pct * 100).round()}%',
                    style: AppText.displayNum(16, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_allDone ? 'Training complete' : 'Keep going',
                    style: AppText.title().copyWith(color: Colors.white)),
                const SizedBox(height: 3),
                Text(
                    _allDone
                        ? 'You\'re cleared to run harvest jobs.'
                        : 'Finish all modules to unlock job dispatch.',
                    style: AppText.bodySm()
                        .copyWith(color: AppColors.greenLeaf200)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moduleCard(int i) {
    final m = _modules[i];
    final done = _done.contains(i);
    return GestureDetector(
      onTap: () => setState(() => done ? _done.remove(i) : _done.add(i)),
      child: SmCard(
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: done ? AppColors.statusCompleteBg : AppColors.surfaceSunk,
                  borderRadius: BorderRadius.circular(AppRadii.md)),
              child: Icon(m.icon,
                  size: 22,
                  color: done ? AppColors.green600 : AppColors.greenSage500),
            ),
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.title,
                      style: AppText.title()
                          .copyWith(fontSize: 16, color: AppColors.fg1)),
                  Text(m.sub,
                      style:
                          AppText.caption().copyWith(color: AppColors.fg3)),
                ],
              ),
            ),
            if (done)
              const Icon(Icons.check_circle, color: AppColors.green600, size: 26)
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                    color: AppColors.greenLeaf100,
                    borderRadius: BorderRadius.circular(AppRadii.pill)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow,
                        size: 16, color: AppColors.greenForest800),
                    const SizedBox(width: 4),
                    Text('Start',
                        style: AppText.caption().copyWith(
                            color: AppColors.greenForest800,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _certificate() {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.greenLeaf100, AppColors.amber100],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.amber200),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
                color: AppColors.accent, shape: BoxShape.circle),
            child: const Icon(Icons.workspace_premium,
                size: 34, color: AppColors.greenForest900),
          ),
          const SizedBox(height: 12),
          Text('Certified Site Manager',
              style: AppText.h3().copyWith(color: AppColors.fg1)),
          const SizedBox(height: 4),
          Text('All modules complete. Your badge is now on your profile.',
              textAlign: TextAlign.center,
              style: AppText.bodySm().copyWith(color: AppColors.fg2)),
        ],
      ),
    );
  }
}
