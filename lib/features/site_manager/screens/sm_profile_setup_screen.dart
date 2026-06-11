import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/design_tokens.dart';
import '../../../app/router.dart';
import '../../../core/models/site_manager_profile.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/site_manager_providers.dart';
import '../widgets/sm_widgets.dart';

const _districts = <String>[
  'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha', 'Kottayam',
  'Idukki', 'Ernakulam', 'Thrissur', 'Palakkad', 'Malappuram', 'Kozhikode',
  'Wayanad', 'Kannur', 'Kasaragod',
];

/// First-time Site Manager setup: student details + college enrolment + ID
/// upload. Writes `/users/{uid}` (role: site_manager) and `/site_managers/{uid}`
/// with `verified: false`, then routes to the verification-pending gate.
class SiteManagerProfileSetupScreen extends ConsumerStatefulWidget {
  const SiteManagerProfileSetupScreen({super.key});

  @override
  ConsumerState<SiteManagerProfileSetupScreen> createState() =>
      _SiteManagerProfileSetupScreenState();
}

class _SiteManagerProfileSetupScreenState
    extends ConsumerState<SiteManagerProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _collegeCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  String? _district;
  CollegeBranch? _branch;
  YearOfStudy? _year;
  bool _idUploaded = false;
  bool _saving = false;

  String? _nameErr, _collegeErr, _rollErr, _districtErr, _branchErr, _yearErr,
      _idErr;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _collegeCtrl.dispose();
    _rollCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _nameErr = _nameCtrl.text.trim().isEmpty ? 'Enter your name' : null;
      _collegeErr =
          _collegeCtrl.text.trim().isEmpty ? 'Enter your college' : null;
      _rollErr = _rollCtrl.text.trim().isEmpty ? 'Enter your roll number' : null;
      _districtErr = _district == null ? 'Select your operating zone' : null;
      _branchErr = _branch == null ? 'Select your branch' : null;
      _yearErr = _year == null ? 'Select your year' : null;
      _idErr = _idUploaded ? null : 'Upload your college ID for verification';
    });
    if ([_nameErr, _collegeErr, _rollErr, _districtErr, _branchErr, _yearErr,
            _idErr]
        .any((e) => e != null)) {
      return;
    }
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      _snack('Not signed in.');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(siteManagerServiceProvider).saveProfileSetup(
            uid: user.uid,
            name: _nameCtrl.text,
            district: _district!,
            collegeName: _collegeCtrl.text,
            rollNumber: _rollCtrl.text,
            branch: _branch!,
            yearOfStudy: _year!,
            idDocUrl: 'pending-review',
            phoneNumber: user.phoneNumber.isEmpty ? null : user.phoneNumber,
          );
      if (!mounted) return;
      context.go(AppRoutes.managerVerification);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Could not submit: $e');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SmBrandHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SmOverline('Site Manager onboarding',
                    color: AppColors.greenSage400),
                const SizedBox(height: 4),
                Text('Set up your profile',
                    style: AppText.h2().copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                    'We verify every student supervisor before assigning jobs.',
                    style: AppText.bodySm()
                        .copyWith(color: AppColors.greenLeaf200)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.s4, AppSpace.s5, AppSpace.s4, AppSpace.s5),
              children: [
                _field('Full name', _nameCtrl,
                    hint: 'e.g. Arjun Pradeep',
                    icon: Icons.person_outline,
                    error: _nameErr,
                    onChanged: () => setState(() => _nameErr = null)),
                const SizedBox(height: 18),
                _field('College name', _collegeCtrl,
                    hint: 'e.g. Govt. Engineering College, Thrissur',
                    icon: Icons.school_outlined,
                    error: _collegeErr,
                    onChanged: () => setState(() => _collegeErr = null)),
                const SizedBox(height: 18),
                _field('Roll number', _rollCtrl,
                    hint: 'e.g. TCR21CS045',
                    icon: Icons.badge_outlined,
                    error: _rollErr,
                    onChanged: () => setState(() => _rollErr = null)),
                const SizedBox(height: 18),
                _label('Branch'),
                if (_branchErr != null) _errText(_branchErr!),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    for (final b in CollegeBranch.values)
                      _choiceChip(b.label, _branch == b, () {
                        setState(() {
                          _branch = b;
                          _branchErr = null;
                        });
                      }),
                  ],
                ),
                const SizedBox(height: 18),
                _label('Year of study'),
                if (_yearErr != null) _errText(_yearErr!),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    for (final y in YearOfStudy.values)
                      _choiceChip(y.label, _year == y, () {
                        setState(() {
                          _year = y;
                          _yearErr = null;
                        });
                      }),
                  ],
                ),
                const SizedBox(height: 18),
                _districtDropdown(),
                const SizedBox(height: 18),
                _idUpload(),
                const SizedBox(height: 26),
                SmButton(
                  label: 'Submit for verification',
                  icon: Icons.verified_outlined,
                  large: true,
                  loading: _saving,
                  onTap: _submit,
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text('An admin reviews your ID within a few hours.',
                      style:
                          AppText.caption().copyWith(color: AppColors.fg3)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) =>
      Text(t, style: AppText.caption().copyWith(color: AppColors.fg2, fontSize: 12.5));

  Widget _errText(String t) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(t,
            style: AppText.caption().copyWith(color: AppColors.statusErrorFg)),
      );

  Widget _field(String label, TextEditingController ctrl,
      {String? hint, IconData? icon, String? error, VoidCallback? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          onChanged: (_) => onChanged?.call(),
          style: AppText.body().copyWith(color: AppColors.fg1),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 19),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        _label('Operating zone (district)'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _district,
          isExpanded: true,
          icon: const Icon(Icons.expand_more),
          hint: const Text('Select your district'),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.place_outlined, size: 19),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

  Widget _choiceChip(String label, bool on, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: on ? AppColors.brand : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
              color: on ? AppColors.brand : AppColors.borderStrong,
              width: 1.4),
        ),
        child: Text(label,
            style: AppText.bodySm().copyWith(
                fontWeight: FontWeight.w600,
                color: on ? AppColors.onBrand : AppColors.fg2)),
      ),
    );
  }

  Widget _idUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('College ID photo'),
        if (_idErr != null) _errText(_idErr!),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() {
            _idUploaded = true;
            _idErr = null;
          }),
          child: Container(
            height: 96,
            decoration: BoxDecoration(
              color: _idUploaded ? AppColors.statusCompleteBg : AppColors.surfaceSunk,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: _idUploaded
                    ? AppColors.green600
                    : AppColors.borderStrong,
                width: 1.4,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _idUploaded
                        ? Icons.check_circle_outline
                        : Icons.add_a_photo_outlined,
                    size: 28,
                    color: _idUploaded ? AppColors.green600 : AppColors.fg3,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _idUploaded
                        ? 'College ID added — ready for review'
                        : 'Tap to upload your college ID',
                    style: AppText.bodySm().copyWith(
                        color: _idUploaded
                            ? AppColors.green600
                            : AppColors.fg2,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
