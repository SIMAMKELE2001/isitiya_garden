import 'package:flutter_test/flutter_test.dart';
import 'package:isitiya_garden/features/location/models/location_models.dart';
import 'package:isitiya_garden/features/produce/models/produce.dart';

void main() {
  group('PlaceSelection', () {
    test('an existing place is complete', () {
      expect(const PlaceSelection(communityId: 3).isComplete, isTrue);
    });
    test('a new place needs a district and a name', () {
      expect(
        const PlaceSelection(areaId: 7, newPlaceName: 'Qunu').isComplete,
        isTrue,
      );
      expect(
        const PlaceSelection(areaId: 7, newPlaceName: 'Q').isComplete,
        isFalse,
      );
      expect(const PlaceSelection(areaId: 7).isComplete, isFalse);
      expect(const PlaceSelection(newPlaceName: 'Qunu').isComplete, isFalse);
    });
    test('nothing chosen is not complete', () {
      expect(const PlaceSelection().isComplete, isFalse);
    });
  });

  group('Location models read database rows', () {
    test('Area', () {
      final a = Area.fromJson({
        'id': 20,
        'province_id': 1,
        'name': 'OR Tambo District',
        'is_metro': false,
      });
      expect(a.name, 'OR Tambo District');
      expect(a.provinceId, 1);
      expect(a.isMetro, isFalse);
    });

    test('PlaceDetails with its district and province', () {
      final d = PlaceDetails.fromJson({
        'id': 1,
        'name': 'Qunu',
        'areas': {
          'id': 20,
          'name': 'OR Tambo District',
          'province_id': 1,
          'provinces': {'id': 1, 'name': 'Eastern Cape'},
        },
      });
      expect(d.name, 'Qunu');
      expect(d.areaName, 'OR Tambo District');
      expect(d.provinceName, 'Eastern Cape');
      expect(d.provinceId, 1);
    });
  });

  group('Produce location', () {
    Map<String, dynamic> row({String? province}) => {
      'id': '1',
      'name': 'Fresh spinach',
      'category': 'Vegetables',
      'quantity': 40,
      'unit': 'bunch',
      'price': 12,
      'is_price_negotiable': false,
      'availability_status': 'available',
      'community': 'Qunu',
      'farmer_name': 'Nomsa Mbatha',
      'farmer_id': 'abc',
      'community_id': 1,
      'area_id': 20,
      'area': 'OR Tambo District',
      'province': province,
    };

    test('label includes the province when known', () {
      expect(
        Produce.fromJson(row(province: 'Eastern Cape')).locationLabel,
        'Qunu, Eastern Cape',
      );
    });
    test('label is just the place when the province is missing', () {
      expect(Produce.fromJson(row()).locationLabel, 'Qunu');
    });
    test('ids needed for nearby grouping are read', () {
      final p = Produce.fromJson(row(province: 'Eastern Cape'));
      expect(p.communityId, 1);
      expect(p.areaId, 20);
      expect(p.farmerId, 'abc');
    });
  });
}
