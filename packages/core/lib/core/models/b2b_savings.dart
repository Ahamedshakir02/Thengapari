import 'inventory_listing.dart';

/// Aggregated savings for a buyer over a period — drives the savings band and
/// the dashboard. Built from `/b2b_buyers/{uid}/savings`.
class SavingsSummary {
  final double totalSaved;
  final double totalSpent;
  final int orderCount;
  final double avgPercent;
  final Map<B2BCrop, double> perCrop;

  const SavingsSummary({
    this.totalSaved = 0,
    this.totalSpent = 0,
    this.orderCount = 0,
    this.avgPercent = 0,
    this.perCrop = const {},
  });
}
