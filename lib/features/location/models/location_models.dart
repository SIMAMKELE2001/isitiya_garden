/// A district or metropolitan municipality (the middle level of the
/// province > district > place structure).
class Area {
  const Area({
    required this.id,
    required this.provinceId,
    required this.name,
    required this.isMetro,
  });

  final int id;
  final int provinceId;
  final String name;
  final bool isMetro;

  factory Area.fromJson(Map<String, dynamic> json) => Area(
    id: json['id'] as int,
    provinceId: json['province_id'] as int,
    name: json['name'] as String,
    isMetro: json['is_metro'] as bool,
  );
}

/// A town, village or farming area (a row of the `communities` table).
class PlaceItem {
  const PlaceItem({required this.id, required this.areaId, required this.name});

  final int id;
  final int areaId;
  final String name;

  factory PlaceItem.fromJson(Map<String, dynamic> json) => PlaceItem(
    id: json['id'] as int,
    areaId: json['area_id'] as int,
    name: json['name'] as String,
  );
}

/// A place together with its district and province, so an edit form can
/// show all three drop-downs already filled in.
class PlaceDetails {
  const PlaceDetails({
    required this.communityId,
    required this.name,
    required this.areaId,
    required this.areaName,
    required this.provinceId,
    required this.provinceName,
  });

  final int communityId;
  final String name;
  final int areaId;
  final String areaName;
  final int provinceId;
  final String provinceName;

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final area = json['areas'] as Map<String, dynamic>;
    final province = area['provinces'] as Map<String, dynamic>;
    return PlaceDetails(
      communityId: json['id'] as int,
      name: json['name'] as String,
      areaId: area['id'] as int,
      areaName: area['name'] as String,
      provinceId: province['id'] as int,
      provinceName: province['name'] as String,
    );
  }
}

/// What the person chose in the place picker: either an existing place,
/// or a district plus the name of a new place to create.
class PlaceSelection {
  const PlaceSelection({this.communityId, this.areaId, this.newPlaceName});

  final int? communityId;
  final int? areaId;
  final String? newPlaceName;

  bool get isComplete =>
      communityId != null ||
      (areaId != null && (newPlaceName?.trim().length ?? 0) >= 2);
}
