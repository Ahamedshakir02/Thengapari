import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/worker_profile.dart';

/// Firestore reads/writes for the Worker role. Paths match
/// docs/00_shared_architecture.md: `/users/{uid}` (shared) and `/workers/{uid}`.
class WorkerService {
  WorkerService({FirebaseFirestore? firestore, FirebaseMessaging? messaging})
      : _db = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseFirestore _db;
  final FirebaseMessaging _messaging;

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
}
