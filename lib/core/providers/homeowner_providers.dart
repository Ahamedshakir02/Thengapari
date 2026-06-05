import 'package:flutter_riverpod/flutter_riverpod.dart';

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
