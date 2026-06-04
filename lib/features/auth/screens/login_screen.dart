import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/providers/auth_provider.dart';
import 'otp_verify_screen.dart';

/// Phone-number entry. Triggers Firebase phone verification and, when the SMS
/// code is sent, navigates to the OTP screen with the verificationId.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  static const _countryCode = '+91'; // India / Kerala

  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
          context.push(
            AppRoutes.otp,
            extra: OtpArgs(
              verificationId: verificationId,
              phoneNumber: fullNumber,
              resendToken: resendToken,
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              const Icon(Icons.eco, color: AgriColors.green400, size: 44),
              const SizedBox(height: 20),
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AgriColors.green900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in with your mobile number to continue',
                style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  prefixText: '$_countryCode  ',
                  counterText: '',
                  hintText: '10-digit mobile number',
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
                onPressed: _sending ? null : _sendOtp,
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
