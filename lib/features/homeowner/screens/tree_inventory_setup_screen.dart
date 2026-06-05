import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/models/tree_inventory.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/homeowner_providers.dart';
import '../../../core/services/homeowner_service.dart';
import '../../../core/widgets/app_button.dart';

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
                  const Text(
                    'What do you grow?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AgriColors.green900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add the trees on your property so we can suggest harvests '
                    'at the right time. You can change these later.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6E6B60)),
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
        color: active ? AgriColors.green50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? AgriColors.green100 : AgriColors.border,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AgriColors.border, width: 0.5),
                ),
                child: Text(type.emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF173404),
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
                    size: 15, color: AgriColors.green600),
                const SizedBox(width: 6),
                const Text('Avg age',
                    style: TextStyle(fontSize: 12, color: Color(0xFF3B6D11))),
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF173404),
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
          color: enabled ? AgriColors.green400 : const Color(0xFFE6E4DC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 16, color: enabled ? Colors.white : const Color(0xFFB4B2A9)),
      ),
    );
  }
}
