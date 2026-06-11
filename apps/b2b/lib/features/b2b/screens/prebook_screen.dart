import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:b2b/router.dart';
import 'package:core/core/models/inventory_listing.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/b2b_providers.dart';
import '../widgets/b2b_widgets.dart';

typedef PreBookArgs = ({InventoryListing listing, int qty});

/// Confirm quantity, delivery date, and payment, then place the order via the
/// atomic `createB2BOrder` Cloud Function. Matches `screen3.jsx`.
class PreBookScreen extends ConsumerStatefulWidget {
  final PreBookArgs args;
  const PreBookScreen({super.key, required this.args});

  @override
  ConsumerState<PreBookScreen> createState() => _PreBookScreenState();
}

class _PreBookScreenState extends ConsumerState<PreBookScreen> {
  int _dateIdx = 0;
  String _pay = 'pay_on_delivery';
  bool _placing = false;
  bool _success = false;

  late final List<DateTime> _dates = List.generate(
      7, (i) => DateTime.now().add(Duration(days: i + 1)));

  InventoryListing get _l => widget.args.listing;
  int get _qty => widget.args.qty;
  double get _subtotal => _qty * _l.unitPrice;
  int get _saved => (_qty * _l.savingsPerUnit).round();

  Future<void> _confirm() async {
    final uid = ref.read(authStateProvider).value?.uid ?? '';
    setState(() => _placing = true);
    try {
      await ref.read(b2bServiceProvider).createB2BOrder(
            listingId: _l.id,
            quantity: _qty,
            deliveryDate: _dates[_dateIdx],
            paymentMethod: _pay,
            buyerId: uid,
          );
      // Pay-now would open Razorpay with the returned order here.
      if (!mounted) return;
      setState(() {
        _placing = false;
        _success = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not place order: $e')));
    }
  }

  void _finish(int tab) {
    ref.read(b2bTabProvider.notifier).state = tab;
    context.go(AppRoutes.b2bHome);
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _successView();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          B2bBackBar(title: 'Pre-book', onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _summaryCard(),
                ),
                const B2bSectionHead(title: 'Delivery date'),
                _datePicker(),
                const B2bSectionHead(title: 'Payment'),
                _payToggle(),
              ],
            ),
          ),
          _footer(),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return B2bCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CropGlyphBox(crop: _l.cropType, size: 56),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                          child: Text(_l.cropType.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppText.title().copyWith(color: AppColors.fg1)),
                        ),
                        const SizedBox(width: 7),
                        GradeTag(_l.grade),
                      ]),
                      const SizedBox(height: 2),
                      Text('${_l.farmName ?? "Farm"} · ${_l.ward}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppText.bodySm().copyWith(color: AppColors.fg3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _line('Quantity', '$_qty ${_l.unit}'),
          _line('Unit price (locked)', '₹${_l.unitPrice.toStringAsFixed(0)}/${_l.unit}'),
          _line('Wholesale equivalent', '₹${b2bInr(_qty * _l.wholesaleMarketPrice)}',
              muted: true, strike: true),
          _line('Delivery', 'Free', valueColor: AppColors.green600),
          const Divider(height: 1, color: AppColors.border),
          _line('Total', '₹${b2bInr(_subtotal)}', bold: true),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1F8A4D), Color(0xFF146C3A)],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.trending_up, size: 16, color: Color(0xFFB6F0C9)),
                  const SizedBox(width: 7),
                  Text("You're saving vs wholesale",
                      style: AppText.bodySm()
                          .copyWith(color: Colors.white.withValues(alpha: 0.85))),
                ]),
                Text('₹${b2bInr(_saved)}',
                    style: AppText.displayNum(20, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String k, String v,
      {bool muted = false, bool strike = false, bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k,
              style: bold
                  ? AppText.title().copyWith(color: AppColors.fg1)
                  : AppText.body().copyWith(color: AppColors.fg2)),
          Text(v,
              style: bold
                  ? AppText.displayNum(20, color: AppColors.fg1)
                  : AppText.body().copyWith(
                      color: valueColor ?? (muted ? AppColors.ink500 : AppColors.fg1),
                      fontWeight: muted ? FontWeight.w400 : FontWeight.w600,
                      decoration:
                          strike ? TextDecoration.lineThrough : null)),
        ],
      ),
    );
  }

  Widget _datePicker() {
    const dow = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    const mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (_, i) {
          final d = _dates[i];
          final active = i == _dateIdx;
          return GestureDetector(
            onTap: () => setState(() => _dateIdx = i),
            child: Container(
              width: 62,
              decoration: BoxDecoration(
                color: active ? AppColors.blue700 : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                    color: active ? AppColors.blue700 : AppColors.borderStrong,
                    width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dow[d.weekday % 7],
                      style: AppText.caption().copyWith(
                          color: active ? Colors.white : AppColors.fg3,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${d.day}',
                      style: AppText.displayNum(20,
                          color: active ? Colors.white : AppColors.fg1)),
                  const SizedBox(height: 2),
                  Text(i == 0 ? 'Tomorrow' : mon[d.month - 1],
                      style: AppText.caption().copyWith(
                          color: active
                              ? Colors.white
                              : AppColors.ink400,
                          fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _payToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _payOpt('pay_on_delivery', 'Pay on delivery',
              'Cash or UPI when produce arrives', 'No risk', AppColors.green600,
              AppColors.statusCompleteBg),
          const SizedBox(height: 10),
          _payOpt('pay_now', 'Pay now · UPI', 'Lock the lot instantly', '+1% off',
              AppColors.blue700, AppColors.blue100),
        ],
      ),
    );
  }

  Widget _payOpt(String id, String title, String sub, String tag, Color tagFg,
      Color tagBg) {
    final active = _pay == id;
    return GestureDetector(
      onTap: () => setState(() => _pay = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.blue100 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
              color: active ? AppColors.blue700 : AppColors.borderStrong,
              width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: active ? AppColors.blue700 : AppColors.borderStrong,
                    width: 2),
              ),
              child: active
                  ? Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                          color: AppColors.blue700, shape: BoxShape.circle))
                  : null,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.title().copyWith(color: AppColors.fg1)),
                  Text(sub, style: AppText.bodySm().copyWith(color: AppColors.fg3)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                  color: tagBg, borderRadius: BorderRadius.circular(AppRadii.xs)),
              child: Text(tag,
                  style: AppText.caption().copyWith(
                      color: tagFg, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: B2bButton(
            label: 'Confirm pre-book · ₹${b2bInr(_subtotal)}',
            trailingIcon: Icons.arrow_forward,
            loading: _placing,
            onTap: _confirm,
          ),
        ),
      ),
    );
  }

  Widget _successView() {
    final d = _dates[_dateIdx];
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: AppColors.statusCompleteBg, shape: BoxShape.circle),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                      color: AppColors.green600, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 34),
                ),
              ),
              const SizedBox(height: 22),
              Text('Pre-book confirmed',
                  textAlign: TextAlign.center,
                  style: AppText.h2().copyWith(color: AppColors.fg1)),
              const SizedBox(height: 8),
              Text(
                  '$_qty ${_l.unit} of ${_l.cropType.label} reserved from ${_l.farmName ?? "the farm"}. Arrives ${d.day}/${d.month}, 7–10 AM.',
                  textAlign: TextAlign.center,
                  style: AppText.body().copyWith(color: AppColors.fg2)),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1F8A4D), Color(0xFF146C3A)],
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Column(
                  children: [
                    Text('YOU SAVED ON THIS ORDER',
                        style: AppText.caption().copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 0.6)),
                    const SizedBox(height: 4),
                    Text('₹${b2bInr(_saved)}',
                        style: AppText.displayNum(30, color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 280,
                child: B2bButton(
                  label: 'View my savings dashboard',
                  onTap: () => _finish(2),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _finish(0),
                child: Text('Back to market',
                    style: AppText.button().copyWith(color: AppColors.fg3)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
