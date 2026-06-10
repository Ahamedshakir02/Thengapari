import 'package:cloud_firestore/cloud_firestore.dart';

/// A processor (husker/buyer) who accepted a broadcast ping — one
/// `/job_pings/{pingId}` document with `status == 'accepted'`. Streamed live
/// onto the BroadcastPingScreen response list.
class ProcessorResponse {
  final String id;
  final String workerId;
  final String name;
  final double rating;
  final int jobsCompleted;
  final double distanceKm;
  final int etaMin;
  final String typeLabel;
  final String status;

  const ProcessorResponse({
    required this.id,
    this.workerId = '',
    required this.name,
    this.rating = 0,
    this.jobsCompleted = 0,
    this.distanceKm = 0,
    this.etaMin = 0,
    this.typeLabel = '',
    this.status = 'accepted',
  });

  bool get isAssigned => status == 'assigned';

  factory ProcessorResponse.fromFirestore(String id, Map<String, dynamic> data) {
    return ProcessorResponse(
      id: id,
      workerId: data['workerId'] as String? ?? '',
      name: data['workerName'] as String? ?? data['name'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      jobsCompleted: (data['jobsCompleted'] as num?)?.toInt() ?? 0,
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0,
      etaMin: (data['etaMin'] as num?)?.toInt() ?? 0,
      typeLabel: data['typeLabel'] as String? ?? '',
      status: data['status'] as String? ?? 'accepted',
    );
  }

  ProcessorResponse copyWith({String? status}) => ProcessorResponse(
        id: id,
        workerId: workerId,
        name: name,
        rating: rating,
        jobsCompleted: jobsCompleted,
        distanceKm: distanceKm,
        etaMin: etaMin,
        typeLabel: typeLabel,
        status: status ?? this.status,
      );
}
