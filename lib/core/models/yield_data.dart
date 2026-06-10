import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

/// The three harvest grades logged on-site. Colours + per-nut market rates
/// match `GRADE_META` in `Designs/ThengaPari Site Manager App/screen2.jsx`.
enum CropGrade {
  gradeA,
  gradeB,
  tender;

  String get label => switch (this) {
        CropGrade.gradeA => 'Grade A',
        CropGrade.gradeB => 'Grade B',
        CropGrade.tender => 'Tender',
      };

  String get firestoreKey => switch (this) {
        CropGrade.gradeA => 'gradeA',
        CropGrade.gradeB => 'gradeB',
        CropGrade.tender => 'tender',
      };

  /// ₹ per nut used for the live estimate.
  int get pricePerNut => switch (this) {
        CropGrade.gradeA => 24,
        CropGrade.gradeB => 15,
        CropGrade.tender => 32,
      };

  Color get color => switch (this) {
        CropGrade.gradeA => AppColors.greenForest700,
        CropGrade.gradeB => AppColors.greenSage500,
        CropGrade.tender => AppColors.accent,
      };
}

/// `/jobs/{jobId}/yieldData/current` — the live yield log written by the Site
/// Manager during weighing. Mirrored onto the parent job summary fields the
/// Homeowner app reads (`actualYieldKg`, `gradeA`, `gradeB`, `tender`).
class YieldData {
  final double totalKg;
  final int gradeA;
  final int gradeB;
  final int tender;
  final double estimatedValue;
  final String? scalePhotoUrl;
  final DateTime? loggedAt;
  final String? loggedBy;

  const YieldData({
    this.totalKg = 0,
    this.gradeA = 0,
    this.gradeB = 0,
    this.tender = 0,
    this.estimatedValue = 0,
    this.scalePhotoUrl,
    this.loggedAt,
    this.loggedBy,
  });

  int get totalNuts => gradeA + gradeB + tender;

  int countFor(CropGrade g) => switch (g) {
        CropGrade.gradeA => gradeA,
        CropGrade.gradeB => gradeB,
        CropGrade.tender => tender,
      };

  /// Live estimated value at market rate (₹).
  static double estimate(int gradeA, int gradeB, int tender) =>
      gradeA * CropGrade.gradeA.pricePerNut +
      gradeB * CropGrade.gradeB.pricePerNut +
      tender * CropGrade.tender.pricePerNut;

  factory YieldData.fromFirestore(Map<String, dynamic> data) {
    return YieldData(
      totalKg: (data['totalKg'] as num?)?.toDouble() ?? 0,
      gradeA: (data['gradeA'] as num?)?.toInt() ?? 0,
      gradeB: (data['gradeB'] as num?)?.toInt() ?? 0,
      tender: (data['tender'] as num?)?.toInt() ?? 0,
      estimatedValue: (data['estimatedValue'] as num?)?.toDouble() ?? 0,
      scalePhotoUrl: data['scalePhotoUrl'] as String?,
      loggedAt: (data['loggedAt'] as Timestamp?)?.toDate(),
      loggedBy: data['loggedBy'] as String?,
    );
  }
}
