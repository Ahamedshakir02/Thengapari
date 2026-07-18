import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/design_tokens.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../widgets/auth_widgets.dart';

/// Arguments passed to [OtpVerifyScreen] via GoRouter's `extra`.
class OtpArgs {
  final String verificationId;
  final String phoneNumber;
  final int? resendToken;

  const OtpArgs({
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });
}

/// 6-digit OTP entry (design `screens-b.jsx` OTP screen): six code boxes with
/// active/filled/error states driven by one hidden text field, "Sent to …" +
/// Change, and a resend countdown. On success a brief "You're all set!"
/// overlay shows while the router's auth redirect takes over — this screen
/// never navigates forward itself.
class OtpVerifyScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final int? resendToken;

  const OtpVerifyScreen({
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
    super.key,
  });

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  static const _resendSeconds = 45;

  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  late String _verificationId = widget.verificationId;
  late int? _resendToken = widget.resendToken;
  int _resendLeft = _resendSeconds;
  Timer? _resendTimer;
  bool _verifying = false;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _otpController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendLeft = _resendSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_resendLeft <= 1) {
        _resendTimer?.cancel();
      }
      setState(() => _resendLeft = (_resendLeft - 1).clamp(0, _resendSeconds));
    });
  }

  void _onCodeChanged() {
    if (_error != null) setState(() => _error = null);
    setState(() {}); // repaint boxes
    if (_otpController.text.length == 6 && !_verifying) _verify();
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.length != 6) return;
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).verifyOtp(
            verificationId: _verificationId,
            smsCode: code,
          );
      if (!mounted) return;
      // Show the design's transient success state; the router's auth redirect
      // replaces this screen once authStateChanges emits.
      setState(() => _success = true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = e.message ?? 'Invalid code, please try again';
        _otpController.clear();
      });
    }
  }

  Future<void> _resend() async {
    setState(() {
      _error = null;
      _otpController.clear();
    });
    _startResendTimer();
    try {
      await ref.read(authServiceProvider).verifyPhoneNumber(
            phoneNumber: widget.phoneNumber,
            verificationFailed: (e) {
              if (!mounted) return;
              setState(() => _error = e.message ?? 'Could not resend the code');
            },
            codeSent: (verificationId, resendToken) {
              if (!mounted) return;
              setState(() {
                _verificationId = verificationId;
                _resendToken = resendToken ?? _resendToken;
              });
            },
          );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message ?? 'Could not resend the code');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthTopBar(onBack: () => Navigator.of(context).maybePop()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    children: [
                      Text(tr('otp_head', lang), style: AppText.h1()),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${tr('otp_sent_to', lang)} ${widget.phoneNumber}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.bodyLg(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Text(
                              tr('otp_edit', lang),
                              style: AppText.bodyLg().copyWith(
                                color: AppColors.brand,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _codeBoxes(),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: AppText.bodySm()
                              .copyWith(color: AppColors.statusErrorFg),
                        ),
                      ],
                      const SizedBox(height: 26),
                      _resendRow(lang),
                    ],
                  ),
                ),
              ],
            ),
            if (_success) _successOverlay(),
          ],
        ),
      ),
    );
  }

  /// Six code boxes fronting one hidden autofocused text field (system
  /// keyboard + paste both work).
  Widget _codeBoxes() {
    final code = _otpController.text;
    return Stack(
      children: [
        // Hidden input driving the boxes.
        Opacity(
          opacity: 0,
          child: SizedBox(
            height: 1,
            child: TextField(
              controller: _otpController,
              focusNode: _focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Row(
            children: [
              for (int i = 0; i < 6; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _box(i, code)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _box(int i, String code) {
    final filled = i < code.length;
    final active = i == code.length && !_verifying;
    final hasError = _error != null;

    final borderColor = hasError
        ? AppColors.statusErrorFg
        : active
            ? AppColors.brand
            : filled
                ? AppColors.greenSage400
                : AppColors.mist200;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? AppColors.greenLeaf50 : AppColors.paper0,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: borderColor, width: active ? 2 : 1.5),
      ),
      child: Text(
        filled ? code[i] : '',
        style: GoogleFonts.balooChettan2(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.brandInk,
        ),
      ),
    );
  }

  Widget _resendRow(AppLang lang) {
    if (_resendLeft > 0) {
      final mm = (_resendLeft ~/ 60).toString();
      final ss = (_resendLeft % 60).toString().padLeft(2, '0');
      return Text(
        '${tr('otp_resend_in', lang)} $mm:$ss',
        style: AppText.bodySm().copyWith(color: AppColors.fg3),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: _resend,
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Text(
          tr('otp_resend', lang),
          style: AppText.bodyLg().copyWith(
            color: AppColors.brand,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Design's transient success state (screens-b.jsx Signed-in node): green
  /// check badge in a leaf ring. The router redirect replaces the whole auth
  /// stack moments later.
  Widget _successOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppColors.bg,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.greenLeaf100,
              ),
              child: Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green600,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 36, color: Colors.white),
              ),
            ),
            const SizedBox(height: 18),
            Text("You're all set!", style: AppText.h2()),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                "Welcome to ThengaPari. Let's get your trees working for you.",
                textAlign: TextAlign.center,
                style: AppText.body(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
