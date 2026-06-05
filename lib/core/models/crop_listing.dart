import 'package:flutter/material.dart';

/// A single crop listing in the B2B live-inventory browser.
///
/// Hand-written for the foundation phase (matches the existing model
/// convention in this package). Note [bgColor] is a [Color]; the plan's
/// `freezed` migration will need a JSON converter for it once Firestore
/// serialization is wired up.
class CropListing {
  final String id;
  final String name;
  final String grade; // "Grade A", "Alphonso", "dry"
  final String icon; // emoji/glyph rendered as text
  final Color bgColor;
  final String harvestedLabel;
  final String location;
  final String quantity;
  final String priceLabel; // "₹18/pc"
  final String savingLabel; // "↓12% vs market"
  final double savingPercent;

  const CropListing({
    required this.id,
    required this.name,
    required this.grade,
    required this.icon,
    required this.bgColor,
    required this.harvestedLabel,
    required this.location,
    required this.quantity,
    required this.priceLabel,
    required this.savingLabel,
    required this.savingPercent,
  });
}
