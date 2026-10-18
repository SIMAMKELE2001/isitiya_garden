import 'package:flutter_test/flutter_test.dart';
import 'package:isitiya_garden/features/produce/models/produce.dart';

Map<String, dynamic> sample({
  Object? price = 12,
  bool negotiable = false,
  Object quantity = 40,
  String status = 'available',
}) => {
  'id': '1',
  'name': 'Fresh spinach',
  'category': 'Vegetables',
  'quantity': quantity,
  'unit': 'bunch',
  'price': price,
  'is_price_negotiable': negotiable,
  'availability_status': status,
  'community': 'Qunu',
  'farmer_name': 'Nomsa Mbatha',
  'buyer_types': ['Household', 'Spaza shop'],
  'available_from': '2026-10-15',
  'created_at': '2026-10-15T10:00:00+00:00',
};

void main() {
  group('Produce.fromJson', () {
    test('reads the fields of an active_listings row', () {
      final p = Produce.fromJson(sample());
      expect(p.name, 'Fresh spinach');
      expect(p.farmerName, 'Nomsa Mbatha');
      expect(p.community, 'Qunu');
      expect(p.status, AvailabilityStatus.available);
      expect(p.buyerTypes, ['Household', 'Spaza shop']);
      expect(p.availableFrom, DateTime(2026, 10, 15));
      expect(p.createdAt, isNotNull);
    });

    test('copes with missing optional fields', () {
      final json = sample()
        ..remove('buyer_types')
        ..remove('available_from');
      final p = Produce.fromJson(json);
      expect(p.buyerTypes, isEmpty);
      expect(p.availableFrom, isNull);
      expect(p.description, isNull);
    });

    test('maps the status text from the database', () {
      expect(
        Produce.fromJson(sample(status: 'low')).status,
        AvailabilityStatus.low,
      );
      expect(
        Produce.fromJson(sample(status: 'unavailable')).status,
        AvailabilityStatus.unavailable,
      );
    });
  });

  group('Produce labels', () {
    test('price label for a fixed price', () {
      expect(Produce.fromJson(sample()).priceLabel, 'R12 per bunch');
    });
    test('price label with cents', () {
      expect(
        Produce.fromJson(sample(price: 12.5)).priceLabel,
        'R12.50 per bunch',
      );
    });
    test('price label when negotiable', () {
      expect(
        Produce.fromJson(sample(negotiable: true)).priceLabel,
        'R12 per bunch · negotiable',
      );
    });
    test('price label when there is no price', () {
      expect(
        Produce.fromJson(sample(price: null, negotiable: true)).priceLabel,
        'Price negotiable',
      );
    });
    test('quantity label drops a useless .0', () {
      expect(Produce.fromJson(sample()).quantityLabel, '40');
      expect(Produce.fromJson(sample(quantity: 2.5)).quantityLabel, '2.5');
    });
  });

  group('AvailabilityStatus labels use words, not only colour', () {
    test('labels', () {
      expect(AvailabilityStatus.available.label, 'Available');
      expect(AvailabilityStatus.low.label, 'Low availability');
      expect(AvailabilityStatus.unavailable.label, 'Unavailable');
    });
  });
}
