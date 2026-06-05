import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/job_status_badge.dart';

/// The central `/jobs/{jobId}` document (see docs/00_shared_architecture.md).
/// All four apps read/write this; the homeowner app mostly reads it.
///
/// [status] is kept as the raw Firestore string so it round-trips losslessly
/// across apps; [badgeStatus] / [progress] derive UI state from it.
class HarvestJob {
  final String id;
  final String homeownerId;
  final String? siteManagerId;
  final List<String> workerIds;
  final List<String> cropTypes;
  final String status;
  final String? address;
  final String? district;
  final GeoPoint? location;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final double? estimatedYieldKg;
  final double? actualYieldKg;
  final int? gradeA;
  final int? gradeB;
  final int? tender;
  final double? earningsAmount;
  final double? feeAmount;
  final String paymentStatus;
  final String? reportUrl;
  final List<String> photos;
  final String notes;
  final DateTime? createdAt;

  const HarvestJob({
    required this.id,
    required this.homeownerId,
    this.siteManagerId,
    this.workerIds = const [],
    this.cropTypes = const [],
    this.status = 'pending',
    this.address,
    this.district,
    this.location,
    this.scheduledAt,
    this.completedAt,
    this.estimatedYieldKg,
    this.actualYieldKg,
    this.gradeA,
    this.gradeB,
    this.tender,
    this.earningsAmount,
    this.feeAmount,
    this.paymentStatus = 'unpaid',
    this.reportUrl,
    this.photos = const [],
    this.notes = '',
    this.createdAt,
  });

  factory HarvestJob.fromFirestore(String id, Map<String, dynamic> data) {
    List<String> strList(dynamic v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? const [];
    return HarvestJob(
      id: id,
      homeownerId: data['homeownerId'] as String? ?? '',
      siteManagerId: data['siteManagerId'] as String?,
      workerIds: strList(data['workerIds']),
      cropTypes: strList(data['cropTypes']),
      status: data['status'] as String? ?? 'pending',
      address: data['address'] as String?,
      district: data['district'] as String?,
      location: data['location'] as GeoPoint?,
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      estimatedYieldKg: (data['estimatedYieldKg'] as num?)?.toDouble(),
      actualYieldKg: (data['actualYieldKg'] as num?)?.toDouble(),
      gradeA: (data['gradeA'] as num?)?.toInt(),
      gradeB: (data['gradeB'] as num?)?.toInt(),
      tender: (data['tender'] as num?)?.toInt(),
      earningsAmount: (data['earningsAmount'] as num?)?.toDouble(),
      feeAmount: (data['feeAmount'] as num?)?.toDouble(),
      paymentStatus: data['paymentStatus'] as String? ?? 'unpaid',
      reportUrl: data['reportUrl'] as String?,
      photos: strList(data['photos']),
      notes: data['notes'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Still ongoing — neither finished nor cancelled.
  bool get isActive => status != 'complete' && status != 'cancelled';

  bool get isComplete => status == 'complete';

  /// Maps the raw Firestore status to the shared [JobStatus] badge enum.
  JobStatus get badgeStatus => switch (status) {
        'pending' => JobStatus.scheduled,
        'site_manager_assigned' => JobStatus.assigned,
        'worker_assigned' => JobStatus.assigned,
        'in_progress' => JobStatus.inProgress,
        'harvesting' => JobStatus.inProgress,
        'processing' => JobStatus.processing,
        'byproducts_routed' => JobStatus.processing,
        'complete' => JobStatus.complete,
        _ => JobStatus.scheduled,
      };

  /// 0.0–1.0 progress for the in-progress bar, or null when not yet underway.
  double? get progress => switch (status) {
        'in_progress' => 0.55,
        'harvesting' => 0.70,
        'processing' => 0.85,
        'byproducts_routed' => 0.95,
        'complete' => 1.0,
        _ => null,
      };

  /// e.g. "Coconut + Mango harvest".
  String get title {
    if (cropTypes.isEmpty) return 'Harvest';
    final names = cropTypes
        .map((c) => c.isEmpty ? c : '${c[0].toUpperCase()}${c.substring(1)}')
        .join(' + ');
    return '$names harvest';
  }
}
