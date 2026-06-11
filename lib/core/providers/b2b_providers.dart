import 'package:flutter_riverpod/flutter_riverpod.dart';
// StateProvider lives in the legacy export in Riverpod 3.x.
import 'package:flutter_riverpod/legacy.dart';

import '../models/b2b_buyer_profile.dart';
import '../models/b2b_order.dart';
import '../models/b2b_savings.dart';
import '../models/inventory_listing.dart';
import '../models/standing_order.dart';
import '../services/b2b_service.dart';

/// Crop / grade / distance filter for the live inventory list. A record so
/// Riverpod families key on it by value.
typedef InventoryFilter = ({B2BCrop? crop, String? grade, double? maxKm});

const InventoryFilter kNoFilter = (crop: null, grade: null, maxKm: null);

final b2bServiceProvider = Provider<B2BService>((ref) => B2BService());

/// Selected bottom-nav tab (0 = Market, 1 = Orders, 2 = Savings).
final b2bTabProvider = StateProvider<int>((ref) => 0);

final b2bProfileProvider =
    StreamProvider.family<B2BBuyerProfile?, String>((ref, uid) {
  return ref.watch(b2bServiceProvider).watchProfile(uid);
});

/// Raw available-inventory stream (unfiltered).
final inventoryStreamProvider =
    StreamProvider<List<InventoryListing>>((ref) {
  return ref.watch(b2bServiceProvider).watchInventory();
});

/// Filtered + best-savings-sorted inventory for the market screen.
final liveInventoryProvider =
    Provider.family<AsyncValue<List<InventoryListing>>, InventoryFilter>(
        (ref, filter) {
  return ref.watch(inventoryStreamProvider).whenData((all) {
    final list = all.where((l) {
      if (filter.crop != null && l.cropType != filter.crop) return false;
      if (filter.grade != null && l.grade != filter.grade) return false;
      if (filter.maxKm != null &&
          l.distanceKm != null &&
          l.distanceKm! > filter.maxKm!) {
        return false;
      }
      return true;
    }).toList();
    list.sort((a, b) => b.savingsPercent.compareTo(a.savingsPercent));
    return list;
  });
});

final listingDetailProvider =
    StreamProvider.family<InventoryListing?, String>((ref, id) {
  return ref.watch(b2bServiceProvider).watchListing(id);
});

final activeOrdersProvider =
    StreamProvider.family<List<B2BOrder>, String>((ref, uid) {
  return ref.watch(b2bServiceProvider).watchActiveOrders(uid);
});

final orderHistoryProvider =
    FutureProvider.family<List<B2BOrder>, String>((ref, uid) {
  return ref.watch(b2bServiceProvider).fetchOrderHistory(uid);
});

final orderTrackingProvider =
    StreamProvider.family<List<TrackingEvent>, String>((ref, orderId) {
  return ref.watch(b2bServiceProvider).watchOrderTracking(orderId);
});

final monthlySavingsProvider =
    FutureProvider.family<SavingsSummary, String>((ref, uid) {
  return ref.watch(b2bServiceProvider).monthlySavings(uid);
});

final weeklySpendProvider =
    FutureProvider.family<List<double>, String>((ref, uid) {
  return ref.watch(b2bServiceProvider).weeklySpend(uid);
});

final standingOrdersProvider =
    StreamProvider.family<List<StandingOrder>, String>((ref, uid) {
  return ref.watch(b2bServiceProvider).watchStandingOrders(uid);
});

final marketPricesProvider = FutureProvider<Map<String, double>>((ref) {
  return ref.watch(b2bServiceProvider).marketPrices();
});
