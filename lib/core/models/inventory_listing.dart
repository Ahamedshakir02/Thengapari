import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Crops sold through the B2B portal. Tints + glyph colours match
/// `Designs/ThengaPari B2B Portal App/crops.jsx`.
enum B2BCrop {
  coconut,
  mango,
  pepper,
  jackfruit,
  banana,
  ginger,
  arecanut;

  String get label => switch (this) {
        B2BCrop.coconut => 'Coconut',
        B2BCrop.mango => 'Mango',
        B2BCrop.pepper => 'Black Pepper',
        B2BCrop.jackfruit => 'Jackfruit',
        B2BCrop.banana => 'Nendran Banana',
        B2BCrop.ginger => 'Ginger',
        B2BCrop.arecanut => 'Arecanut',
      };

  String get firestoreValue => name;

  /// Sold per piece or per kilogram.
  String get unit => switch (this) {
        B2BCrop.coconut || B2BCrop.jackfruit => 'pc',
        _ => 'kg',
      };

  /// Tinted circle background behind the glyph.
  Color get tint => switch (this) {
        B2BCrop.coconut => const Color(0xFFEFE3D6),
        B2BCrop.mango => const Color(0xFFFCEBCB),
        B2BCrop.pepper => const Color(0xFFE6EFD9),
        B2BCrop.jackfruit => const Color(0xFFECF3E0),
        B2BCrop.banana => const Color(0xFFFCEBCB),
        B2BCrop.ginger => const Color(0xFFF3E8D6),
        B2BCrop.arecanut => const Color(0xFFF3E8D6),
      };

  static B2BCrop fromString(String? v) {
    for (final c in B2BCrop.values) {
      if (c.name == v) return c;
    }
    return B2BCrop.coconut;
  }
}

/// `/inventory/{listingId}` — a live crop lot created by
/// `updateInventoryOnHarvest` after a Site Manager completes a job. All four
/// apps treat this as the B2B-facing projection of a harvest's yield.
class InventoryListing {
  final String id;
  final B2BCrop cropType;
  final String grade; // "Grade A" / "Grade B"
  final int quantity;
  final int quantityRemaining;
  final double unitPrice;
  final double wholesaleMarketPrice;
  final double savingsPercent;
  final DateTime? harvestedAt;
  final String ward;
  final GeoPoint? location;
  final bool available;
  final String? jobId;

  // Design extras (optional — seeded/enriched by ops).
  final String? variety;
  final String? condition;
  final double? distanceKm;
  final String? farmName;
  final double? farmRating;
  final int? farmHarvests;
  final String? farmSince;
  final String? farmPlot;

  const InventoryListing({
    required this.id,
    required this.cropType,
    this.grade = 'Grade A',
    this.quantity = 0,
    this.quantityRemaining = 0,
    this.unitPrice = 0,
    this.wholesaleMarketPrice = 0,
    double? savingsPercent,
    this.harvestedAt,
    this.ward = '',
    this.location,
    this.available = true,
    this.jobId,
    this.variety,
    this.condition,
    this.distanceKm,
    this.farmName,
    this.farmRating,
    this.farmHarvests,
    this.farmSince,
    this.farmPlot,
  }) : savingsPercent = savingsPercent ??
            (wholesaleMarketPrice <= 0
                ? 0
                : (wholesaleMarketPrice - unitPrice) / wholesaleMarketPrice * 100);

  String get unit => cropType.unit;

  /// ₹ saved per unit vs wholesale.
  double get savingsPerUnit => wholesaleMarketPrice - unitPrice;

  /// Hours since harvest (for the freshness indicator).
  int get freshnessHours =>
      harvestedAt == null ? 0 : DateTime.now().difference(harvestedAt!).inHours;

  /// 0–4h "Peak fresh", 4–12h "Fresh", else "Good".
  String get freshnessLabel => switch (freshnessHours) {
        <= 4 => 'Peak fresh',
        <= 12 => 'Fresh',
        _ => 'Good',
      };

  /// 1.0 (just harvested) → ~0 (24h+), for the freshness progress bar.
  double get freshnessFraction =>
      (1 - freshnessHours / 24).clamp(0.0, 1.0).toDouble();

  String get harvestLabel {
    final h = freshnessHours;
    if (harvestedAt == null) return 'Recently harvested';
    if (h < 24) return 'Harvested today';
    if (h < 48) return 'Harvested yesterday';
    return 'Harvested ${h ~/ 24}d ago';
  }

  /// Write payload for `/inventory/{id}`. NOTE: in production the live writer
  /// is the `updateInventoryOnHarvest` Cloud Function (functions/inventory.ts);
  /// keep these field names in sync with that function. Provided here for Dart
  /// round-tripping / tests / future admin tooling.
  Map<String, Object?> toFirestore() {
    return {
      'cropType': cropType.firestoreValue,
      'grade': grade,
      'quantity': quantity,
      'quantityRemaining': quantityRemaining,
      'unitPrice': unitPrice,
      'wholesaleMarketPrice': wholesaleMarketPrice,
      'savingsPercent': savingsPercent,
      'harvestedAt': harvestedAt == null ? null : Timestamp.fromDate(harvestedAt!),
      'location': location,
      'ward': ward,
      'available': available,
      'jobId': jobId,
      'variety': variety,
      'condition': condition,
      'distanceKm': distanceKm,
      'farmName': farmName,
      'farmRating': farmRating,
      'farmHarvests': farmHarvests,
      'farmSince': farmSince,
      'farmPlot': farmPlot,
    };
  }

  factory InventoryListing.fromFirestore(String id, Map<String, dynamic> data) {
    return InventoryListing(
      id: id,
      cropType: B2BCrop.fromString(data['cropType'] as String?),
      grade: data['grade'] as String? ?? 'Grade A',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      quantityRemaining: (data['quantityRemaining'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      wholesaleMarketPrice:
          (data['wholesaleMarketPrice'] as num?)?.toDouble() ?? 0,
      savingsPercent: (data['savingsPercent'] as num?)?.toDouble(),
      harvestedAt: (data['harvestedAt'] as Timestamp?)?.toDate(),
      ward: data['ward'] as String? ?? '',
      location: data['location'] as GeoPoint?,
      available: data['available'] as bool? ?? true,
      jobId: data['jobId'] as String?,
      variety: data['variety'] as String?,
      condition: data['condition'] as String?,
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
      farmName: data['farmName'] as String?,
      farmRating: (data['farmRating'] as num?)?.toDouble(),
      farmHarvests: (data['farmHarvests'] as num?)?.toInt(),
      farmSince: data['farmSince'] as String?,
      farmPlot: data['farmPlot'] as String?,
    );
  }
}
