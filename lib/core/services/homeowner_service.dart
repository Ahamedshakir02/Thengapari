import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tree_inventory.dart';

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
  HomeownerService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

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
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
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
}
