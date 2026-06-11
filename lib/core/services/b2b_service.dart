import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/b2b_buyer_profile.dart';
import '../models/b2b_order.dart';
import '../models/b2b_savings.dart';
import '../models/inventory_listing.dart';
import '../models/standing_order.dart';

/// Firestore / Functions I/O for the B2B buyer role. Paths match
/// docs/00_shared_architecture.md.
class B2BService {
  B2BService({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
    FirebaseFunctions? functions,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _db;
  final FirebaseMessaging _messaging;
  final FirebaseFunctions _functions;

  // ───────────────────────────── Profile / GST ─────────────────────────────

  Future<void> saveBusinessProfile({
    required String uid,
    required String ownerName,
    required String businessName,
    required BusinessType businessType,
    required String gstNumber,
    required String address,
    required String district,
    required List<B2BCrop> cropPreferences,
    String? phoneNumber,
  }) async {
    String? fcmToken;
    try {
      fcmToken = await _messaging.getToken();
    } catch (_) {
      fcmToken = null;
    }
    final trimmed = ownerName.trim();
    final sp = trimmed.indexOf(' ');
    final firstName = sp == -1 ? trimmed : trimmed.substring(0, sp);
    final lastName = sp == -1 ? null : trimmed.substring(sp + 1).trim();

    final batch = _db.batch();
    batch.set(
      _db.collection('users').doc(uid),
      {
        'firstName': firstName,
        if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
        'district': district,
        'role': 'b2b',
        'phoneNumber': ?phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.set(
      _db.collection('b2b_buyers').doc(uid),
      {
        'businessName': businessName.trim(),
        'businessType': businessType.firestoreValue,
        'gstNumber': gstNumber.trim().toUpperCase(),
        'address': address.trim(),
        'district': district,
        'verified': false,
        'cropPreferences':
            cropPreferences.map((c) => c.firestoreValue).toList(),
        'totalOrdersPlaced': 0,
        'totalSpent': 0.0,
        'totalSaved': 0.0,
        'fcmToken': ?fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Stream<B2BBuyerProfile?> watchProfile(String uid) {
    return _db.collection('b2b_buyers').doc(uid).snapshots().map((doc) =>
        doc.exists && doc.data() != null
            ? B2BBuyerProfile.fromFirestore(doc.data()!)
            : null);
  }

  // ─────────────────────────────── Inventory ───────────────────────────────

  /// All available lots, freshest first. Crop/grade/distance filtering is done
  /// client-side (see `liveInventoryProvider`) to avoid composite-index churn.
  Stream<List<InventoryListing>> watchInventory() {
    return _db
        .collection('inventory')
        .where('available', isEqualTo: true)
        .snapshots()
        .map((s) {
      final list = s.docs
          .map((d) => InventoryListing.fromFirestore(d.id, d.data()))
          .where((l) => l.quantityRemaining > 0)
          .toList();
      list.sort((a, b) => (b.harvestedAt ?? DateTime(0))
          .compareTo(a.harvestedAt ?? DateTime(0)));
      return list;
    });
  }

  Stream<InventoryListing?> watchListing(String listingId) {
    return _db.collection('inventory').doc(listingId).snapshots().map((doc) =>
        doc.exists && doc.data() != null
            ? InventoryListing.fromFirestore(doc.id, doc.data()!)
            : null);
  }

  /// Daily wholesale reference prices, keyed by crop.
  Future<Map<String, double>> marketPrices() async {
    final snap = await _db.collection('market_prices').get();
    return {
      for (final d in snap.docs)
        d.id: (d.data()['wholesalePrice'] as num?)?.toDouble() ?? 0,
    };
  }

  // ────────────────────────────── Orders ───────────────────────────────────

  /// Atomic order placement (Cloud Function): checks + decrements inventory in
  /// a transaction, creates the order, returns Razorpay details if pay-now.
  Future<Map<String, dynamic>> createB2BOrder({
    required String listingId,
    required int quantity,
    required DateTime deliveryDate,
    required String paymentMethod,
    required String buyerId,
  }) async {
    final res = await _functions.httpsCallable('createB2BOrder').call({
      'listingId': listingId,
      'quantity': quantity,
      'deliveryDate': deliveryDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'buyerId': buyerId,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  Stream<List<B2BOrder>> watchActiveOrders(String uid) {
    return _db
        .collection('b2b_orders')
        .where('buyerId', isEqualTo: uid)
        .snapshots()
        .map((s) {
      final list = s.docs
          .map((d) => B2BOrder.fromFirestore(d.id, d.data()))
          .where((o) => o.status.isActive)
          .toList();
      list.sort((a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return list;
    });
  }

  Future<List<B2BOrder>> fetchOrderHistory(String uid) async {
    final snap = await _db
        .collection('b2b_orders')
        .where('buyerId', isEqualTo: uid)
        .get();
    final list = snap.docs
        .map((d) => B2BOrder.fromFirestore(d.id, d.data()))
        .where((o) => !o.status.isActive)
        .toList();
    list.sort((a, b) =>
        (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    return list;
  }

  Stream<List<TrackingEvent>> watchOrderTracking(String orderId) {
    return _db
        .collection('b2b_orders/$orderId/tracking')
        .orderBy('timestamp')
        .snapshots()
        .map((s) =>
            s.docs.map((d) => TrackingEvent.fromFirestore(d.data())).toList());
  }

  Future<void> confirmDelivery(String orderId) async {
    await _functions.httpsCallable('confirmDelivery').call({'orderId': orderId});
  }

  Future<String> generateInvoice(String orderId) async {
    final res =
        await _functions.httpsCallable('generateInvoice').call({'orderId': orderId});
    return (res.data as Map)['invoiceUrl'] as String;
  }

  // ────────────────────────────── Savings ──────────────────────────────────

  Future<SavingsSummary> monthlySavings(String uid) async {
    final cutoff = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 30)));
    final snap = await _db
        .collection('b2b_buyers/$uid/savings')
        .where('createdAt', isGreaterThan: cutoff)
        .get();
    double totalSaved = 0, totalSpent = 0, pctSum = 0;
    final perCrop = <B2BCrop, double>{};
    for (final d in snap.docs) {
      final data = d.data();
      final saved = (data['savingsAmount'] as num?)?.toDouble() ?? 0;
      final spent = (data['platformPrice'] as num?)?.toDouble() ?? 0;
      totalSaved += saved;
      totalSpent += spent;
      pctSum += (data['savingsPercent'] as num?)?.toDouble() ?? 0;
      final crop = B2BCrop.fromString(data['cropType'] as String?);
      perCrop[crop] = (perCrop[crop] ?? 0) + saved;
    }
    final n = snap.docs.length;
    return SavingsSummary(
      totalSaved: totalSaved,
      totalSpent: totalSpent,
      orderCount: n,
      avgPercent: n == 0 ? 0 : pctSum / n,
      perCrop: perCrop,
    );
  }

  /// Delivered-order spend bucketed into the last 8 weeks (oldest → newest).
  Future<List<double>> weeklySpend(String uid) async {
    final cutoff = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 56)));
    final snap = await _db
        .collection('b2b_orders')
        .where('buyerId', isEqualTo: uid)
        .where('createdAt', isGreaterThan: cutoff)
        .get();
    final buckets = List<double>.filled(8, 0);
    final now = DateTime.now();
    for (final d in snap.docs) {
      final o = B2BOrder.fromFirestore(d.id, d.data());
      if (o.status != B2BOrderStatus.delivered || o.createdAt == null) continue;
      final weekIdx = 7 - (now.difference(o.createdAt!).inDays ~/ 7);
      if (weekIdx >= 0 && weekIdx < 8) buckets[weekIdx] += o.totalAmount;
    }
    return buckets;
  }

  // ─────────────────────────── Standing orders ─────────────────────────────

  Stream<List<StandingOrder>> watchStandingOrders(String uid) {
    return _db
        .collection('standing_orders')
        .where('buyerId', isEqualTo: uid)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => StandingOrder.fromFirestore(d.id, d.data())).toList());
  }

  Future<void> createStandingOrder({
    required String uid,
    required B2BCrop cropType,
    required String grade,
    required int quantityPerOrder,
    required StandingFrequency frequency,
    double? maxPricePer,
    required DateTime startDate,
  }) async {
    await _db.collection('standing_orders').add({
      'buyerId': uid,
      'cropType': cropType.firestoreValue,
      'grade': grade,
      'quantityPerOrder': quantityPerOrder,
      'frequency': frequency.firestoreValue,
      'maxPricePer': ?maxPricePer,
      'startDate': Timestamp.fromDate(startDate),
      'nextDue': Timestamp.fromDate(startDate),
      'active': true,
      'lastFulfilled': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
