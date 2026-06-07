import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/worker_profile.dart';
import '../services/worker_service.dart';
import 'auth_provider.dart';

/// Single shared [WorkerService] instance.
final workerServiceProvider = Provider<WorkerService>((ref) => WorkerService());

/// Live `/workers/{uid}` profile (skills, online state, reliability, etc.).
final workerProfileProvider =
    StreamProvider.family<WorkerProfile?, String>((ref, uid) {
  return ref.watch(workerServiceProvider).watchWorker(uid);
});

/// Availability toggle state for the Worker home screen. Writes `isOnline` to
/// `/workers/{uid}` and starts/stops location tracking (location tracking is
/// wired up in a later step). Kept optimistic so the switch feels instant.
final workerAvailabilityProvider =
    StateNotifierProvider<WorkerAvailabilityNotifier, bool>(
        (ref) => WorkerAvailabilityNotifier(ref));

class WorkerAvailabilityNotifier extends StateNotifier<bool> {
  WorkerAvailabilityNotifier(this._ref) : super(false);

  final Ref _ref;
  bool _seeded = false;

  /// Seed the initial value from the live profile, once.
  void seed(bool online) {
    if (_seeded) return;
    _seeded = true;
    state = online;
  }

  Future<void> toggle() async {
    final next = !state;
    state = next; // optimistic
    final uid = _ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    try {
      await _ref.read(workerServiceProvider).setOnline(uid, next);
    } catch (_) {
      // Keep the optimistic value; a later step surfaces sync errors.
    }
  }
}

/// At-a-glance numbers for the two home-screen stat cards.
class WorkerDayStats {
  final double earningsToday;
  final int jobsCompletedToday;

  const WorkerDayStats({
    this.earningsToday = 0,
    this.jobsCompletedToday = 0,
  });
}

/// Today's earnings + completed-job count. Backed by an aggregation over
/// `/workers/{uid}/earnings` in the real app; seeded in the dev harness.
final workerDayStatsProvider =
    StreamProvider.family<WorkerDayStats, String>((ref, uid) {
  return Stream.value(const WorkerDayStats());
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

/// Today's confirmed (pre-accepted) jobs. Reads `/jobs` filtered by
/// `workerId == uid` and today's date in the real app; seeded in the harness.
final workerConfirmedJobsProvider =
    StreamProvider.family<List<WorkerConfirmedJob>, String>((ref, uid) {
  return Stream.value(const []);
});

/// Last 7 days of earnings (Mon → Sun) for the weekly bar chart. Index 6 is
/// today. Backed by `/workers/{uid}/earnings` in the real app.
final workerWeeklyEarningsProvider =
    StreamProvider.family<List<double>, String>((ref, uid) {
  return Stream.value(const [0, 0, 0, 0, 0, 0, 0]);
});
