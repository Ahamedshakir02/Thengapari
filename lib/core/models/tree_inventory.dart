import 'package:cloud_firestore/cloud_firestore.dart';

/// The crop/tree types a homeowner can register. [firestoreValue] is the
/// snake_case string stored in Firestore and read by the other apps, so it
/// MUST stay stable across the codebase.
enum CropType {
  coconut,
  mango,
  jackfruit,
  pepper,
  areca;

  String get label => switch (this) {
        CropType.coconut => 'Coconut',
        CropType.mango => 'Mango',
        CropType.jackfruit => 'Jackfruit',
        CropType.pepper => 'Pepper',
        CropType.areca => 'Areca nut',
      };

  String get emoji => switch (this) {
        CropType.coconut => '🥥',
        CropType.mango => '🥭',
        CropType.jackfruit => '🟢',
        CropType.pepper => '🌶️',
        CropType.areca => '🌰',
      };

  String get firestoreValue => name; // 'coconut', 'mango', ...

  static CropType? fromString(String? value) {
    for (final t in CropType.values) {
      if (t.name == value) return t;
    }
    return null;
  }
}

/// One `/homeowners/{uid}/trees/{treeId}` document — a group of trees of a
/// single [type] owned by the homeowner.
class TreeInventory {
  final String id;
  final CropType type;
  final int count;
  final int avgAgeYears;
  final DateTime? lastHarvestedAt;

  const TreeInventory({
    required this.id,
    required this.type,
    required this.count,
    required this.avgAgeYears,
    this.lastHarvestedAt,
  });

  factory TreeInventory.fromFirestore(String id, Map<String, dynamic> data) {
    return TreeInventory(
      id: id,
      type: CropType.fromString(data['type'] as String?) ?? CropType.coconut,
      count: (data['count'] as num?)?.toInt() ?? 0,
      avgAgeYears: (data['avgAgeYears'] as num?)?.toInt() ?? 0,
      lastHarvestedAt: (data['lastHarvested'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'type': type.firestoreValue,
        'count': count,
        'avgAgeYears': avgAgeYears,
        'lastHarvested':
            lastHarvestedAt == null ? null : Timestamp.fromDate(lastHarvestedAt!),
      };
}
