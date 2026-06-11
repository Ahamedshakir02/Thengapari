import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:b2b/router.dart';
import 'package:core/core/models/b2b_buyer_profile.dart';
import 'package:core/core/models/inventory_listing.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/b2b_providers.dart';
import '../widgets/b2b_widgets.dart';

const _districts = <String>[
  'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha', 'Kottayam',
  'Idukki', 'Ernakulam', 'Thrissur', 'Palakkad', 'Malappuram', 'Kozhikode',
  'Wayanad', 'Kannur', 'Kasaragod',
];

/// Onboard a business buyer: business details + 15-char GST + crop preferences.
/// Writes `/users/{uid}` (role b2b) + `/b2b_buyers/{uid}` (verified: false),
/// then routes to the GST verification-pending gate.
class BusinessProfileSetupScreen extends ConsumerStatefulWidget {
  const BusinessProfileSetupScreen({super.key});

  @override
  ConsumerState<BusinessProfileSetupScreen> createState() =>
      _BusinessProfileSetupScreenState();
}

class _BusinessProfileSetupScreenState
    extends ConsumerState<BusinessProfileSetupScreen> {
  final _bizCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _district;
  BusinessType? _type;
  final Set<B2BCrop> _crops = {};
  bool _saving = false;

  String? _bizErr, _ownerErr, _gstErr, _typeErr, _districtErr, _cropErr;

  @override
  void dispose() {
    _bizCtrl.dispose();
    _ownerCtrl.dispose();
    _gstCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _bizErr = _bizCtrl.text.trim().isEmpty ? 'Enter your business name' : null;
      _ownerErr = _ownerCtrl.text.trim().isEmpty ? 'Enter the owner name' : null;
      _typeErr = _type == null ? 'Select a business type' : null;
      _gstErr = B2BBuyerProfile.isValidGst(_gstCtrl.text)
          ? null
          : 'Enter a valid 15-character GSTIN';
      _districtErr = _district == null ? 'Select your district' : null;
      _cropErr = _crops.isEmpty ? 'Pick at least one crop' : null;
    });
    if ([_bizErr, _ownerErr, _typeErr, _gstErr, _districtErr, _cropErr]
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
      await ref.read(b2bServiceProvider).saveBusinessProfile(
            uid: user.uid,
            ownerName: _ownerCtrl.text,
            businessName: _bizCtrl.text,
            businessType: _type!,
            gstNumber: _gstCtrl.text,
            address: _addressCtrl.text,
            district: _district!,
            cropPreferences: _crops.toList(),
            phoneNumber: user.phoneNumber.isEmpty ? null : user.phoneNumber,
          );
      if (!mounted) return;
      context.go(AppRoutes.b2bVerification);
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
          const B2bAppBar(
            eyebrow: 'B2B buyer onboarding',
            title: 'Set up your business',
            sub: 'We verify your GST before you can place orders.',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
              children: [
                _field('Business name', _bizCtrl,
                    hint: 'e.g. Saravana Juice Stall',
                    icon: Icons.store_outlined,
                    error: _bizErr,
                    onChanged: () => setState(() => _bizErr = null)),
                const SizedBox(height: 18),
                _field('Owner name', _ownerCtrl,
                    hint: 'e.g. Saravanan R',
                    icon: Icons.person_outline,
                    error: _ownerErr,
                    onChanged: () => setState(() => _ownerErr = null)),
                const SizedBox(height: 18),
                _label('Business type'),
                if (_typeErr != null) _err(_typeErr!),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    for (final t in BusinessType.values)
                      _choice(t.label, _type == t,
                          () => setState(() {
                                _type = t;
                                _typeErr = null;
                              })),
                  ],
                ),
                const SizedBox(height: 18),
                _field('GSTIN', _gstCtrl,
                    hint: '32AABCR1234F1Z5',
                    icon: Icons.verified_outlined,
                    error: _gstErr,
                    caps: true,
                    maxLen: 15,
                    onChanged: () => setState(() => _gstErr = null)),
                const SizedBox(height: 18),
                _districtDropdown(),
                const SizedBox(height: 18),
                _field('Delivery address', _addressCtrl,
                    hint: 'Shop / unit address',
                    icon: Icons.location_on_outlined,
                    maxLines: 2),
                const SizedBox(height: 18),
                _label('Crops you buy'),
                if (_cropErr != null) _err(_cropErr!),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    for (final c in B2BCrop.values)
                      _cropChoice(c),
                  ],
                ),
                const SizedBox(height: 26),
                B2bButton(
                  label: 'Submit for verification',
                  icon: Icons.verified_outlined,
                  loading: _saving,
                  onTap: _submit,
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text('GST is checked against the government database.',
                      style: AppText.caption().copyWith(color: AppColors.fg3)),
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

  Widget _err(String t) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(t,
            style: AppText.caption().copyWith(color: AppColors.statusErrorFg)),
      );

  Widget _field(String label, TextEditingController ctrl,
      {String? hint,
      IconData? icon,
      String? error,
      bool caps = false,
      int? maxLen,
      int maxLines = 1,
      VoidCallback? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          maxLength: maxLen,
          textCapitalization:
              caps ? TextCapitalization.characters : TextCapitalization.none,
          inputFormatters:
              caps ? [UpperCaseFormatter()] : null,
          onChanged: (_) => onChanged?.call(),
          style: AppText.body().copyWith(color: AppColors.fg1),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 19),
            isDense: true,
            counterText: '',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            errorText: error,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: const BorderSide(color: AppColors.blue500, width: 1.5),
            ),
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

  Widget _choice(String label, bool on, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: on ? AppColors.blue700 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
              color: on ? AppColors.blue700 : AppColors.borderStrong, width: 1.4),
        ),
        child: Text(label,
            style: AppText.bodySm().copyWith(
                fontWeight: FontWeight.w600,
                color: on ? Colors.white : AppColors.fg2)),
      ),
    );
  }

  Widget _cropChoice(B2BCrop c) {
    final on = _crops.contains(c);
    return GestureDetector(
      onTap: () => setState(() {
        on ? _crops.remove(c) : _crops.add(c);
        _cropErr = null;
      }),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
        decoration: BoxDecoration(
          color: on ? AppColors.blue100 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
              color: on ? AppColors.blue700 : AppColors.borderStrong, width: 1.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CropGlyphBox(crop: c, size: 26, radius: 999, glyphSize: 18),
            const SizedBox(width: 8),
            Text(c.label,
                style: AppText.bodySm().copyWith(
                    fontWeight: FontWeight.w600,
                    color: on ? AppColors.blue900 : AppColors.fg2)),
          ],
        ),
      ),
    );
  }
}

/// Forces input to upper-case (GSTIN is stored upper-case).
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
