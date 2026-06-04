import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/providers/auth_provider.dart';

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

/// 6-digit OTP entry. On success, sign-in completes and the router's auth
/// redirect takes over navigation (to /select-role or a role home), so this
/// screen does not navigate on success itself.
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
  final _otpController = TextEditingController();
  bool _verifying = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).verifyOtp(
            verificationId: widget.verificationId,
            smsCode: code,
          );
      // No explicit navigation: authStateProvider updates and the router
      // redirect routes the now-signed-in user onward.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = e.message ?? 'Invalid code, please try again';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Verify your number',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AgriColors.green900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter the 6-digit code sent to ${widget.phoneNumber}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 22, letterSpacing: 8),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _verifying ? null : _verify,
                child: _verifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Verify & continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
