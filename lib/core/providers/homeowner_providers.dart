import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/harvest_job.dart';
import '../models/job_status_update.dart';
import '../models/tree_inventory.dart';
import '../services/homeowner_service.dart';

/// Single shared [HomeownerService] instance.
final homeownerServiceProvider =
    Provider<HomeownerService>((ref) => HomeownerService());

/// Real-time tree inventory for a homeowner — `/homeowners/{uid}/trees`.
final treeInventoryProvider =
    StreamProvider.family<List<TreeInventory>, String>((ref, uid) {
  return ref.watch(homeownerServiceProvider).watchTrees(uid);
});

/// Real-time stream of all of a homeowner's jobs — `/jobs` filtered by
/// `homeownerId`. Used to derive the active job and earnings.
final homeownerJobsProvider =
    StreamProvider.family<List<HarvestJob>, String>((ref, uid) {
  return ref.watch(homeownerServiceProvider).watchHomeownerJobs(uid);
});

/// The single active (not complete/cancelled) job, or null. Real-time.
final activeJobProvider =
    StreamProvider.family<HarvestJob?, String>((ref, uid) {
  return ref.watch(homeownerServiceProvider).watchHomeownerJobs(uid).map((jobs) {
    for (final job in jobs) {
      if (job.isActive) return job;
    }
    return null;
  });
});

/// The most recent completed job for a homeowner (drives the yield report).
final latestCompletedJobProvider =
    StreamProvider.family<HarvestJob?, String>((ref, uid) {
  return ref.watch(homeownerServiceProvider).watchHomeownerJobs(uid).map((jobs) {
    HarvestJob? latest;
    for (final job in jobs) {
      if (!job.isComplete) continue;
      if (latest == null ||
          (job.completedAt ?? DateTime(0))
              .isAfter(latest.completedAt ?? DateTime(0))) {
        latest = job;
      }
    }
    return latest;
  });
});

/// Real-time on-site checklist events for a job — `/jobs/{jobId}/statusUpdates`
/// ordered by time (drives the live tracker timeline).
final statusUpdatesProvider =
    StreamProvider.family<List<JobStatusUpdate>, String>((ref, jobId) {
  return FirebaseFirestore.instance
      .collection('jobs/$jobId/statusUpdates')
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs
          .map((d) => JobStatusUpdate.fromFirestore(d.id, d.data()))
          .toList());
});

/// Sum of completed-job earnings in the last 30 days.
final monthlyEarningsProvider =
    FutureProvider.family<double, String>((ref, uid) async {
  final jobs = await ref.watch(homeownerServiceProvider).fetchHomeownerJobs(uid);
  final cutoff = DateTime.now().subtract(const Duration(days: 30));
  return jobs
      .where((j) =>
          j.isComplete &&
          j.earningsAmount != null &&
          (j.completedAt?.isAfter(cutoff) ?? false))
      .fold<double>(0, (acc, j) => acc + (j.earningsAmount ?? 0));
});

/// Completed-job earnings bucketed into the last 6 weeks (oldest → newest) for
/// [WeeklyEarningsChartPainter].
final weeklyEarningsProvider =
    FutureProvider.family<List<double>, String>((ref, uid) async {
  final jobs = await ref.watch(homeownerServiceProvider).fetchHomeownerJobs(uid);
  const weeks = 6;
  final now = DateTime.now();
  final buckets = List<double>.filled(weeks, 0);
  for (final job in jobs) {
    if (!job.isComplete || job.earningsAmount == null) continue;
    final when = job.completedAt;
    if (when == null) continue;
    final daysAgo = now.difference(when).inDays;
    final weekIdx = weeks - 1 - (daysAgo ~/ 7);
    if (weekIdx >= 0 && weekIdx < weeks) {
      buckets[weekIdx] += job.earningsAmount!;
    }
  }
  return buckets;
});
