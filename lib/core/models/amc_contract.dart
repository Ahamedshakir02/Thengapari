import 'package:cloud_firestore/cloud_firestore.dart';

/// AMC subscription tiers.
enum AmcPlan {
  basic,
  standard,
  premium;

  String get label => switch (this) {
        AmcPlan.basic => 'Basic',
        AmcPlan.standard => 'Standard',
        AmcPlan.premium => 'Premium',
      };

  int get annualFee => switch (this) {
        AmcPlan.basic => 1499,
        AmcPlan.standard => 2999,
        AmcPlan.premium => 4999,
      };

  String get coverage => switch (this) {
        AmcPlan.basic => 'Coconut · 2 auto-harvests / year',
        AmcPlan.standard => 'Coconut + Mango · seasonal auto-harvests',
        AmcPlan.premium => 'All crops · priority + monthly visits',
      };

  List<String> get crops => switch (this) {
        AmcPlan.basic => const ['coconut'],
        AmcPlan.standard => const ['coconut', 'mango'],
        AmcPlan.premium => const ['coconut', 'mango', 'jackfruit', 'pepper', 'areca'],
      };

  static AmcPlan? fromString(String? v) {
    for (final p in AmcPlan.values) {
      if (p.name == v) return p;
    }
    return null;
  }
}

/// `/amc_contracts/{uid}` — an active annual maintenance subscription.
class AmcContract {
  final AmcPlan plan;
  final List<String> crops;
  final DateTime startDate;
  final int annualFee;
  final bool autoRenew;
  final DateTime? nextDispatch;

  const AmcContract({
    required this.plan,
    required this.crops,
    required this.startDate,
    required this.annualFee,
    this.autoRenew = true,
    this.nextDispatch,
  });

  factory AmcContract.fromFirestore(Map<String, dynamic> data) {
    return AmcContract(
      plan: AmcPlan.fromString(data['plan'] as String?) ?? AmcPlan.basic,
      crops: (data['crops'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      annualFee: (data['annualFee'] as num?)?.toInt() ?? 0,
      autoRenew: data['autoRenew'] as bool? ?? true,
      nextDispatch: (data['nextDispatch'] as Timestamp?)?.toDate(),
    );
  }
}
