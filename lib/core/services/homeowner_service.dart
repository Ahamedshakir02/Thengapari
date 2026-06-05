import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/harvest_job.dart';
import '../models/tree_inventory.dart';
import '../models/yield_estimate.dart';

/// A single tree group the user is about to save during setup (no id yet).
class TreeDraft {
  final CropType type;
  final int count;
  final int avgAgeYears;

  const TreeDraft({
    required this.type,
    required this.count,
    this.avgAgeYears = 0,
  });
}

/// Firestore reads/writes for the Homeowner role.
///
/// Collection paths match `docs/00_shared_architecture.md` exactly so the
/// Worker / Site Manager / B2B apps stay compatible:
///   /users/{uid}                     shared profile doc
///   /homeowners/{uid}                homeowner-specific doc (address)
///   /homeowners/{uid}/trees/{id}     tree inventory
class HomeownerService {
  HomeownerService({FirebaseFirestore? firestore, FirebaseFunctions? functions})
      : _db = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  /// Writes the shared `/users/{uid}` profile and the homeowner doc.
  ///
  /// Name is split into first/last to match the existing [AppUser] model
  /// (firstName/lastName), which all four apps read. `role: 'homeowner'` is
  /// what flips role-based routing to the homeowner app.
  Future<void> saveProfile({
    required String uid,
    required String name,
    required String district,
    required String address,
    String? phoneNumber,
  }) async {
    final trimmed = name.trim();
    final spaceIdx = trimmed.indexOf(' ');
    final firstName = spaceIdx == -1 ? trimmed : trimmed.substring(0, spaceIdx);
    final lastName =
        spaceIdx == -1 ? null : trimmed.substring(spaceIdx + 1).trim();

    final batch = _db.batch();

    batch.set(
      _db.collection('users').doc(uid),
      {
        'firstName': firstName,
        if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
        'district': district,
        'role': 'homeowner',
        'phoneNumber': ?phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      _db.collection('homeowners').doc(uid),
      {
        'address': address.trim(),
        'district': district,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Batch-writes the homeowner's initial tree inventory. Trees with count 0
  /// are skipped.
  Future<void> saveTrees({
    required String uid,
    required List<TreeDraft> trees,
  }) async {
    final treesCol = _db.collection('homeowners').doc(uid).collection('trees');
    final batch = _db.batch();
    for (final tree in trees) {
      if (tree.count <= 0) continue;
      batch.set(treesCol.doc(), {
        'type': tree.type.firestoreValue,
        'count': tree.count,
        'avgAgeYears': tree.avgAgeYears,
        'lastHarvested': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Live stream of the homeowner's tree inventory.
  Stream<List<TreeInventory>> watchTrees(String uid) {
    return _db
        .collection('homeowners')
        .doc(uid)
        .collection('trees')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TreeInventory.fromFirestore(d.id, d.data()))
            .toList());
  }

  /// Live stream of every job for this homeowner. We filter/aggregate
  /// client-side (active job, earnings) to avoid composite-index requirements
  /// on `/jobs`.
  Stream<List<HarvestJob>> watchHomeownerJobs(String uid) {
    return _db
        .collection('jobs')
        .where('homeownerId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => HarvestJob.fromFirestore(d.id, d.data()))
            .toList());
  }

  /// One-shot fetch of this homeowner's jobs (for earnings aggregation).
  Future<List<HarvestJob>> fetchHomeownerJobs(String uid) async {
    final snap = await _db
        .collection('jobs')
        .where('homeownerId', isEqualTo: uid)
        .get();
    return snap.docs
        .map((d) => HarvestJob.fromFirestore(d.id, d.data()))
        .toList();
  }

  /// Pre-booking price preview. Calls the `calculateYieldEstimate` Cloud
  /// Function; if it isn't deployed/reachable, falls back to a local estimate
  /// from the per-crop yield/rate constants so booking still works.
  Future<YieldEstimate> calculateYieldEstimate({
    required Map<CropType, int> treeCounts,
    required String district,
    required bool ripeOnly,
  }) async {
    final factor = ripeOnly ? 0.6 : 1.0;
    try {
      final res =
          await _functions.httpsCallable('calculateYieldEstimate').call({
        'cropTypes': treeCounts.keys.map((c) => c.firestoreValue).toList(),
        'treeCounts': {
          for (final e in treeCounts.entries) e.key.firestoreValue: e.value
        },
        'district': district,
        'ripeOnly': ripeOnly,
      });
      final data = Map<String, dynamic>.from(res.data as Map);
      return YieldEstimate(
        estimatedKg: (data['estimatedKg'] as num).toDouble(),
        estimatedEarning: (data['estimatedEarning'] as num).toDouble(),
        marketRate: (data['marketRate'] as num?)?.toDouble() ?? 0,
      );
    } catch (_) {
      // Local fallback.
      double kg = 0, earning = 0;
      for (final entry in treeCounts.entries) {
        final cropKg = entry.value * entry.key.kgPerTree * factor;
        kg += cropKg;
        earning += cropKg * entry.key.ratePerKg;
      }
      return YieldEstimate(
        estimatedKg: kg,
        estimatedEarning: earning,
        marketRate: kg == 0 ? 0 : earning / kg,
      );
    }
  }

  /// Creates a `/jobs/{id}` document and returns its id. Status starts at
  /// `pending`; the `onJobCreate` Cloud Function assigns a site manager.
  Future<String> createJob({
    required String uid,
    required List<CropType> crops,
    required DateTime scheduledAt,
    required double estimatedYieldKg,
    required String district,
    String notes = '',
    GeoPoint? location,
  }) async {
    final doc = _db.collection('jobs').doc();
    await doc.set({
      'homeownerId': uid,
      'cropTypes': crops.map((c) => c.firestoreValue).toList(),
      'status': 'pending',
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'estimatedYieldKg': estimatedYieldKg,
      'district': district,
      'notes': notes,
      'location': ?location,
      'workerIds': <String>[],
      'paymentStatus': 'unpaid',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }
}
