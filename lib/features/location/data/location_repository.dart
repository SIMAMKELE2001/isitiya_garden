import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/models/user_profile.dart';
import '../models/location_models.dart';

/// Reads the province > district > place structure and creates new places.
class LocationRepository {
  LocationRepository(this._client);

  final SupabaseClient _client;

  Future<List<LookupItem>> provinces() async {
    final rows = await _client
        .from('provinces')
        .select('id, name')
        .order('name');
    return rows.map<LookupItem>((r) => LookupItem.fromJson(r)).toList();
  }

  /// Districts and metros, optionally only those of one province.
  Future<List<Area>> areas({int? provinceId}) async {
    var request = _client
        .from('areas')
        .select('id, province_id, name, is_metro');
    if (provinceId != null) {
      request = request.eq('province_id', provinceId);
    }
    final rows = await request.order('name');
    return rows.map<Area>((r) => Area.fromJson(r)).toList();
  }

  Future<List<PlaceItem>> places(int areaId) async {
    final rows = await _client
        .from('communities')
        .select('id, area_id, name')
        .eq('area_id', areaId)
        .order('name');
    return rows.map<PlaceItem>((r) => PlaceItem.fromJson(r)).toList();
  }

  /// The place with its district and province (embedded selects).
  Future<PlaceDetails?> placeDetails(int communityId) async {
    final row = await _client
        .from('communities')
        .select('id, name, areas(id, name, province_id, provinces(id, name))')
        .eq('id', communityId)
        .maybeSingle();
    return row == null ? null : PlaceDetails.fromJson(row);
  }

  /// Turns a selection into a place id. For a new place it calls the
  /// database function, which trims the name and avoids duplicates.
  Future<int> resolve(PlaceSelection selection) async {
    final existing = selection.communityId;
    if (existing != null) return existing;

    final result = await _client.rpc(
      'get_or_create_place',
      params: {'p_area_id': selection.areaId, 'p_name': selection.newPlaceName},
    );
    return result as int;
  }
}

final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => LocationRepository(ref.watch(supabaseClientProvider)),
);

final provincesProvider = FutureProvider<List<LookupItem>>(
  (ref) => ref.watch(locationRepositoryProvider).provinces(),
);

/// A "family" provider: one cached list per province (null = every district).
final areasProvider = FutureProvider.family<List<Area>, int?>(
  (ref, provinceId) =>
      ref.watch(locationRepositoryProvider).areas(provinceId: provinceId),
);

/// One cached list of places per district.
final placesProvider = FutureProvider.family<List<PlaceItem>, int>(
  (ref, areaId) => ref.watch(locationRepositoryProvider).places(areaId),
);

/// The details (name, district, province) of one place, cached per id.
/// Used wherever we show a person's place without loading every place.
final placeDetailsProvider = FutureProvider.family<PlaceDetails?, int?>((
  ref,
  communityId,
) async {
  if (communityId == null) return null;
  return ref.watch(locationRepositoryProvider).placeDetails(communityId);
});
