import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/auth_providers.dart';
import '../models/produce.dart';

/// Reads produce from the database.
class ProduceRepository {
  ProduceRepository(this._client);

  final SupabaseClient _client;

  /// Live listings, optionally narrowed by search text and filters
  /// (FR19, FR20, FR21). The `active_listings` view already hides inactive,
  /// unavailable and expired listings (NFR10).
  ///
  /// The search text matches the produce name, farmer, farm, town, district
  /// or province, so "Qunu" or "Eastern Cape" work as well as "spinach".
  Future<List<Produce>> fetchActive({
    String? query,
    String? category,
    int? provinceId,
    int? areaId,
    AvailabilityStatus? status,
  }) async {
    var request = _client.from('active_listings').select();

    // Characters with a special meaning in a filter are replaced by spaces.
    final text = query?.replaceAll(RegExp(r'[,()*%\\"]'), ' ').trim();
    if (text != null && text.isNotEmpty) {
      request = request.or(
        'name.ilike.*$text*,farmer_name.ilike.*$text*,farm_name.ilike.*$text*,'
        'community.ilike.*$text*,area.ilike.*$text*,province.ilike.*$text*',
      );
    }
    if (category != null) {
      request = request.eq('category', category);
    }
    if (provinceId != null) {
      request = request.eq('province_id', provinceId);
    }
    if (areaId != null) {
      request = request.eq('area_id', areaId);
    }
    if (status != null) {
      request = request.eq('availability_status', status.name);
    }

    final rows = await request.order('created_at', ascending: false);
    return rows.map<Produce>((r) => Produce.fromJson(r)).toList();
  }

  /// Category names for the chips, in the order set in the database.
  Future<List<String>> fetchCategories() async {
    final rows = await _client
        .from('categories')
        .select('name')
        .order('sort_order');
    return rows.map<String>((r) => r['name'] as String).toList();
  }

  /// Turns a stored file path into a web address for the photo.
  String? imageUrl(String? path) => path == null
      ? null
      : _client.storage.from('produce-images').getPublicUrl(path);
}

final produceRepositoryProvider = Provider<ProduceRepository>(
  (ref) => ProduceRepository(ref.watch(supabaseClientProvider)),
);

final activeListingsProvider = FutureProvider<List<Produce>>(
  (ref) => ref.watch(produceRepositoryProvider).fetchActive(),
);

final categoriesProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(produceRepositoryProvider).fetchCategories(),
);
