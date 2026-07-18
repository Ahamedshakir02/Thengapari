import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/design_tokens.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/app_user.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../widgets/auth_widgets.dart';
import 'otp_verify_screen.dart';

/// Phone-number entry (design `PhoneEntry` — `.tp-form` / `.tp-phone`).
/// Triggers Firebase phone verification and, when the SMS code is sent,
/// navigates to the OTP screen with the verificationId.
///
/// Design note: the custom in-screen NumPad from the mock is intentionally
/// skipped — the system number keyboard is used instead (a hidden TextField
/// drives the formatted digit display).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  static const _countryCode = '+91'; // India / Kerala

  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onChanged);
    _focusNode.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Debug-only: skip phone OTP and enter the app as a [role]. Sets the
  /// [devAuthOverrideProvider]; the router then redirects to that role's home.
  void _devLogin(UserRole role) {
    ref.read(devAuthOverrideProvider.notifier).set(AppUser(
      uid: 'dev-${role.asFirestoreValue}-uid',
      phoneNumber: '+910000000000',
      firstName: switch (role) {
        UserRole.homeowner => 'Meera',
        UserRole.worker => 'Ravi',
        UserRole.siteManager => 'Arjun',
        UserRole.b2b => 'Anil',
      },
      lastName: 'Nair',
      district: 'Thrissur',
      role: role,
    ));
  }

  Future<void> _sendOtp() async {
    final raw = _phoneController.text.trim();
    if (raw.length != 10) {
      setState(() => _error = 'Enter a valid 10-digit mobile number');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });

    final fullNumber = '$_countryCode$raw';
    try {
      await ref.read(authServiceProvider).verifyPhoneNumber(
        phoneNumber: fullNumber,
        verificationFailed: (e) {
          if (!mounted) return;
          setState(() {
            _sending = false;
            _error = e.message ?? 'Verification failed';
          });
        },
        codeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() => _sending = false);
          // Push the OTP screen directly so this shared auth screen doesn't
          // depend on any single app's route table.
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => OtpVerifyScreen(
              verificationId: verificationId,
              phoneNumber: fullNumber,
              resendToken: resendToken,
            ),
          ));
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = e.message ?? 'Could not start verification';
      });
    }
  }

  /// "98765 43210" — raw digits grouped 5 + 5.
  String get _formatted {
    final d = _phoneController.text;
    return d.length <= 5 ? d : '${d.substring(0, 5)} ${d.substring(5)}';
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final ml = lang == AppLang.ml;
    final ready = _phoneController.text.length == 10;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            AuthTopBar(onBack: () => context.go('/welcome')),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 8, 30, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      tr('phone_head', lang),
                      style: AppText.h1().copyWith(
                        color: AppColors.brandInk,
                        fontSize: ml ? 27 : 32,
                        height: ml ? 1.32 : 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(tr('phone_lead', lang), style: AppText.bodyLg()),
                    const SizedBox(height: 28),
                    Text(
                      tr('phone_label', lang).toUpperCase(),
                      style: AppText.overline(),
                    ),
                    const SizedBox(height: 8),
                    _phoneField(),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        style: AppText.bodySm()
                            .copyWith(color: AppColors.statusErrorFg),
                      ),
                    ],
                    const SizedBox(height: 18),
                    _reassureLine(lang),
                    if (kDebugMode) _devBypass(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 16, 30, 18),
              child: AuthCtaButton(
                label: tr('auth_send_otp', lang),
                loading: _sending,
                onPressed: ready && !_sending ? _sendOtp : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The `.tp-phone` input: flag + "+91" chip, formatted digit display, and a
  /// hidden TextField that brings up the system number keyboard.
  Widget _phoneField() {
    final focused = _focusNode.hasFocus;
    final hasDigits = _phoneController.text.isNotEmpty;
    return Stack(
      children: [
        // Hidden field: owns the text + keyboard. Kept 1x1 and invisible.
        SizedBox(
          width: 1,
          height: 1,
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _phoneController,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: ''),
              showCursor: false,
              autocorrect: false,
              enableSuggestions: false,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: focused ? AppColors.brand : AppColors.borderStrong,
                width: 1.5,
              ),
              boxShadow: focused
                  ? const [
                      BoxShadow(color: AppColors.greenLeaf100, spreadRadius: 4),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // +91 country-code chip
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 14, 0),
                  decoration: const BoxDecoration(
                    border: Border(
                      right:
                          BorderSide(color: AppColors.border, width: 1.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _IndiaFlag(),
                      const SizedBox(width: 7),
                      Text(_countryCode, style: AppText.title()),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      hasDigits ? _formatted : '00000 00000',
                      maxLines: 1,
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        height: 1,
                        fontWeight:
                            hasDigits ? FontWeight.w600 : FontWeight.w500,
                        letterSpacing: hasDigits ? 1.32 : 0.88,
                        color:
                            hasDigits ? AppColors.fg1 : AppColors.ink400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Shield + "we'll send a one-time code" reassurance (`.tp-reassure`).
  Widget _reassureLine(AppLang lang) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.verified_user_outlined,
            size: 16,
            color: AppColors.greenSage500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(tr('auth_reassure', lang),
              style: AppText.bodySm().copyWith(color: AppColors.fg3)),
        ),
      ],
    );
  }

  /// Debug-only login bypass shown while phone auth is disabled in dev.
  Widget _devBypass() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Row(
          children: const [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('DEV BYPASS',
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w700)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final role in UserRole.values)
              OutlinedButton(
                onPressed: () => _devLogin(role),
                child: Text(_roleLabel(role)),
              ),
          ],
        ),
      ],
    );
  }

  String _roleLabel(UserRole role) => switch (role) {
        UserRole.homeowner => 'Homeowner',
        UserRole.worker => 'Worker',
        UserRole.siteManager => 'Site Manager',
        UserRole.b2b => 'B2B',
      };
}

/// Tiny India flag chip (`.tp-phone__flag`): saffron / white / green bands
/// with a navy Ashoka-chakra dot, 24x17, radius 3.
class _IndiaFlag extends StatelessWidget {
  const _IndiaFlag();

  static const _saffron = Color(0xFFFF9933);
  static const _green = Color(0xFF138808);
  static const _navy = Color(0xFF0A2A6B);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        width: 24,
        height: 17,
        child: Stack(
          children: [
            Column(
              children: const [
                Expanded(child: ColoredBox(color: _saffron, child: SizedBox.expand())),
                Expanded(child: ColoredBox(color: Colors.white, child: SizedBox.expand())),
                Expanded(child: ColoredBox(color: _green, child: SizedBox.expand())),
              ],
            ),
            Center(
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _navy, width: 0.8),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 1.2,
                    height: 1.2,
                    child: DecoratedBox(
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: _navy),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
