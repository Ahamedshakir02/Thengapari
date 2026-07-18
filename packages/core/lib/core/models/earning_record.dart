import 'package:cloud_firestore/cloud_firestore.dart';

/// `/workers/{uid}/earnings/{jobId}` — one payout record per completed job.
/// Written by the `markJobComplete` Cloud Function (admin only); the Worker
/// app reads these for the day stats and the weekly earnings chart.
class EarningRecord {
  final String id;
  final String jobId;
  final double amount;
  final DateTime? createdAt;

  const EarningRecord({
    required this.id,
    required this.jobId,
    required this.amount,
    this.createdAt,
  });

  factory EarningRecord.fromFirestore(String id, Map<String, dynamic> data) {
    return EarningRecord(
      id: id,
      jobId: data['jobId'] as String? ?? id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
