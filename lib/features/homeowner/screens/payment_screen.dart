import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../app/design_tokens.dart';
import '../../../core/models/harvest_job.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/homeowner_providers.dart';
import '../../../core/widgets/app_icon.dart';

/// Pay the service fee after a harvest. Itemised invoice, UPI options, and
/// Razorpay checkout (order created server-side via `createRazorpayOrder`).
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late final Razorpay _razorpay;
  bool _processing = false;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _onSuccess(PaymentSuccessResponse r) {
    if (!mounted) return;
    setState(() {
      _processing = false;
      _success = true;
    });
  }

  void _onError(PaymentFailureResponse r) {
    if (!mounted) return;
    setState(() => _processing = false);
    _snack('Payment failed: ${r.message ?? 'cancelled'}');
  }

  void _onWallet(ExternalWalletResponse r) {}

  Future<void> _pay(HarvestJob job, double amount) async {
    setState(() => _processing = true);
    try {
      final order = await ref.read(homeownerServiceProvider).createRazorpayOrder(
            jobId: job.id,
            amount: amount,
          );
      _razorpay.open({
        'key': order.keyId,
        'order_id': order.orderId,
        'amount': order.amountPaise,
        'name': 'ThengaPari',
        'description': 'Harvest service fee',
        'prefill': {
          'contact': ref.read(authStateProvider).value?.phoneNumber ?? '',
        },
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      _snack('Payments aren’t configured yet (createRazorpayOrder not '
          'deployed). $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final jobAsync = ref.watch(latestCompletedJobProvider(uid));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Payment')),
      body: jobAsync.when(
        data: (job) {
          if (job == null) {
            return const Center(child: Text('Nothing to pay right now.'));
          }
          final fee = job.feeAmount ?? 0;
          if (_success) return _SuccessView(amount: fee);
          return _Invoice(
            fee: fee,
            processing: _processing,
            onPay: () => _pay(job, fee),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load invoice.')),
      ),
    );
  }
}

class _Invoice extends StatelessWidget {
  final double fee;
  final bool processing;
  final VoidCallback onPay;

  const _Invoice(
      {required this.fee, required this.processing, required this.onPay});

  @override
  Widget build(BuildContext context) {
    final harvest = (fee * 0.6).roundToDouble();
    final manager = (fee * 0.25).roundToDouble();
    final platform = fee - harvest - manager;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter, 12, AppSpace.gutter, 12),
            children: [
              // Invoice card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice', style: AppText.title()),
                    const SizedBox(height: 4),
                    _row('Harvest service', harvest),
                    _row('Site manager fee', manager),
                    _row('Platform commission', platform, last: true),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunk,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text('Total payable',
                                  style: AppText.title().copyWith(fontSize: 16))),
                          Text('₹${fee.toStringAsFixed(0)}',
                              style: AppText.displayNum(22,
                                  color: AppColors.brandInk)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Pay using', style: AppText.caption()),
              const SizedBox(height: 8),
              Row(
                children: [
                  _upi('GPay', Icons.account_balance_wallet_outlined),
                  const SizedBox(width: 10),
                  _upi('PhonePe', Icons.account_balance_outlined),
                  const SizedBox(width: 10),
                  _upi('Paytm', Icons.payments_outlined),
                ],
              ),
              const SizedBox(height: 10),
              Text('UPI apps open via the Razorpay secure checkout.',
                  style: AppText.caption().copyWith(fontSize: 11.5)),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(AppSpace.gutter, 12, AppSpace.gutter,
              12 + MediaQuery.of(context).padding.bottom),
          child: GestureDetector(
            onTap: processing ? null : onPay,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.brand,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                boxShadow: AppShadows.md,
              ),
              child: processing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text('Pay ₹${fee.toStringAsFixed(0)}',
                      style: AppText.button().copyWith(color: AppColors.onBrand)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, double value, {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: AppText.bodySm().copyWith(color: AppColors.fg2))),
          Text('₹${value.toStringAsFixed(0)}',
              style: AppText.bodySm().copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fg1)),
        ],
      ),
    );
  }

  Widget _upi(String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.brand, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: AppText.caption().copyWith(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final double amount;
  const _SuccessView({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (_, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.statusCompleteBg,
                  shape: BoxShape.circle,
                ),
                child: AppIcon('check',
                    size: 44,
                    color: AppColors.statusCompleteFg,
                    strokeWidth: 2.6),
              ),
            ),
            const SizedBox(height: 18),
            Text('Payment successful', style: AppText.h2()),
            const SizedBox(height: 6),
            Text('₹${amount.toStringAsFixed(0)} paid — thank you!',
                style: AppText.body().copyWith(color: AppColors.fg2)),
          ],
        ),
      ),
    );
  }
}
