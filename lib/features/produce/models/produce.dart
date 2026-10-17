/// Mirrors the `availability_status` type in the database.
enum AvailabilityStatus {
  available,
  low,
  unavailable;

  /// Converts the text stored in the database into an enum value.
  static AvailabilityStatus fromDb(String value) => switch (value) {
        'low' => AvailabilityStatus.low,
        'unavailable' => AvailabilityStatus.unavailable,
        _ => AvailabilityStatus.available,
      };

  /// Words shown to the user. Never colour alone, always text as well.
  String get label => switch (this) {
        AvailabilityStatus.available => 'Available',
        AvailabilityStatus.low => 'Low availability',
        AvailabilityStatus.unavailable => 'Unavailable',
      };
}

/// One row of the `active_listings` view, as a Dart object.
class Produce {
  const Produce({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.price,
    required this.isPriceNegotiable,
    required this.status,
    required this.community,
    required this.farmerName,
    this.description,
    this.imagePath,
  });

  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double? price;
  final bool isPriceNegotiable;
  final AvailabilityStatus status;
  final String community;
  final String farmerName;
  final String? description;
  final String? imagePath;

  /// "40" instead of "40.0".
  String get quantityLabel =>
      quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toString();

  /// "R12 per bunch", "R18 per head · negotiable" or "Price negotiable".
  String get priceLabel {
    final p = price;
    if (p == null) return 'Price negotiable';
    final amount = p.toStringAsFixed(p % 1 == 0 ? 0 : 2);
    return 'R$amount per $unit${isPriceNegotiable ? ' · negotiable' : ''}';
  }

  /// Builds a Produce from the map Supabase returns for one row.
  factory Produce.fromJson(Map<String, dynamic> json) => Produce(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
        price: (json['price'] as num?)?.toDouble(),
        isPriceNegotiable: json['is_price_negotiable'] as bool,
        status: AvailabilityStatus.fromDb(json['availability_status'] as String),
        community: json['community'] as String,
        farmerName: json['farmer_name'] as String,
        description: json['description'] as String?,
        imagePath: json['image_path'] as String?,
      );
}
