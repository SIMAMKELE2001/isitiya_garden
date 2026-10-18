import '../../produce/models/produce.dart';

/// One of the farmer's own listings, including the ids the edit form needs.
/// (Buyers see the slimmer `Produce`, read from the `active_listings` view.)
class FarmerListing {
  const FarmerListing({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    this.description,
    required this.quantity,
    required this.unitId,
    required this.unitName,
    this.price,
    required this.isPriceNegotiable,
    required this.status,
    this.availableFrom,
    this.availableUntil,
    required this.communityId,
    required this.communityName,
    this.locationNote,
    this.imagePath,
    required this.isActive,
    this.buyerTypeIds = const [],
  });

  final String id;
  final String name;
  final int categoryId;
  final String categoryName;
  final String? description;
  final double quantity;
  final int unitId;
  final String unitName;
  final double? price;
  final bool isPriceNegotiable;
  final AvailabilityStatus status;
  final DateTime? availableFrom;
  final DateTime? availableUntil;
  final int communityId;
  final String communityName;
  final String? locationNote;
  final String? imagePath;
  final bool isActive;
  final List<int> buyerTypeIds;

  /// True when buyers can currently see this listing (NFR10).
  bool get isVisibleToBuyers =>
      isActive && status != AvailabilityStatus.unavailable;

  String get quantityLabel =>
      quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toString();

  String get priceLabel {
    final p = price;
    if (p == null) return 'Price negotiable';
    final amount = p.toStringAsFixed(p % 1 == 0 ? 0 : 2);
    return 'R$amount per $unitName${isPriceNegotiable ? ' · negotiable' : ''}';
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  factory FarmerListing.fromJson(Map<String, dynamic> json) {
    final category = json['categories'] as Map<String, dynamic>?;
    final unit = json['units'] as Map<String, dynamic>?;
    final community = json['communities'] as Map<String, dynamic>?;
    final types = json['listing_buyer_types'] as List<dynamic>? ?? const [];

    return FarmerListing(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['category_id'] as int,
      categoryName: category?['name'] as String? ?? '',
      description: json['description'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unitId: json['unit_id'] as int,
      unitName: unit?['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
      isPriceNegotiable: json['is_price_negotiable'] as bool,
      status: AvailabilityStatus.fromDb(json['availability_status'] as String),
      availableFrom: _date(json['available_from']),
      availableUntil: _date(json['available_until']),
      communityId: json['community_id'] as int,
      communityName: community?['name'] as String? ?? '',
      locationNote: json['location_note'] as String?,
      imagePath: json['image_path'] as String?,
      isActive: json['is_active'] as bool,
      buyerTypeIds: [
        for (final t in types)
          (t as Map<String, dynamic>)['buyer_type_id'] as int,
      ],
    );
  }
}

/// What the Add / Edit form collects, ready to be saved.
class ListingInput {
  const ListingInput({
    required this.name,
    required this.categoryId,
    this.description,
    required this.quantity,
    required this.unitId,
    this.price,
    required this.isPriceNegotiable,
    required this.status,
    required this.availableFrom,
    this.availableUntil,
    required this.communityId,
    this.locationNote,
    this.imagePath,
    required this.buyerTypeIds,
  });

  final String name;
  final int categoryId;
  final String? description;
  final double quantity;
  final int unitId;
  final double? price;
  final bool isPriceNegotiable;
  final AvailabilityStatus status;
  final DateTime availableFrom;
  final DateTime? availableUntil;
  final int communityId;
  final String? locationNote;
  final String? imagePath;
  final Set<int> buyerTypeIds;

  static String _day(DateTime d) => d.toIso8601String().substring(0, 10);

  /// The database columns for this listing (the buyer types go in their
  /// own table, so they are not part of this map).
  Map<String, dynamic> toRow() => {
    'name': name.trim(),
    'category_id': categoryId,
    'description': description,
    'quantity': quantity,
    'unit_id': unitId,
    'price': price,
    'is_price_negotiable': isPriceNegotiable,
    'availability_status': status.name,
    'available_from': _day(availableFrom),
    'available_until': availableUntil == null ? null : _day(availableUntil!),
    'community_id': communityId,
    'location_note': locationNote,
    'image_path': imagePath,
  };
}

/// The farmer-only profile details (FR04).
class FarmerDetails {
  const FarmerDetails({
    required this.farmName,
    this.whatsappNumber,
    this.about,
  });

  final String farmName;
  final String? whatsappNumber;
  final String? about;

  factory FarmerDetails.fromJson(Map<String, dynamic> json) => FarmerDetails(
    farmName: json['farm_name'] as String,
    whatsappNumber: json['whatsapp_number'] as String?,
    about: json['about'] as String?,
  );
}
