import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Worker skill types. [firestoreValue] is the stable snake_case stored in
/// `/workers/{uid}.skills` and matched by the job-matching Cloud Function.
enum WorkerSkill {
  climber,
  husker,
  pepperPicker,
  jackfruitProcessor,
  generalLabour;

  String get label => switch (this) {
        WorkerSkill.climber => 'Climber',
        WorkerSkill.husker => 'Husker',
        WorkerSkill.pepperPicker => 'Pepper picker',
        WorkerSkill.jackfruitProcessor => 'Jackfruit processor',
        WorkerSkill.generalLabour => 'General labour',
      };

  String get firestoreValue => switch (this) {
        WorkerSkill.climber => 'climber',
        WorkerSkill.husker => 'husker',
        WorkerSkill.pepperPicker => 'pepper_picker',
        WorkerSkill.jackfruitProcessor => 'jackfruit_processor',
        WorkerSkill.generalLabour => 'general_labour',
      };

  IconData get icon => switch (this) {
        WorkerSkill.climber => Icons.park_outlined,
        WorkerSkill.husker => Icons.spa_outlined,
        WorkerSkill.pepperPicker => Icons.grass_outlined,
        WorkerSkill.jackfruitProcessor => Icons.eco_outlined,
        WorkerSkill.generalLabour => Icons.handyman_outlined,
      };

  static WorkerSkill? fromString(String? v) {
    for (final s in WorkerSkill.values) {
      if (s.firestoreValue == v) return s;
    }
    return null;
  }
}

/// `/workers/{uid}` document.
class WorkerProfile {
  final List<WorkerSkill> skills;
  final String upiVpa;
  final bool isOnline;
  final double reliabilityScore;
  final int totalJobsCompleted;
  final double totalEarned;
  final GeoPoint? location;

  const WorkerProfile({
    this.skills = const [],
    this.upiVpa = '',
    this.isOnline = false,
    this.reliabilityScore = 100,
    this.totalJobsCompleted = 0,
    this.totalEarned = 0,
    this.location,
  });

  factory WorkerProfile.fromFirestore(Map<String, dynamic> data) {
    return WorkerProfile(
      skills: ((data['skills'] as List?) ?? const [])
          .map((e) => WorkerSkill.fromString(e.toString()))
          .whereType<WorkerSkill>()
          .toList(),
      upiVpa: data['upiVpa'] as String? ?? '',
      isOnline: data['isOnline'] as bool? ?? false,
      reliabilityScore: (data['reliabilityScore'] as num?)?.toDouble() ?? 100,
      totalJobsCompleted: (data['totalJobsCompleted'] as num?)?.toInt() ?? 0,
      totalEarned: (data['totalEarned'] as num?)?.toDouble() ?? 0,
      location: data['location'] as GeoPoint?,
    );
  }

  /// Worker has finished setup once they have at least one skill + a UPI VPA.
  bool get isSetUp => skills.isNotEmpty && upiVpa.isNotEmpty;
}
