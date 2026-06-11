import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:homeowner/router.dart';
import 'package:core/core/models/tree_inventory.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/homeowner_providers.dart';
import 'package:core/core/services/homeowner_service.dart';
import 'package:core/core/widgets/app_button.dart';
import 'package:core/core/widgets/app_icon.dart';

/// First-time tree inventory: the homeowner logs how many of each tree type
/// they own. Batch-writes `/homeowners/{uid}/trees`, then enters the app.
class TreeInventorySetupScreen extends ConsumerStatefulWidget {
  const TreeInventorySetupScreen({super.key});

  @override
  ConsumerState<TreeInventorySetupScreen> createState() =>
      _TreeInventorySetupScreenState();
}

class _TreeInventorySetupScreenState
    extends ConsumerState<TreeInventorySetupScreen> {
  final Map<CropType, int> _counts = {for (final t in CropType.values) t: 0};
  final Map<CropType, int> _ages = {for (final t in CropType.values) t: 5};
  bool _saving = false;

  int get _totalTrees => _counts.values.fold(0, (a, b) => a + b);

  Future<void> _finish() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      _snack('Not signed in — cannot save trees.');
      return;
    }
    setState(() => _saving = true);
    try {
      final drafts = <TreeDraft>[
        for (final entry in _counts.entries)
          if (entry.value > 0)
            TreeDraft(
              type: entry.key,
              count: entry.value,
              avgAgeYears: _ages[entry.key] ?? 0,
            ),
      ];
      if (drafts.isNotEmpty) {
        await ref.read(homeownerServiceProvider).saveTrees(
              uid: user.uid,
              trees: drafts,
            );
      }
      if (!mounted) return;
      context.go(AppRoutes.homeownerHome);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Could not save trees: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Your trees'),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => context.go(AppRoutes.homeownerHome),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  Text('What do you grow?', style: AppText.h2()),
                  const SizedBox(height: 4),
                  Text(
                    'Add the trees on your property so we can suggest harvests '
                    'at the right time. You can change these later.',
                    style: AppText.bodySm().copyWith(color: AppColors.fg3),
                  ),
                  const SizedBox(height: 20),
                  for (final type in CropType.values) ...[
                    _CropCountCard(
                      type: type,
                      count: _counts[type]!,
                      ageYears: _ages[type]!,
                      onCountChanged: (v) => setState(() => _counts[type] = v),
                      onAgeChanged: (v) => setState(() => _ages[type] = v),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: AppButton(
                label: _totalTrees == 0
                    ? 'Finish setup'
                    : 'Finish setup · $_totalTrees trees',
                loading: _saving,
                onPressed: _finish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One crop row with a count stepper, and (once count > 0) an average-age
/// stepper.
class _CropCountCard extends StatelessWidget {
  final CropType type;
  final int count;
  final int ageYears;
  final ValueChanged<int> onCountChanged;
  final ValueChanged<int> onAgeChanged;

  const _CropCountCard({
    required this.type,
    required this.count,
    required this.ageYears,
    required this.onCountChanged,
    required this.onAgeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? AppColors.surfaceSunk : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: active ? AppColors.brand : AppColors.border,
          width: active ? 1 : 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CropPalette.tint(type),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: CropGlyph(type, size: 24, color: CropPalette.fg(type)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fg1,
                  ),
                ),
              ),
              _Stepper(
                value: count,
                min: 0,
                onChanged: onCountChanged,
              ),
            ],
          ),
          if (active) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.eco_outlined,
                    size: 15, color: AppColors.brand),
                const SizedBox(width: 6),
                const Text('Avg age',
                    style: TextStyle(fontSize: 12, color: AppColors.fg2)),
                const Spacer(),
                _Stepper(
                  value: ageYears,
                  min: 1,
                  suffix: 'yr',
                  onChanged: onAgeChanged,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact +/- counter.
class _Stepper extends StatelessWidget {
  final int value;
  final int min;
  final String? suffix;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.value,
    required this.min,
    required this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon: Icons.remove,
          onTap: value > min ? () => onChanged(value - 1) : null,
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 44),
          alignment: Alignment.center,
          child: Text(
            suffix == null ? '$value' : '$value $suffix',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.fg1,
            ),
          ),
        ),
        _StepBtn(icon: Icons.add, onTap: () => onChanged(value + 1)),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.brand : AppColors.mist200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 16, color: enabled ? Colors.white : AppColors.ink400),
      ),
    );
  }
}
