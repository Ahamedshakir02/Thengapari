import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/earning_record.dart';
import '../models/harvest_job.dart';
import '../models/job_ping.dart';
import '../models/worker_profile.dart';
import '../services/worker_service.dart';
import '../utils/geo.dart';
import 'auth_provider.dart';

/// Single shared [WorkerService] instance.
final workerServiceProvider = Provider<WorkerService>((ref) => WorkerService());

/// Live `/workers/{uid}` profile (skills, online state, reliability, etc.).
final workerProfileProvider =
    StreamProvider.family<WorkerProfile?, String>((ref, uid) {
  return ref.watch(workerServiceProvider).watchWorker(uid);
});

/// The newest still-valid pending job ping for this worker, or null. The home
/// screen listens to this to trigger the full-screen ping takeover.
final workerPendingPingProvider =
    StreamProvider.family<JobPing?, String>((ref, uid) {
  return ref.watch(workerServiceProvider).watchPendingPing(uid);
});

/// Availability toggle state for the Worker home screen. Writes `isOnline` to
/// `/workers/{uid}` and refreshes the stored location when going online so
/// ping fan-out can compute distances. Kept optimistic so the switch feels
/// instant.
class WorkerAvailabilityNotifier extends Notifier<bool> {
  bool _seeded = false;

  @override
  bool build() => false;

  /// Seed the initial value from the live profile, once.
  void seed(bool online) {
    if (_seeded) return;
    _seeded = true;
    state = online;
  }

  Future<void> toggle() async {
    final next = !state;
    state = next; // optimistic
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    final service = ref.read(workerServiceProvider);
    try {
      await service.setOnline(uid, next);
      if (next) await service.syncLocation(uid);
    } catch (_) {
      // Keep the optimistic value; a later step surfaces sync errors.
    }
  }
}

final workerAvailabilityProvider =
    NotifierProvider<WorkerAvailabilityNotifier, bool>(
        WorkerAvailabilityNotifier.new);

/// At-a-glance numbers for the two home-screen stat cards.
class WorkerDayStats {
  final double earningsToday;
  final int jobsCompletedToday;

  const WorkerDayStats({
    this.earningsToday = 0,
    this.jobsCompletedToday = 0,
  });
}

/// Earnings records for the current week (Mon 00:00 → now). One stream backs
/// both the day stats and the weekly chart.
final _weekEarningsProvider =
    StreamProvider.family<List<EarningRecord>, String>((ref, uid) {
  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  return ref.watch(workerServiceProvider).watchEarningsSince(uid, monday);
});

/// Today's earnings + completed-job count from `/workers/{uid}/earnings`.
final workerDayStatsProvider =
    StreamProvider.family<WorkerDayStats, String>((ref, uid) {
  final records = ref.watch(_weekEarningsProvider(uid)).value ?? const [];
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  double total = 0;
  int count = 0;
  for (final r in records) {
    final at = r.createdAt;
    if (at == null || at.isBefore(startOfDay)) continue;
    total += r.amount;
    count++;
  }
  return Stream.value(
      WorkerDayStats(earningsToday: total, jobsCompletedToday: count));
});

/// A pre-accepted job shown in the "Today's confirmed jobs" list.
class WorkerConfirmedJob {
  final String id;
  final String title;
  final String place;
  final String distance;
  final DateTime scheduledAt;
  final double payout;

  /// `true` for the next imminent job (amber "Up next" badge).
  final bool isNext;

  const WorkerConfirmedJob({
    required this.id,
    required this.title,
    required this.place,
    required this.distance,
    required this.scheduledAt,
    required this.payout,
    this.isNext = false,
  });
}

/// Today's confirmed (pre-accepted) jobs — `/jobs` where `workerIds` contains
/// this worker and `scheduledAt` is today.
final workerConfirmedJobsProvider =
    StreamProvider.family<List<WorkerConfirmedJob>, String>((ref, uid) {
  final workerLoc = ref.watch(workerProfileProvider(uid)).value?.location;
  return ref
      .watch(workerServiceProvider)
      .watchTodayAssignedJobs(uid)
      .map((jobs) {
    final active = jobs.where((j) => j.isActive).toList();
    return [
      for (final (i, job) in active.indexed)
        WorkerConfirmedJob(
          id: job.id,
          title: _confirmedTitle(job),
          place: job.address ?? job.district ?? 'Job site',
          distance: workerLoc != null && job.location != null
              ? '${haversineKm(workerLoc, job.location!).toStringAsFixed(1)} km'
              : '—',
          scheduledAt: job.scheduledAt ?? DateTime.now(),
          // Worker share defaults to 55% of job earnings until the Cloud
          // Function writes the exact payout (same fallback as markJobComplete).
          payout: ((job.earningsAmount ?? 0) * 0.55).roundToDouble(),
          isNext: i == 0,
        ),
    ];
  });
});

String _confirmedTitle(HarvestJob job) {
  final crop = job.cropTypes.isEmpty ? 'Harvest' : job.cropTypes.first;
  final cropLabel = crop[0].toUpperCase() + crop.substring(1);
  final yield_ = job.estimatedYieldKg;
  return yield_ != null
      ? '$cropLabel harvest · ~${yield_.round()} kg'
      : '$cropLabel harvest';
}

/// This week's earnings (Mon → Sun) for the weekly bar chart. Index is
/// `weekday - 1`, so today lines up with the highlighted bar.
final workerWeeklyEarningsProvider =
    StreamProvider.family<List<double>, String>((ref, uid) {
  final records = ref.watch(_weekEarningsProvider(uid)).value ?? const [];
  final buckets = List<double>.filled(7, 0);
  for (final r in records) {
    final at = r.createdAt;
    if (at == null) continue;
    buckets[at.weekday - 1] += r.amount;
  }
  return Stream.value(buckets);
});

/// Streams the worker's live position into `/jobs/{jobId}/tracking` while
/// travelling to a job (started by the Navigate screen, stopped on arrival or
/// dispose). Best-effort: permission denials just leave the map static.
class WorkerTrackingController extends Notifier<String?> {
  StreamSubscription<GeoPoint>? _sub;

  @override
  String? build() {
    ref.onDispose(() => _sub?.cancel());
    return null;
  }

  void start(String jobId) {
    if (state == jobId) return;
    stop();
    state = jobId;
    final service = ref.read(workerServiceProvider);
    try {
      _sub = service.positionStream().listen(
            (p) => service.writeTrackingPoint(jobId, p),
            onError: (_) {/* location unavailable — keep the screen alive */},
          );
    } catch (_) {/* plugin unavailable (e.g. tests) */}
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    state = null;
  }
}

final workerTrackingProvider =
    NotifierProvider<WorkerTrackingController, String?>(
        WorkerTrackingController.new);
