import 'package:cloud_firestore/cloud_firestore.dart';

/// `/job_pings/{pingId}` — a time-boxed job offer fanned out to one worker by
/// the `broadcastWorkerPing` / `broadcastProcessorPing` Cloud Functions.
///
/// The worker either accepts (via the atomic `acceptPing` callable — never a
/// direct write) or declines (client write allowed by rules) before
/// [expiresAt]. Field names match `functions/src/pings.ts`, the canonical
/// writer.
class JobPing {
  final String id;
  final String jobId;
  final String workerId;

  /// 'pending' | 'accepted' | 'declined' | 'cancelled'
  final String status;
  final String? cropType;
  final String? requiredSkill;
  final double? yieldKg;
  final double? distanceKm;
  final int? etaMin;
  final double? payout;
  final String? place;

  /// Display name of the site manager who posted the job (denormalised by the
  /// broadcast function so the ping screen can show it pre-acceptance).
  final String? managerName;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  const JobPing({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.status,
    this.cropType,
    this.requiredSkill,
    this.yieldKg,
    this.distanceKm,
    this.etaMin,
    this.payout,
    this.place,
    this.managerName,
    this.createdAt,
    this.expiresAt,
  });

  factory JobPing.fromFirestore(String id, Map<String, dynamic> data) {
    return JobPing(
      id: id,
      jobId: data['jobId'] as String? ?? '',
      workerId: data['workerId'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      cropType: data['cropType'] as String?,
      requiredSkill: data['requiredSkill'] as String?,
      yieldKg: (data['yieldKg'] as num?)?.toDouble(),
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
      etaMin: (data['etaMin'] as num?)?.toInt(),
      payout: (data['payout'] as num?)?.toDouble(),
      place: data['place'] as String?,
      managerName: data['managerName'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  bool get isPending => status == 'pending' && !isExpired;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Seconds until expiry, floored at 0.
  int get secondsLeft {
    if (expiresAt == null) return 0;
    final s = expiresAt!.difference(DateTime.now()).inSeconds;
    return s < 0 ? 0 : s;
  }

  /// Headline for the ping takeover screen, e.g. "Coconut husking needed".
  String get headline {
    final crop = (cropType ?? 'harvest').replaceFirst(
        cropType?.isNotEmpty == true ? cropType![0] : '',
        cropType?.isNotEmpty == true ? cropType![0].toUpperCase() : '');
    return switch (requiredSkill) {
      'husker' => '$crop husking needed',
      'climber' => '$crop climbing needed',
      _ => '$crop work needed',
    };
  }
}
