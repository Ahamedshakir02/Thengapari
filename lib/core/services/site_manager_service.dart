import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/byproduct.dart';
import '../models/harvest_job.dart';
import '../models/job_step.dart';
import '../models/processor_response.dart';
import '../models/site_manager_profile.dart';
import '../models/yield_data.dart';

/// Firestore / Functions reads + writes for the Site Manager role. Every path
/// matches docs/00_shared_architecture.md so the four apps stay compatible.
class SiteManagerService {
  SiteManagerService({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
    FirebaseFunctions? functions,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _db;
  final FirebaseMessaging _messaging;
  final FirebaseFunctions _functions;

  // ─────────────────────────── Profile / verification ──────────────────────

  /// First-time setup: shared `/users/{uid}` (role: site_manager) +
  /// `/site_managers/{uid}` with `verified: false` (admin flips it true).
  Future<void> saveProfileSetup({
    required String uid,
    required String name,
    required String district,
    required String collegeName,
    required String rollNumber,
    required CollegeBranch branch,
    required YearOfStudy yearOfStudy,
    GeoPoint? operatingZone,
    String? idDocUrl,
    String? phoneNumber,
  }) async {
    final trimmed = name.trim();
    final sp = trimmed.indexOf(' ');
    final firstName = sp == -1 ? trimmed : trimmed.substring(0, sp);
    final lastName = sp == -1 ? null : trimmed.substring(sp + 1).trim();

    String? fcmToken;
    try {
      fcmToken = await _messaging.getToken();
    } catch (_) {
      fcmToken = null;
    }

    final batch = _db.batch();
    batch.set(
      _db.collection('users').doc(uid),
      {
        'firstName': firstName,
        if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
        'district': district,
        'role': 'site_manager',
        'phoneNumber': ?phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.set(
      _db.collection('site_managers').doc(uid),
      {
        'collegeName': collegeName.trim(),
        'rollNumber': rollNumber.trim(),
        'branch': branch.firestoreValue,
        'yearOfStudy': yearOfStudy.number,
        'verified': false,
        'rating': 0.0,
        'jobsCompleted': 0,
        'currentJobId': null,
        'trainingComplete': false,
        'operatingZone': ?operatingZone,
        'idDocUrl': ?idDocUrl,
        'fcmToken': ?fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  /// Live `/site_managers/{uid}` profile.
  Stream<SiteManagerProfile?> watchProfile(String uid) {
    return _db.collection('site_managers').doc(uid).snapshots().map((doc) =>
        doc.exists && doc.data() != null
            ? SiteManagerProfile.fromFirestore(doc.data()!)
            : null);
  }

  // ─────────────────────────────── Daily queue ─────────────────────────────

  /// Today's assigned jobs, sorted by scheduled time.
  Stream<List<HarvestJob>> watchTodayJobs(String uid) {
    final now = DateTime.now();
    final start = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final end =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day + 1));
    return _db
        .collection('jobs')
        .where('siteManagerId', isEqualTo: uid)
        .where('scheduledAt', isGreaterThanOrEqualTo: start)
        .where('scheduledAt', isLessThan: end)
        .orderBy('scheduledAt')
        .snapshots()
        .map((s) => s.docs
            .map((d) => HarvestJob.fromFirestore(d.id, d.data()))
            .toList());
  }

  // ─────────────────────────── Checklist / status ──────────────────────────

  /// Live derived checklist for [jobId]. Builds the ordered step list from the
  /// completed `/jobs/{jobId}/statusUpdates` events (sequential unlock).
  Stream<List<JobStep>> watchSteps(String jobId) {
    return _db
        .collection('jobs/$jobId/statusUpdates')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) {
      final completed = <String, DateTime?>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final id = (data['type'] ?? data['step']) as String?;
        if (id == null) continue;
        completed[id] = (data['createdAt'] as Timestamp?)?.toDate();
      }
      return buildJobSteps(completed);
    });
  }

  /// Check in at the site: writes the `arrived` status event and flips the job
  /// to `in_progress`. The Homeowner live tracker reads `title` + `createdAt`.
  Future<void> checkIn({
    required String jobId,
    required String uid,
    required GeoPoint location,
  }) async {
    await completeStep(
      jobId: jobId,
      uid: uid,
      kind: ManagerStepKind.arrived,
      location: location,
      jobStatus: 'in_progress',
      extraJobFields: {'checkInAt': FieldValue.serverTimestamp()},
    );
  }

  /// Write a `/jobs/{jobId}/statusUpdates` event for a completed checklist step
  /// and (optionally) advance the parent job's `status`.
  Future<void> completeStep({
    required String jobId,
    required String uid,
    required ManagerStepKind kind,
    String? note,
    String? photoUrl,
    GeoPoint? location,
    String? jobStatus,
    Map<String, Object?> extraJobFields = const {},
  }) async {
    await _db.collection('jobs/$jobId/statusUpdates').add({
      'type': kind.id,
      'step': kind.id,
      // `title` + `createdAt` are what the Homeowner live tracker reads.
      'title': kind.label,
      'note': ?note,
      'photoUrl': ?photoUrl,
      'location': ?location,
      'siteManagerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    if (jobStatus != null || extraJobFields.isNotEmpty) {
      await _db.collection('jobs').doc(jobId).update({
        if (jobStatus != null) 'status': jobStatus,
        ...extraJobFields,
      });
    }
  }

  // ─────────────────────────────── Yield data ──────────────────────────────

  Stream<YieldData?> watchYield(String jobId) {
    return _db
        .doc('jobs/$jobId/yieldData/current')
        .snapshots()
        .map((doc) => doc.exists && doc.data() != null
            ? YieldData.fromFirestore(doc.data()!)
            : null);
  }

  /// Save weighed yield to `/jobs/{jobId}/yieldData/current` (merge) and mirror
  /// the summary onto the parent job for the Homeowner live weight card.
  Future<void> saveYield({
    required String jobId,
    required String uid,
    required double totalKg,
    required int gradeA,
    required int gradeB,
    required int tender,
    String? scalePhotoUrl,
  }) async {
    final estimatedValue =
        YieldData.estimate(gradeA, gradeB, tender).toDouble();
    await _db.doc('jobs/$jobId/yieldData/current').set({
      'totalKg': totalKg,
      'gradeA': gradeA,
      'gradeB': gradeB,
      'tender': tender,
      'estimatedValue': estimatedValue,
      'scalePhotoUrl': ?scalePhotoUrl,
      'loggedAt': FieldValue.serverTimestamp(),
      'loggedBy': uid,
    }, SetOptions(merge: true));

    await _db.collection('jobs').doc(jobId).update({
      'actualYieldKg': totalKg,
      'currentYieldKg': totalKg,
      'gradeA': gradeA,
      'gradeB': gradeB,
      'tender': tender,
    });
  }

  // ───────────────────────────── Broadcast ping ────────────────────────────

  /// Fan out an FCM ping to nearby processors (Cloud Function).
  Future<void> broadcastProcessorPing({
    required String jobId,
    required String cropType,
    required double yieldKg,
    required double lat,
    required double lng,
    double radiusKm = 5,
  }) async {
    await _functions.httpsCallable('broadcastProcessorPing').call({
      'jobId': jobId,
      'cropType': cropType,
      'yieldKg': yieldKg,
      'location': {'lat': lat, 'lng': lng},
      'radiusKm': radiusKm,
      'requiredSkill': 'husker',
    });
  }

  /// Live worker Accept responses for a broadcast.
  Stream<List<ProcessorResponse>> watchPingResponses(String jobId) {
    return _db
        .collection('job_pings')
        .where('jobId', isEqualTo: jobId)
        .where('status', whereIn: ['accepted', 'assigned'])
        .snapshots()
        .map((s) => s.docs
            .map((d) => ProcessorResponse.fromFirestore(d.id, d.data()))
            .toList());
  }

  /// Assign a responding processor (first-come, manual override allowed).
  Future<void> assignProcessor({
    required String jobId,
    required String pingId,
    required String workerId,
  }) async {
    final batch = _db.batch();
    batch.update(_db.collection('job_pings').doc(pingId), {
      'status': 'assigned',
      'assignedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_db.collection('jobs').doc(jobId), {
      'workerIds': FieldValue.arrayUnion([workerId]),
      'status': 'processing',
    });
    await batch.commit();
  }

  // ───────────────────────────── Byproducts ────────────────────────────────

  /// Registered buyers accepting [type], nearest-first relative to [near].
  Future<List<ByproductBuyer>> nearbyBuyers(
      ByproductType type, GeoPoint? near) async {
    final snap = await _db
        .collection('byproduct_buyers')
        .where('acceptsTypes', arrayContains: type.firestoreValue)
        .get();
    final buyers =
        snap.docs.map((d) => ByproductBuyer.fromFirestore(d.id, d.data())).toList();
    buyers.sort((a, b) =>
        a.distanceKmFrom(near).compareTo(b.distanceKmFrom(near)));
    return buyers;
  }

  /// Write one routing record per byproduct → buyer assignment.
  Future<void> routeByproducts({
    required String jobId,
    required List<ByproductRoute> routes,
    GeoPoint? buyerLocation,
  }) async {
    final batch = _db.batch();
    for (final r in routes) {
      batch.set(_db.collection('byproduct_routes').doc(), {
        'jobId': jobId,
        'byproductType': r.type.firestoreValue,
        'weightKg': r.weightKg,
        'buyerId': r.buyerId,
        'buyerName': r.buyerName,
        'buyerLocation': ?buyerLocation,
        'routedAt': FieldValue.serverTimestamp(),
        'status': 'scheduled_pickup',
      });
    }
    batch.update(_db.collection('jobs').doc(jobId), {
      'status': 'byproducts_routed',
    });
    await batch.commit();
  }

  // ───────────────────────────── Report / complete ─────────────────────────

  /// Generate the homeowner PDF (Cloud Function) and return its Storage URL.
  Future<String> generateHarvestReport(String jobId) async {
    final res =
        await _functions.httpsCallable('generateHarvestReport').call({
      'jobId': jobId,
    });
    return (res.data as Map)['pdfUrl'] as String;
  }

  /// Mark the job complete — triggers payouts + the homeowner notification.
  Future<void> markJobComplete({
    required String jobId,
    required String reportUrl,
  }) async {
    await _functions.httpsCallable('markJobComplete').call({
      'jobId': jobId,
      'reportUrl': reportUrl,
    });
  }
}
