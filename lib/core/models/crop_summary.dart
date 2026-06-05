/// A crop chip shown in the homeowner hero inventory row.
///
/// Hand-written for the foundation phase (matches the existing model
/// convention in this package). The plan migrates this to `freezed` +
/// `json_serializable` once feature work begins.
class CropSummary {
  final String name;
  final String icon; // emoji or glyph rendered as text, e.g. "🥥"
  final String quantity; // "×24", "×8", "~2 kg"
  final DateTime? nextHarvest;

  const CropSummary({
    required this.name,
    required this.icon,
    required this.quantity,
    this.nextHarvest,
  });
}
