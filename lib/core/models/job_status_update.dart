import 'package:cloud_firestore/cloud_firestore.dart';

/// One `/jobs/{jobId}/statusUpdates/{id}` event, written by the Site Manager
/// app as it works through the on-site checklist.
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
}
