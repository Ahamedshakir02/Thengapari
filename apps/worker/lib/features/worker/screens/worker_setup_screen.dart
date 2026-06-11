import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:worker/router.dart';
import 'package:core/core/models/worker_profile.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/worker_providers.dart';

/// Worker palette (dark teal) — local to the worker feature.
class _W {
  static const bg = Color(0xFF08332F); // teal-900
  static const surface = Color(0xFF0E5249); // teal-700
  static const field = Color(0xFF0B4640);
  static const border = Color(0xFF15786B); // teal-500
  static const fg = Colors.white;
  static const fg2 = Color(0xFF9FE1CB);
  static const accent = AppColors.amber500;
}

const _districts = <String>[
  'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha', 'Kottayam',
  'Idukki', 'Ernakulam', 'Thrissur', 'Palakkad', 'Malappuram', 'Kozhikode',
  'Wayanad', 'Kannur', 'Kasaragod',
];

/// First-time worker setup — profile, skills, and UPI VPA in one flow. Writes
/// `/users/{uid}` (role: worker) + `/workers/{uid}`.
class WorkerSetupScreen extends ConsumerStatefulWidget {
  const WorkerSetupScreen({super.key});

  @override
  ConsumerState<WorkerSetupScreen> createState() => _WorkerSetupScreenState();
}

class _WorkerSetupScreenState extends ConsumerState<WorkerSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  String? _district;
  final Set<WorkerSkill> _skills = {};
  bool _saving = false;
  String? _nameErr, _districtErr, _skillErr, _upiErr;

  static final _upiRe = RegExp(r'^[\w.\-]{2,}@[a-zA-Z]{2,}$');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = ref.read(authStateProvider).value;
    setState(() {
      _nameErr = _nameCtrl.text.trim().isEmpty ? 'Enter your name' : null;
      _districtErr = _district == null ? 'Select a district' : null;
      _skillErr = _skills.isEmpty ? 'Pick at least one skill' : null;
      _upiErr = _upiRe.hasMatch(_upiCtrl.text.trim())
          ? null
          : 'Enter a valid UPI ID (name@bank)';
    });
    if (_nameErr != null ||
        _districtErr != null ||
        _skillErr != null ||
        _upiErr != null) {
      return;
    }
    if (user == null) {
      _snack('Not signed in.');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(workerServiceProvider).saveWorkerSetup(
            uid: user.uid,
            name: _nameCtrl.text,
            district: _district!,
            skills: _skills.toList(),
            upiVpa: _upiCtrl.text,
            phoneNumber: user.phoneNumber.isEmpty ? null : user.phoneNumber,
          );
      if (!mounted) return;
      context.go(AppRoutes.workerHome);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Could not save: $e');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _W.bg,
      appBar: AppBar(
        backgroundColor: _W.bg,
        foregroundColor: _W.fg,
        title: Text('Set up your work',
            style: AppText.h3().copyWith(color: _W.fg)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  Text("Let's get you earning",
                      style: AppText.h2().copyWith(color: _W.fg)),
                  const SizedBox(height: 4),
                  Text(
                      'Tell us your skills and where to send payouts. You can '
                      'change these anytime.',
                      style: AppText.bodySm().copyWith(color: _W.fg2)),
                  const SizedBox(height: 22),
                  _field('Full name', _nameCtrl,
                      hint: 'e.g. Suresh Kumar',
                      icon: Icons.person_outline,
                      error: _nameErr,
                      onChanged: () =>
                          setState(() => _nameErr = null)),
                  const SizedBox(height: 18),
                  _districtDropdown(),
                  const SizedBox(height: 22),
                  _label('Your skills'),
                  if (_skillErr != null) _errText(_skillErr!),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      for (final s in WorkerSkill.values)
                        _skillChip(s),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _field('Payout UPI ID', _upiCtrl,
                      hint: 'name@okaxis',
                      icon: Icons.account_balance_wallet_outlined,
                      error: _upiErr,
                      keyboard: TextInputType.emailAddress,
                      formatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s'))
                      ],
                      onChanged: () => setState(() => _upiErr = null)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _W.accent,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.greenForest900))
                      : Text('Save and start earning',
                          style: AppText.button()
                              .copyWith(color: AppColors.greenForest900)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) =>
      Text(t, style: AppText.caption().copyWith(color: _W.fg2, fontSize: 12.5));

  Widget _errText(String t) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(t,
            style: AppText.caption()
                .copyWith(color: const Color(0xFFF09595), fontSize: 11.5)),
      );

  Widget _field(String label, TextEditingController ctrl,
      {String? hint,
      IconData? icon,
      String? error,
      TextInputType? keyboard,
      List<TextInputFormatter>? formatters,
      VoidCallback? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          inputFormatters: formatters,
          onChanged: (_) => onChanged?.call(),
          style: const TextStyle(color: _W.fg, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF6FB6AB), fontSize: 15),
            filled: true,
            fillColor: _W.field,
            prefixIcon: icon == null
                ? null
                : Icon(icon, size: 18, color: _W.fg2),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: const BorderSide(color: _W.border, width: 0.6),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: const BorderSide(color: _W.accent, width: 1.4),
            ),
            errorText: error,
          ),
        ),
      ],
    );
  }

  Widget _districtDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('District'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _district,
          isExpanded: true,
          dropdownColor: _W.surface,
          icon: const Icon(Icons.expand_more, color: _W.fg2),
          hint: const Text('Select your district',
              style: TextStyle(color: Color(0xFF6FB6AB), fontSize: 15)),
          style: const TextStyle(color: _W.fg, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: _W.field,
            isDense: true,
            prefixIcon: const Icon(Icons.place_outlined, size: 18, color: _W.fg2),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: const BorderSide(color: _W.border, width: 0.6),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: const BorderSide(color: _W.accent, width: 1.4),
            ),
            errorText: _districtErr,
          ),
          items: [
            for (final d in _districts)
              DropdownMenuItem(value: d, child: Text(d)),
          ],
          onChanged: (v) => setState(() {
            _district = v;
            _districtErr = null;
          }),
        ),
      ],
    );
  }

  Widget _skillChip(WorkerSkill s) {
    final on = _skills.contains(s);
    return GestureDetector(
      onTap: () => setState(() {
        on ? _skills.remove(s) : _skills.add(s);
        _skillErr = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: on ? _W.accent : _W.field,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
              color: on ? _W.accent : _W.border, width: on ? 0 : 0.6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(s.icon,
                size: 16,
                color: on ? AppColors.greenForest900 : _W.fg2),
            const SizedBox(width: 7),
            Text(s.label,
                style: AppText.bodySm().copyWith(
                    fontWeight: FontWeight.w600,
                    color: on ? AppColors.greenForest900 : _W.fg)),
          ],
        ),
      ),
    );
  }
}
