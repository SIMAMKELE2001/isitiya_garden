import 'package:flutter_test/flutter_test.dart';
import 'package:isitiya_garden/features/farmer/data/listing_validators.dart';

void main() {
  group('ListingValidators.parseNumber', () {
    test('understands a decimal comma and a decimal point', () {
      expect(ListingValidators.parseNumber('12,5'), 12.5);
      expect(ListingValidators.parseNumber('12.5'), 12.5);
      expect(ListingValidators.parseNumber(' 20 '), 20);
    });
    test('returns null for text', () {
      expect(ListingValidators.parseNumber('abc'), isNull);
      expect(ListingValidators.parseNumber(null), isNull);
    });
  });

  group('ListingValidators.quantity', () {
    test('must be above zero', () {
      expect(ListingValidators.quantity(''), isNotNull);
      expect(ListingValidators.quantity('0'), isNotNull);
      expect(ListingValidators.quantity('-3'), isNotNull);
      expect(ListingValidators.quantity('abc'), isNotNull);
      expect(ListingValidators.quantity('20'), isNull);
      expect(ListingValidators.quantity('2,5'), isNull);
    });
  });

  group('ListingValidators.price (FR09)', () {
    test('is required when the price is not negotiable', () {
      expect(ListingValidators.price('', isRequired: true), isNotNull);
    });
    test('may be empty when the price is negotiable', () {
      expect(ListingValidators.price('', isRequired: false), isNull);
    });
    test('rejects negative and non-numeric prices', () {
      expect(ListingValidators.price('-5', isRequired: false), isNotNull);
      expect(ListingValidators.price('abc', isRequired: false), isNotNull);
    });
    test('accepts normal prices', () {
      expect(ListingValidators.price('12', isRequired: true), isNull);
      expect(ListingValidators.price('12.50', isRequired: true), isNull);
      expect(ListingValidators.price('0', isRequired: true), isNull);
    });
  });

  group('ListingValidators.name', () {
    test('needs two letters', () {
      expect(ListingValidators.name(''), isNotNull);
      expect(ListingValidators.name('A'), isNotNull);
      expect(ListingValidators.name('Spinach'), isNull);
    });
  });

  group('Length limits match the database', () {
    test('description 600, note 120, about 500', () {
      expect(ListingValidators.description('a' * 600), isNull);
      expect(ListingValidators.description('a' * 601), isNotNull);
      expect(ListingValidators.locationNote('a' * 120), isNull);
      expect(ListingValidators.locationNote('a' * 121), isNotNull);
      expect(ListingValidators.about('a' * 500), isNull);
      expect(ListingValidators.about('a' * 501), isNotNull);
    });
  });
}
