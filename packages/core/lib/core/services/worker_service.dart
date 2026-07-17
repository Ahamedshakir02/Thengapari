import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';

import '../models/earning_record.dart';
import '../models/harvest_job.dart';
import '../models/job_ping.dart';
import '../models/worker_profile.dart';

/// Firestore reads/writes for the Worker role. Paths match
/// docs/00_shared_architecture.md: `/users/{uid}` (shared), `/workers/{uid}`,
/// `/job_pings` and the shared `/jobs` collection.
class WorkerService {
  WorkerService({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
    FirebaseFunctions? functions,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _db;
  final FirebaseMessaging _messaging;
  final FirebaseFunctions _functions;

  /// First-time worker setup: shared profile (`role: 'worker'`) + the
  /// `/workers/{uid}` doc with skills, UPI VPA, FCM token, and starting stats.
  Future<void> saveWorkerSetup({
    required String uid,
    required String name,
    required String district,
    required List<WorkerSkill> skills,
    required String upiVpa,
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
        'role': 'worker',
        'phoneNumber': ?phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.set(
      _db.collection('workers').doc(uid),
      {
        'skills': skills.map((s) => s.firestoreValue).toList(),
        'upiVpa': upiVpa.trim(),
        'isOnline': false,
        'reliabilityScore': 100.0,
        'fcmToken': ?fcmToken,
        'totalJobsCompleted': 0,
        'totalEarned': 0.0,
        'location': null,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  /// Live `/workers/{uid}` profile.
  Stream<WorkerProfile?> watchWorker(String uid) {
    return _db.collection('workers').doc(uid).snapshots().map((doc) =>
        doc.exists && doc.data() != null
            ? WorkerProfile.fromFirestore(doc.data()!)
            : null);
  }

  /// Availability toggle (used by the Worker home screen in step 2).
  Future<void> setOnline(String uid, bool online) async {
    await _db.collection('workers').doc(uid).set({
      'isOnline': online,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ─────────────────────────── Job pings ───────────────────────────

  /// The newest still-valid pending ping targeted at this worker, or null.
  /// Drives the full-screen JobPingScreen takeover.
  Stream<JobPing?> watchPendingPing(String uid) {
    return _db
        .collection('job_pings')
        .where('workerId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((s) {
      for (final d in s.docs) {
        final ping = JobPing.fromFirestore(d.id, d.data());
        if (!ping.isExpired) return ping;
      }
      return null;
    });
  }

  /// Accept a ping via the atomic `acceptPing` Cloud Function (transactional —
  /// exactly one worker wins the job). Returns the jobId on success.
  Future<String> acceptPing(String pingId) async {
    final res =
        await _functions.httpsCallable('acceptPing').call({'pingId': pingId});
    return (res.data as Map)['jobId'] as String? ?? '';
  }

  /// Decline a ping (direct write — rules allow the targeted worker to set
  /// status to 'declined').
  Future<void> declinePing(String pingId) async {
    await _db
        .collection('job_pings')
        .doc(pingId)
        .update({'status': 'declined'});
  }

  // ──────────────────────── Jobs + earnings ────────────────────────

  /// Jobs this worker is assigned to with today's schedule (confirmed list on
  /// the home screen).
  Stream<List<HarvestJob>> watchTodayAssignedJobs(String uid) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _db
        .collection('jobs')
        .where('workerIds', arrayContains: uid)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('scheduledAt')
        .snapshots()
        .map((s) => s.docs
            .map((d) => HarvestJob.fromFirestore(d.id, d.data()))
            .toList());
  }

  /// Live `/jobs/{jobId}` document (readable once this worker is assigned).
  Stream<HarvestJob?> watchJob(String jobId) {
    return _db.collection('jobs').doc(jobId).snapshots().map((d) =>
        d.exists && d.data() != null
            ? HarvestJob.fromFirestore(d.id, d.data()!)
            : null);
  }

  /// Earnings records since [since] (drives day stats + the weekly chart).
  Stream<List<EarningRecord>> watchEarningsSince(String uid, DateTime since) {
    return _db
        .collection('workers/$uid/earnings')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs
            .map((d) => EarningRecord.fromFirestore(d.id, d.data()))
            .toList());
  }

  // ─────────────────────────── Location ───────────────────────────

  /// One-shot: store the worker's current position on `/workers/{uid}` so the
  /// ping fan-out can compute distances. Silently no-ops if permission is
  /// denied or location is unavailable — going online must never crash.
  Future<void> syncLocation(String uid) async {
    try {
      final pos = await _currentPosition();
      if (pos == null) return;
      await _db.collection('workers').doc(uid).set({
        'location': GeoPoint(pos.latitude, pos.longitude),
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {/* best-effort */}
  }

  /// Continuous positions while travelling to a job (25 m granularity).
  Stream<GeoPoint> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
      ),
    ).map((p) => GeoPoint(p.latitude, p.longitude));
  }

  /// Append a live-location breadcrumb to `/jobs/{jobId}/tracking` so the
  /// homeowner map can follow the worker en route.
  Future<void> writeTrackingPoint(String jobId, GeoPoint point) async {
    await _db.collection('jobs/$jobId/tracking').add({
      'type': 'worker_location',
      'location': point,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<Position?> _currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    return Geolocator.getCurrentPosition();
  }
}
