import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../theme/worker_theme.dart';

/// Worker "Wallet" tab — available balance, withdraw-to-UPI sheet flow, weekly
/// chart, linked UPI, and recent payouts. Matches
/// `Designs/ThengaPari Worker App/screen-wallet.jsx`. Data is demo/static.
class WorkerWalletTab extends StatelessWidget {
  const WorkerWalletTab({super.key});

  static const _balance = 2380;
  static const _upi = 'ravi@okaxis';
  static const _week = <double>[980, 1240, 760, 1500, 1100, 1240, 0];

  static const _txns = <_Txn>[
    _Txn('Coconut husking', 'Today · 9:54 AM', '380', '4072 1183', false),
    _Txn('Palm trimming', 'Yesterday · 5:12 PM', '300', '3981 7720', false),
    _Txn('Withdrawal to UPI', 'Yesterday · 8:00 PM', '1500', '2261 0049', true),
    _Txn('Tender coconut climb', 'Mon · 11:40 AM', '420', '1180 5532', false),
    _Txn('Coconut climbing', 'Sun · 10:20 AM', '460', '8841 2093', false),
  ];

  @override
  Widget build(BuildContext context) {
    final weekTotal = _week.fold<double>(0, (a, b) => a + b);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const WScreenHeader(
            title: 'Wallet',
            trailing: WHeaderIconBtn(icon: Icons.history),
          ),
          _balanceCard(context),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: WMiniStat(
                  icon: Icons.schedule,
                  label: 'Pending payout',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WRupee('0', size: 22),
                      const SizedBox(height: 6),
                      Text('Auto-paid after each job',
                          style: AppText.caption().copyWith(color: WColors.fg3)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WMiniStat(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'This week',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WRupee(inrGroup(weekTotal), size: 22),
                      const SizedBox(height: 6),
                      Text('▲ 12% vs last',
                          style: AppText.caption().copyWith(
                              color: WColors.good, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _card(
            child: Column(
              children: [
                WSectionHead(
                  title: 'This week',
                  dense: true,
                  trailing: Text('₹${(weekTotal / 1000).toStringAsFixed(1)}k',
                      style: AppText.displayNum(17, color: WColors.teal100)),
                ),
                const WWeeklyChart(week: _week, todayIndex: 5),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _linkedUpi(),
          const SizedBox(height: 22),
          const WSectionHead(title: 'Recent payouts'),
          _card(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (int i = 0; i < _txns.length; i++) ...[
                  if (i > 0) const Divider(color: WColors.line, height: 1),
                  _txnRow(_txns[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [WColors.glowTop, WColors.surface, WColors.surface2],
        ),
        border: Border.all(color: WColors.lineStrong),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 34,
              offset: const Offset(0, 14)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AVAILABLE BALANCE',
              style: AppText.caption().copyWith(
                  color: WColors.teal100, letterSpacing: 1.4, fontSize: 11)),
          const SizedBox(height: 8),
          WRupee(inrGroup(_balance), size: 48, weight: FontWeight.w800),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _openWithdraw(context),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [WColors.accent2, WColors.accent],
                ),
                boxShadow: [
                  BoxShadow(
                      color: WColors.accent.withValues(alpha: 0.4),
                      blurRadius: 22,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.south, size: 19, color: WColors.accentPress),
                  const SizedBox(width: 8),
                  Text('Withdraw to UPI',
                      style: AppText.button()
                          .copyWith(color: WColors.accentPress, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkedUpi() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: WColors.surface2, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.account_balance, size: 20, color: WColors.teal300),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Linked UPI',
                    style: AppText.caption().copyWith(color: WColors.fg3)),
                const SizedBox(height: 2),
                Text(_upi,
                    style: AppText.bodySm().copyWith(
                        color: WColors.fg1, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.verified, size: 20, color: WColors.good),
        ],
      ),
    );
  }

  Widget _txnRow(_Txn t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.out ? WColors.surface2 : const Color(0x245FC896),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(t.out ? Icons.north_east : Icons.eco,
                size: 19, color: t.out ? WColors.teal300 : WColors.good),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body().copyWith(
                        color: WColors.fg1, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text(t.time, style: AppText.caption().copyWith(color: WColors.fg3)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${t.out ? '−' : '+'}₹${t.amt}',
                  style: AppText.displayNum(16,
                      color: t.out ? WColors.fg2 : WColors.good)),
              const SizedBox(height: 5),
              Text('ref ${t.ref}',
                  style: AppText.caption()
                      .copyWith(color: WColors.fg3, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) => Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: WColors.line),
        ),
        child: child,
      );

  void _openWithdraw(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x9E031411),
      builder: (_) => const _WithdrawSheet(balance: _balance, upi: _upi),
    );
  }
}

class _Txn {
  final String title, time, amt, ref;
  final bool out;
  const _Txn(this.title, this.time, this.amt, this.ref, this.out);
}

// ─────────────────────────── Withdraw sheet ───────────────────────────

class _WithdrawSheet extends StatefulWidget {
  final int balance;
  final String upi;
  const _WithdrawSheet({required this.balance, required this.upi});

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  late int _amount = widget.balance;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          18, 14, 18, 22 + MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: WColors.bg2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        border: Border(
          top: BorderSide(color: WColors.line),
          left: BorderSide(color: WColors.line),
          right: BorderSide(color: WColors.line),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                color: WColors.lineStrong,
                borderRadius: BorderRadius.circular(999)),
          ),
          _done ? _doneStage() : _formStage(),
        ],
      ),
    );
  }

  Widget _formStage() {
    final quick = [500, 1000, widget.balance];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Withdraw to UPI', style: AppText.h3().copyWith(color: WColors.fg1)),
        const SizedBox(height: 4),
        Text('Instant · no fee',
            style: AppText.bodySm().copyWith(color: WColors.fg3)),
        const SizedBox(height: 18),
        Text('AMOUNT TO WITHDRAW',
            style: AppText.overline().copyWith(color: WColors.fg3, fontSize: 11)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: WColors.lineStrong, width: 2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹', style: AppText.displayNum(34, color: WColors.accent2)),
              const SizedBox(width: 6),
              Text(inrGroup(_amount),
                  style: AppText.displayNum(40,
                      color: WColors.fg1, weight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (int i = 0; i < quick.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _quickBtn(quick[i], i == 2)),
            ],
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: WColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: WColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: WColors.surface2,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.account_balance,
                    size: 19, color: WColors.teal300),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sent instantly to',
                        style:
                            AppText.caption().copyWith(color: WColors.fg3)),
                    const SizedBox(height: 2),
                    Text(widget.upi,
                        style: AppText.bodySm().copyWith(
                            color: WColors.fg1, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: WColors.fg3),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () => setState(() => _done = true),
          child: Container(
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [WColors.accent2, WColors.accent],
              ),
              boxShadow: [
                BoxShadow(
                    color: WColors.accent.withValues(alpha: 0.4),
                    blurRadius: 26,
                    offset: const Offset(0, 10)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.south, size: 20, color: WColors.accentPress),
                const SizedBox(width: 9),
                Text('Withdraw ₹${inrGroup(_amount)}',
                    style: AppText.button().copyWith(
                        color: WColors.accentPress, fontSize: 18)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickBtn(int q, bool isAll) {
    final on = q == _amount;
    return GestureDetector(
      onTap: () => setState(() => _amount = q),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? const Color(0x29F4A52A) : WColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
              color: on ? const Color(0x66F4A52A) : WColors.line),
        ),
        child: Text('${isAll ? 'All ' : ''}₹${inrGroup(q)}',
            style: AppText.caption().copyWith(
                color: on ? WColors.accent2 : WColors.fg2,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ),
    );
  }

  Widget _doneStage() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
                center: Alignment(0, -0.3), colors: [WColors.good, Color(0xFF2E8E5C)]),
            boxShadow: [
              BoxShadow(
                  color: WColors.good.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12)),
            ],
          ),
          child: const Icon(Icons.check, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text('Money on the way', style: AppText.h2().copyWith(color: WColors.fg1)),
        const SizedBox(height: 6),
        Text('₹${inrGroup(_amount)}',
            style: AppText.displayNum(30,
                color: WColors.good, weight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Reaching your bank in seconds · ${widget.upi}',
            textAlign: TextAlign.center,
            style: AppText.bodySm().copyWith(color: WColors.fg3)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            height: 56,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.pill)),
            child: Text('Done',
                style: AppText.button().copyWith(color: WColors.bg, fontSize: 17)),
          ),
        ),
      ],
    );
  }
}
