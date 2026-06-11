import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/design_tokens.dart';
import '../../../app/router.dart';
import '../../../core/models/b2b_order.dart';
import '../../../core/providers/b2b_providers.dart';
import '../widgets/b2b_widgets.dart';

/// Live delivery tracking: a route map, an ETA banner, the tracking timeline,
/// and the buyer's confirm-delivery action. Matches the spec in §5.
class OrderTrackingScreen extends ConsumerStatefulWidget {
  final B2BOrder order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  bool _confirming = false;

  Future<void> _confirm() async {
    setState(() => _confirming = true);
    try {
      await ref.read(b2bServiceProvider).confirmDelivery(widget.order.id);
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _confirming = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not confirm: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final events =
        ref.watch(orderTrackingProvider(o.id)).value ?? const <TrackingEvent>[];
    final delivered = o.status == B2BOrderStatus.delivered;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          B2bBackBar(title: 'Track order', onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _map(),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: _etaBanner(o),
                ),
                const B2bSectionHead(title: 'Delivery timeline'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: B2bCard(
                    padding: const EdgeInsets.all(16),
                    child: _timeline(o, events),
                  ),
                ),
              ],
            ),
          ),
          _footer(o, delivered),
        ],
      ),
    );
  }

  Widget _map() {
    return SizedBox(
      height: 200,
      child: CustomPaint(painter: _DeliveryMapPainter(), child: const SizedBox.expand()),
    );
  }

  Widget _etaBanner(B2BOrder o) {
    final delivered = o.status == B2BOrderStatus.delivered;
    return B2bCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.blue100,
                borderRadius: BorderRadius.circular(AppRadii.md)),
            child: Icon(delivered ? Icons.check : Icons.local_shipping,
                size: 22, color: AppColors.blue700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(delivered ? 'Delivered' : 'Arriving in ~18 mins',
                    style: AppText.title()
                        .copyWith(fontSize: 16, color: AppColors.fg1)),
                Text(o.deliveryAddress.isEmpty
                    ? '${o.cropType.label} · ${o.quantity} ${o.unit}'
                    : o.deliveryAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySm().copyWith(color: AppColors.fg3)),
              ],
            ),
          ),
          if (!delivered)
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration:
                  const BoxDecoration(color: AppColors.blue700, shape: BoxShape.circle),
              child: const Icon(Icons.call, size: 20, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _timeline(B2BOrder o, List<TrackingEvent> events) {
    // Fall back to a synthetic timeline derived from the order status if no
    // tracking subcollection events exist yet.
    final steps = events.isNotEmpty
        ? events.map((e) => (e.type, e.timestamp, true)).toList()
        : [
            for (final s in B2BOrderStatus.values.take(4))
              (s, null, s.step <= o.status.step),
          ];
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          _row(steps[i].$1, steps[i].$2, steps[i].$3, last: i == steps.length - 1),
      ],
    );
  }

  Widget _row(B2BOrderStatus type, DateTime? ts, bool done, {required bool last}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.blue700 : AppColors.surfaceSunk,
                  border: Border.all(
                      color: done ? AppColors.blue700 : AppColors.borderStrong,
                      width: 2),
                ),
                child: done
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
              if (!last)
                Expanded(
                  child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: done ? AppColors.blue300 : AppColors.border),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(type.label,
                        style: AppText.title().copyWith(
                            fontSize: 15,
                            color: done ? AppColors.fg1 : AppColors.fg3)),
                  ),
                  if (ts != null)
                    Text(
                        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}',
                        style:
                            AppText.caption().copyWith(color: AppColors.fg3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(B2BOrder o, bool delivered) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: delivered
              ? B2bButton(
                  label: 'View invoice',
                  icon: Icons.receipt_long_outlined,
                  ghost: true,
                  onTap: () => context.push(AppRoutes.b2bInvoice, extra: o),
                )
              : B2bButton(
                  label: 'Confirm delivery received',
                  icon: Icons.check_circle_outline,
                  loading: _confirming,
                  onTap: _confirm,
                ),
        ),
      ),
    );
  }
}

class _DeliveryMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue100, Color(0xFFCBD9E6)],
        ).createShader(rect),
    );
    final road = Paint()
      ..color = AppColors.paper50
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, 0.4 * h), Offset(w, 0.55 * h), road);
    canvas.drawLine(Offset(0.6 * w, 0), Offset(0.45 * w, h), road);

    final route = Path()
      ..moveTo(0.15 * w, 0.8 * h)
      ..cubicTo(0.35 * w, 0.7 * h, 0.4 * w, 0.5 * h, 0.6 * w, 0.42 * h)
      ..cubicTo(0.75 * w, 0.36 * h, 0.78 * w, 0.28 * h, 0.82 * w, 0.22 * h);
    canvas.drawPath(
        route,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = AppColors.blue700);

    // driver marker
    final driver = Offset(0.4 * w, 0.5 * h);
    canvas.drawCircle(driver, 11, Paint()..color = Colors.white);
    canvas.drawCircle(driver, 11,
        Paint()..style = PaintingStyle.stroke ..strokeWidth = 3 ..color = AppColors.blue700);
    canvas.drawCircle(driver, 5, Paint()..color = AppColors.blue700);
    // destination pin
    final pin = Offset(0.82 * w, 0.22 * h);
    canvas.drawCircle(pin.translate(0, -4), 12, Paint()..color = AppColors.accent);
    final tail = Path()
      ..moveTo(pin.dx - 7, pin.dy - 2)
      ..lineTo(pin.dx + 7, pin.dy - 2)
      ..lineTo(pin.dx, pin.dy + 9)
      ..close();
    canvas.drawPath(tail, Paint()..color = AppColors.accent);
    canvas.drawCircle(pin.translate(0, -5), 4, Paint()..color = AppColors.greenForest900);
  }

  @override
  bool shouldRepaint(_DeliveryMapPainter old) => false;
}
