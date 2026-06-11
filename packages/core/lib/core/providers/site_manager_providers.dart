import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// StateProvider moved to the legacy export in Riverpod 3.x.
import 'package:flutter_riverpod/legacy.dart';

import '../models/byproduct.dart';
import '../models/harvest_job.dart';
import '../models/job_step.dart';
import '../models/processor_response.dart';
import '../models/site_manager_profile.dart';
import '../models/yield_data.dart';
import '../services/site_manager_service.dart';

/// Single shared [SiteManagerService] instance.
final siteManagerServiceProvider =
    Provider<SiteManagerService>((ref) => SiteManagerService());

/// Selected bottom-nav tab in the Site Manager shell (Today / On-site /
/// Earnings / Profile). Lets pushed screens (e.g. check-in) jump to a tab.
final managerTabProvider = StateProvider<int>((ref) => 0);

/// Live `/site_managers/{uid}` profile (verification, rating, training, etc.).
final siteManagerProfileProvider =
    StreamProvider.family<SiteManagerProfile?, String>((ref, uid) {
  return ref.watch(siteManagerServiceProvider).watchProfile(uid);
});

/// Today's assigned jobs for the daily queue.
final todayJobsProvider =
    StreamProvider.family<List<HarvestJob>, String>((ref, uid) {
  return ref.watch(siteManagerServiceProvider).watchTodayJobs(uid);
});

/// Live, sequentially-unlocked checklist for a job (drives OnSiteScreen).
final jobStepsProvider =
    StreamProvider.family<List<JobStep>, String>((ref, jobId) {
  return ref.watch(siteManagerServiceProvider).watchSteps(jobId);
});

/// Live yield log for a job — `/jobs/{jobId}/yieldData/current`.
final yieldDataProvider =
    StreamProvider.family<YieldData?, String>((ref, jobId) {
  return ref.watch(siteManagerServiceProvider).watchYield(jobId);
});

/// Live worker Accept responses to a broadcast ping.
final pingResponsesProvider =
    StreamProvider.family<List<ProcessorResponse>, String>((ref, jobId) {
  return ref.watch(siteManagerServiceProvider).watchPingResponses(jobId);
});

/// Nearest registered buyers for a byproduct type. Argument is `(type, near)`.
final nearbyBuyersProvider = FutureProvider.family<List<ByproductBuyer>,
    ({ByproductType type, GeoPoint? near})>((ref, args) {
  return ref
      .watch(siteManagerServiceProvider)
      .nearbyBuyers(args.type, args.near);
});
