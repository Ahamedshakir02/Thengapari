/// Result of `calculateYieldEstimate` — the pre-booking price preview.
class YieldEstimate {
  final double estimatedKg;
  final double estimatedEarning;
  final double marketRate; // ₹/kg (weighted)

  const YieldEstimate({
    required this.estimatedKg,
    required this.estimatedEarning,
    required this.marketRate,
  });
}
