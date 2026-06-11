import 'package:cloud_firestore/cloud_firestore.dart';

import 'job_step.dart';

/// One `/jobs/{jobId}/statusUpdates/{id}` event, written by the Site Manager
/// app as it works through the on-site checklist.
///
/// This file is the SINGLE SOURCE OF TRUTH for the statusUpdates field names:
/// [writeData] (writer, used by `SiteManagerService.completeStep`) and
/// [fromFirestore] (reader, used by the Homeowner live tracker) live together
/// so the cross-app contract can never drift. Do not hand-roll this map
/// elsewhere.
class JobStatusUpdate {
  final String id;
  final String title;
  final String? note;
  final DateTime? createdAt;

  const JobStatusUpdate({
    required this.id,
    required this.title,
    this.note,
    this.createdAt,
  });

  factory JobStatusUpdate.fromFirestore(String id, Map<String, dynamic> data) {
    return JobStatusUpdate(
      id: id,
      title: data['title'] as String? ?? data['step'] as String? ?? '',
      note: data['note'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// The canonical write payload for a checklist step event. Carries both the
  /// machine fields (`type`/`step`/`timestamp`) and the fields the Homeowner
  /// tracker reads (`title`/`createdAt`).
  static Map<String, Object?> writeData({
    required ManagerStepKind kind,
    required String siteManagerId,
    String? note,
    String? photoUrl,
    GeoPoint? location,
  }) {
    return {
      'type': kind.id,
      'step': kind.id,
      'title': kind.label,
      'note': ?note,
      'photoUrl': ?photoUrl,
      'location': ?location,
      'siteManagerId': siteManagerId,
      'createdAt': FieldValue.serverTimestamp(),
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
