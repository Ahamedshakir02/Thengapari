import 'package:cloud_firestore/cloud_firestore.dart';

import 'inventory_listing.dart';

/// Lifecycle of a B2B order — drives the order progress stepper.
enum B2BOrderStatus {
  confirmed,
  dispatched,
  outForDelivery,
  delivered,
  cancelled;

  String get label => switch (this) {
        B2BOrderStatus.confirmed => 'Confirmed',
        B2BOrderStatus.dispatched => 'Dispatched',
        B2BOrderStatus.outForDelivery => 'Out for delivery',
        B2BOrderStatus.delivered => 'Delivered',
        B2BOrderStatus.cancelled => 'Cancelled',
      };

  String get firestoreValue => switch (this) {
        B2BOrderStatus.confirmed => 'confirmed',
        B2BOrderStatus.dispatched => 'dispatched',
        B2BOrderStatus.outForDelivery => 'out_for_delivery',
        B2BOrderStatus.delivered => 'delivered',
        B2BOrderStatus.cancelled => 'cancelled',
      };

  /// 0-based position in the Confirmed→Dispatched→Out→Delivered stepper.
  int get step => switch (this) {
        B2BOrderStatus.confirmed => 0,
        B2BOrderStatus.dispatched => 1,
        B2BOrderStatus.outForDelivery => 2,
        B2BOrderStatus.delivered => 3,
        B2BOrderStatus.cancelled => 0,
      };

  bool get isActive =>
      this != B2BOrderStatus.delivered && this != B2BOrderStatus.cancelled;

  static B2BOrderStatus fromString(String? v) {
    for (final s in B2BOrderStatus.values) {
      if (s.firestoreValue == v) return s;
    }
    return B2BOrderStatus.confirmed;
  }
}

/// `/b2b_orders/{orderId}`.
class B2BOrder {
  final String id;
  final String buyerId;
  final String listingId;
  final B2BCrop cropType;
  final String grade;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final double savingsAmount;
  final DateTime? deliveryDate;
  final String deliveryAddress;
  final String paymentMethod; // 'pay_now' | 'pay_on_delivery'
  final String paymentStatus; // 'pending' | 'paid'
  final B2BOrderStatus status;
  final String? invoiceUrl;
  final DateTime? createdAt;

  const B2BOrder({
    required this.id,
    this.buyerId = '',
    this.listingId = '',
    required this.cropType,
    this.grade = 'Grade A',
    this.quantity = 0,
    this.unitPrice = 0,
    this.totalAmount = 0,
    this.savingsAmount = 0,
    this.deliveryDate,
    this.deliveryAddress = '',
    this.paymentMethod = 'pay_on_delivery',
    this.paymentStatus = 'pending',
    this.status = B2BOrderStatus.confirmed,
    this.invoiceUrl,
    this.createdAt,
  });

  String get unit => cropType.unit;

  factory B2BOrder.fromFirestore(String id, Map<String, dynamic> data) {
    return B2BOrder(
      id: id,
      buyerId: data['buyerId'] as String? ?? '',
      listingId: data['listingId'] as String? ?? '',
      cropType: B2BCrop.fromString(data['cropType'] as String?),
      grade: data['grade'] as String? ?? 'Grade A',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      savingsAmount: (data['savingsAmount'] as num?)?.toDouble() ?? 0,
      deliveryDate: (data['deliveryDate'] as Timestamp?)?.toDate(),
      deliveryAddress: data['deliveryAddress'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String? ?? 'pay_on_delivery',
      paymentStatus: data['paymentStatus'] as String? ?? 'pending',
      status: B2BOrderStatus.fromString(data['status'] as String?),
      invoiceUrl: data['invoiceUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// `/b2b_orders/{orderId}/tracking/{eventId}`.
class TrackingEvent {
  final B2BOrderStatus type;
  final DateTime? timestamp;
  final String? note;
  final GeoPoint? location;

  const TrackingEvent({
    required this.type,
    this.timestamp,
    this.note,
    this.location,
  });

  factory TrackingEvent.fromFirestore(Map<String, dynamic> data) {
    return TrackingEvent(
      type: B2BOrderStatus.fromString(data['type'] as String?),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      note: data['note'] as String?,
      location: data['location'] as GeoPoint?,
    );
  }
}
