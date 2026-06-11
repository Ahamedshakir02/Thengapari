import 'inventory_listing.dart';

/// Business categories a B2B buyer can register as.
enum BusinessType {
  juiceStall,
  bakery,
  chipsManufacturer,
  spiceTrader,
  coirFactory,
  dairyFarm,
  restaurant,
  other;

  String get label => switch (this) {
        BusinessType.juiceStall => 'Juice stall',
        BusinessType.bakery => 'Bakery',
        BusinessType.chipsManufacturer => 'Chips manufacturer',
        BusinessType.spiceTrader => 'Spice trader',
        BusinessType.coirFactory => 'Coir factory',
        BusinessType.dairyFarm => 'Dairy farm',
        BusinessType.restaurant => 'Restaurant',
        BusinessType.other => 'Other',
      };

  String get firestoreValue => switch (this) {
        BusinessType.juiceStall => 'juice_stall',
        BusinessType.bakery => 'bakery',
        BusinessType.chipsManufacturer => 'chips_manufacturer',
        BusinessType.spiceTrader => 'spice_trader',
        BusinessType.coirFactory => 'coir_factory',
        BusinessType.dairyFarm => 'dairy_farm',
        BusinessType.restaurant => 'restaurant',
        BusinessType.other => 'other',
      };

  static BusinessType? fromString(String? v) {
    for (final t in BusinessType.values) {
      if (t.firestoreValue == v) return t;
    }
    return null;
  }
}

/// `/b2b_buyers/{uid}` document.
class B2BBuyerProfile {
  /// 15-character GSTIN format (e.g. `32AABCR1234F1Z5`).
  static final RegExp gstPattern = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');

  static bool isValidGst(String v) => gstPattern.hasMatch(v.trim().toUpperCase());

  final String businessName;
  final BusinessType? businessType;
  final String gstNumber;
  final String address;
  final String district;
  final bool verified;
  final List<B2BCrop> cropPreferences;
  final int totalOrdersPlaced;
  final double totalSpent;
  final double totalSaved;

  const B2BBuyerProfile({
    this.businessName = '',
    this.businessType,
    this.gstNumber = '',
    this.address = '',
    this.district = '',
    this.verified = false,
    this.cropPreferences = const [],
    this.totalOrdersPlaced = 0,
    this.totalSpent = 0,
    this.totalSaved = 0,
  });

  bool get isSetUp => businessName.isNotEmpty && gstNumber.isNotEmpty;

  factory B2BBuyerProfile.fromFirestore(Map<String, dynamic> data) {
    return B2BBuyerProfile(
      businessName: data['businessName'] as String? ?? '',
      businessType: BusinessType.fromString(data['businessType'] as String?),
      gstNumber: data['gstNumber'] as String? ?? '',
      address: data['address'] as String? ?? '',
      district: data['district'] as String? ?? '',
      verified: data['verified'] as bool? ?? false,
      cropPreferences: ((data['cropPreferences'] as List?) ?? const [])
          .map((e) => B2BCrop.fromString(e.toString()))
          .toList(),
      totalOrdersPlaced: (data['totalOrdersPlaced'] as num?)?.toInt() ?? 0,
      totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0,
      totalSaved: (data['totalSaved'] as num?)?.toDouble() ?? 0,
    );
  }
}
