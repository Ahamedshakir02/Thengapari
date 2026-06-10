import 'package:cloud_firestore/cloud_firestore.dart';

/// College stream a student site manager is enrolled in.
enum CollegeBranch {
  engineering,
  agriculture,
  science,
  commerce;

  String get label => switch (this) {
        CollegeBranch.engineering => 'Engineering',
        CollegeBranch.agriculture => 'Agriculture',
        CollegeBranch.science => 'Science',
        CollegeBranch.commerce => 'Commerce',
      };

  String get firestoreValue => name;

  static CollegeBranch? fromString(String? v) {
    for (final b in CollegeBranch.values) {
      if (b.name == v) return b;
    }
    return null;
  }
}

/// Year of study (1st–4th).
enum YearOfStudy {
  first,
  second,
  third,
  fourth;

  int get number => index + 1;

  String get label => switch (this) {
        YearOfStudy.first => '1st year',
        YearOfStudy.second => '2nd year',
        YearOfStudy.third => '3rd year',
        YearOfStudy.fourth => '4th year',
      };

  static YearOfStudy? fromNumber(int? n) {
    if (n == null || n < 1 || n > 4) return null;
    return YearOfStudy.values[n - 1];
  }
}

/// `/site_managers/{uid}` document (see docs/03_site_manager_app_plan.md).
///
/// A trained college student supervises harvests. [verified] is flipped to
/// `true` by an admin after reviewing the uploaded college ID — until then the
/// app shows a "verification pending" gate and no jobs are dispatched.
class SiteManagerProfile {
  final String collegeName;
  final String rollNumber;
  final CollegeBranch? branch;
  final YearOfStudy? yearOfStudy;
  final bool verified;
  final double rating;
  final int jobsCompleted;
  final String? currentJobId;
  final bool trainingComplete;
  final GeoPoint? operatingZone;
  final String? idDocUrl;

  const SiteManagerProfile({
    this.collegeName = '',
    this.rollNumber = '',
    this.branch,
    this.yearOfStudy,
    this.verified = false,
    this.rating = 0,
    this.jobsCompleted = 0,
    this.currentJobId,
    this.trainingComplete = false,
    this.operatingZone,
    this.idDocUrl,
  });

  factory SiteManagerProfile.fromFirestore(Map<String, dynamic> data) {
    return SiteManagerProfile(
      collegeName: data['collegeName'] as String? ?? '',
      rollNumber: data['rollNumber'] as String? ?? '',
      branch: CollegeBranch.fromString(data['branch'] as String?),
      yearOfStudy: YearOfStudy.fromNumber((data['yearOfStudy'] as num?)?.toInt()),
      verified: data['verified'] as bool? ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      jobsCompleted: (data['jobsCompleted'] as num?)?.toInt() ?? 0,
      currentJobId: data['currentJobId'] as String?,
      trainingComplete: data['trainingComplete'] as bool? ?? false,
      operatingZone: data['operatingZone'] as GeoPoint?,
      idDocUrl: data['idDocUrl'] as String?,
    );
  }

  /// Setup is done once the student has submitted college details + an ID doc.
  bool get isSetUp =>
      collegeName.isNotEmpty && rollNumber.isNotEmpty && idDocUrl != null;

  /// Cleared to receive job dispatch only when admin-verified AND trained.
  bool get canTakeJobs => verified && trainingComplete;
}
