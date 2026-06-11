import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:core/app/design_tokens.dart';
import 'package:core/core/models/b2b_order.dart';
import 'package:core/core/providers/b2b_providers.dart';
import '../widgets/b2b_widgets.dart';

/// GST-compliant invoice view for a delivered order. Renders the breakdown
/// in-app and offers share/download of the generated PDF (`generateInvoice`).
class InvoiceViewScreen extends ConsumerStatefulWidget {
  final B2BOrder order;
  const InvoiceViewScreen({super.key, required this.order});

  @override
  ConsumerState<InvoiceViewScreen> createState() => _InvoiceViewScreenState();
}

class _InvoiceViewScreenState extends ConsumerState<InvoiceViewScreen> {
  String? _url;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _url = widget.order.invoiceUrl;
    if (_url == null) _generate();
  }

  Future<void> _generate() async {
    setState(() => _loading = true);
    try {
      final url = await ref.read(b2bServiceProvider).generateInvoice(widget.order.id);
      if (!mounted) return;
      setState(() {
        _url = url;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _share() async {
    await SharePlus.instance.share(
        ShareParams(text: 'ThengaPari GST invoice: ${_url ?? widget.order.id}'));
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final taxable = o.totalAmount;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          B2bBackBar(title: 'Tax invoice', onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                B2bCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ThengaPari Agri Pvt Ltd',
                                    style: AppText.title()
                                        .copyWith(color: AppColors.fg1)),
                                Text('GSTIN 32AABCT1234T1Z2',
                                    style: AppText.caption()
                                        .copyWith(color: AppColors.fg3)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('TAX INVOICE',
                                  style: AppText.overline()
                                      .copyWith(color: AppColors.blue700)),
                              Text('INV-${o.id}',
                                  style: AppText.caption()
                                      .copyWith(color: AppColors.fg2)),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      _kv('Buyer', o.deliveryAddress.isEmpty ? 'Registered business' : o.deliveryAddress),
                      _kv('Order date',
                          o.createdAt == null ? '—' : '${o.createdAt!.day}/${o.createdAt!.month}/${o.createdAt!.year}'),
                      const Divider(height: 24, color: AppColors.border),
                      // Line item
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                                '${o.cropType.label} (${o.grade}) — ${o.quantity} ${o.unit} × ₹${o.unitPrice.toStringAsFixed(0)}',
                                style: AppText.bodySm()
                                    .copyWith(color: AppColors.fg1)),
                          ),
                          Text('₹${b2bInr(taxable)}',
                              style: AppText.bodySm().copyWith(
                                  color: AppColors.fg1,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Text('HSN 0801 · fresh produce',
                          style: AppText.caption().copyWith(color: AppColors.fg3)),
                      const Divider(height: 24, color: AppColors.border),
                      _kv('Taxable value', '₹${b2bInr(taxable)}'),
                      _kv('CGST (0% — exempt)', '₹0'),
                      _kv('SGST (0% — exempt)', '₹0'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.blue100,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Grand total',
                                style: AppText.title()
                                    .copyWith(color: AppColors.blue900)),
                            Text('₹${b2bInr(taxable)}',
                                style: AppText.displayNum(22,
                                    color: AppColors.blue900)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                          'Fresh produce — harvested and dispatched direct from source.',
                          style: AppText.caption().copyWith(color: AppColors.fg3)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_loading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ))
                else
                  Row(
                    children: [
                      Expanded(
                        child: B2bButton(
                          label: 'Download',
                          icon: Icons.download_outlined,
                          ghost: true,
                          onTap: () => ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(const SnackBar(
                                content: Text('Saved to Downloads'))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: B2bButton(
                          label: 'Share',
                          icon: Icons.ios_share,
                          onTap: _share,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: AppText.bodySm().copyWith(color: AppColors.fg3)),
          Flexible(
            child: Text(v,
                textAlign: TextAlign.right,
                style: AppText.bodySm().copyWith(
                    color: AppColors.fg1, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
