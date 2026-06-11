import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:homeowner/router.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/homeowner_providers.dart';
import 'package:core/core/widgets/app_button.dart';
import 'package:core/core/widgets/app_text_field.dart';

/// The 14 districts of Kerala.
const _keralaDistricts = <String>[
  'Thiruvananthapuram',
  'Kollam',
  'Pathanamthitta',
  'Alappuzha',
  'Kottayam',
  'Idukki',
  'Ernakulam',
  'Thrissur',
  'Palakkad',
  'Malappuram',
  'Kozhikode',
  'Wayanad',
  'Kannur',
  'Kasaragod',
];

/// First-time homeowner profile setup: name, district, property address.
/// Writes `/users/{uid}` (with `role: 'homeowner'`) and `/homeowners/{uid}`,
/// then continues to the tree inventory setup.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _district;
  bool _saving = false;
  String? _nameError;
  String? _districtError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = ref.read(authStateProvider).value;
    setState(() {
      _nameError = _nameCtrl.text.trim().isEmpty ? 'Please enter your name' : null;
      _districtError = _district == null ? 'Please select a district' : null;
    });
    if (_nameError != null || _districtError != null) return;
    if (user == null) {
      _snack('Not signed in — cannot save profile.');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(homeownerServiceProvider).saveProfile(
            uid: user.uid,
            name: _nameCtrl.text,
            district: _district!,
            address: _addressCtrl.text,
            phoneNumber: user.phoneNumber.isEmpty ? null : user.phoneNumber,
          );
      if (!mounted) return;
      context.go(AppRoutes.homeownerTreeSetup);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Could not save profile: $e');
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
      appBar: AppBar(title: const Text('Set up your profile')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  Text('Tell us about you', style: AppText.h2()),
                  const SizedBox(height: 4),
                  Text(
                    'We use this to match you with a nearby site manager '
                    'when you book a harvest.',
                    style: AppText.bodySm().copyWith(color: AppColors.fg3),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Full name',
                    hint: 'e.g. Meera Nair',
                    controller: _nameCtrl,
                    prefixIcon: Icons.person_outline,
                    errorText: _nameError,
                    onChanged: (_) {
                      if (_nameError != null) setState(() => _nameError = null);
                    },
                  ),
                  const SizedBox(height: 18),
                  _DistrictDropdown(
                    value: _district,
                    errorText: _districtError,
                    onChanged: (v) => setState(() {
                      _district = v;
                      _districtError = null;
                    }),
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Property address',
                    hint: 'House name, landmark, area',
                    controller: _addressCtrl,
                    prefixIcon: Icons.home_outlined,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: AppButton(
                label: 'Save and continue',
                loading: _saving,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kerala district picker styled to match [AppTextField].
class _DistrictDropdown extends StatelessWidget {
  final String? value;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  const _DistrictDropdown({
    required this.value,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('District',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.fg2)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: AppColors.brand),
          hint: const Text('Select your district',
              style: TextStyle(fontSize: 15, color: AppColors.ink400)),
          decoration: InputDecoration(
            errorText: errorText,
            isDense: true,
            prefixIcon: const Icon(Icons.place_outlined,
                size: 18, color: AppColors.brand),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          style: const TextStyle(fontSize: 15, color: AppColors.fg1),
          items: [
            for (final d in _keralaDistricts)
              DropdownMenuItem(value: d, child: Text(d)),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
