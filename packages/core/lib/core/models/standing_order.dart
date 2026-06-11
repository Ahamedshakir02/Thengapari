import 'package:cloud_firestore/cloud_firestore.dart';

import 'inventory_listing.dart';

/// Recurrence cadence for a standing order.
enum StandingFrequency {
  weekly,
  biweekly,
  monthly;

  String get label => switch (this) {
        StandingFrequency.weekly => 'Weekly',
        StandingFrequency.biweekly => 'Bi-weekly',
        StandingFrequency.monthly => 'Monthly',
      };

  String get firestoreValue => switch (this) {
        StandingFrequency.weekly => 'weekly',
        StandingFrequency.biweekly => 'biweekly',
        StandingFrequency.monthly => 'monthly',
      };

  /// Dispatches per month, for the spend estimate.
  double get perMonth => switch (this) {
        StandingFrequency.weekly => 4.3,
        StandingFrequency.biweekly => 2.15,
        StandingFrequency.monthly => 1,
      };

  static StandingFrequency fromString(String? v) {
    for (final f in StandingFrequency.values) {
      if (f.firestoreValue == v) return f;
    }
    return StandingFrequency.weekly;
  }
}

/// `/standing_orders/{orderId}` — a recurring auto-booked order.
class StandingOrder {
  final String id;
  final B2BCrop cropType;
  final String grade; // 'Grade A' | 'Grade A + B' | 'Any'
  final int quantityPerOrder;
  final StandingFrequency frequency;
  final double? maxPricePer;
  final DateTime? startDate;
  final DateTime? nextDue;
  final bool active;
  final DateTime? lastFulfilled;

  const StandingOrder({
    required this.id,
    required this.cropType,
    this.grade = 'Grade A',
    this.quantityPerOrder = 0,
    this.frequency = StandingFrequency.weekly,
    this.maxPricePer,
    this.startDate,
    this.nextDue,
    this.active = true,
    this.lastFulfilled,
  });

  String get unit => cropType.unit;

  factory StandingOrder.fromFirestore(String id, Map<String, dynamic> data) {
    return StandingOrder(
      id: id,
      cropType: B2BCrop.fromString(data['cropType'] as String?),
      grade: data['grade'] as String? ?? 'Grade A',
      quantityPerOrder: (data['quantityPerOrder'] as num?)?.toInt() ?? 0,
      frequency: StandingFrequency.fromString(data['frequency'] as String?),
      maxPricePer: (data['maxPricePer'] as num?)?.toDouble(),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      nextDue: (data['nextDue'] as Timestamp?)?.toDate(),
      active: data['active'] as bool? ?? true,
      lastFulfilled: (data['lastFulfilled'] as Timestamp?)?.toDate(),
    );
  }
}
