import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/models/user_profile.dart';
import '../../produce/models/produce.dart';
import '../models/farmer_models.dart';

/// Everything the farmer side reads from and writes to Supabase.
class FarmerRepository {
  FarmerRepository(this._client);

  final SupabaseClient _client;
  static const _bucket = 'produce-images';

  // ---------- Listings ----------

  /// The farmer's own listings (active and deactivated), newest first.
  /// The embedded `categories(name)` and friends fetch related names
  /// in the same request.
  Future<List<FarmerListing>> fetchMyListings(String userId) async {
    final rows = await _client
        .from('produce_listings')
        .select(
            '*, categories(name), units(name), communities(name), listing_buyer_types(buyer_type_id)')
        .eq('farmer_id', userId)
        .order('created_at', ascending: false);
    return rows.map<FarmerListing>((r) => FarmerListing.fromJson(r)).toList();
  }

  Future<void> createListing(String userId, ListingInput input) async {
    final row = await _client
        .from('produce_listings')
        .insert({...input.toRow(), 'farmer_id': userId})
        .select('id')
        .single();
    final id = row['id'] as String;
    try {
      await _addBuyerTypes(id, input.buyerTypeIds);
    } catch (_) {
      // Undo, so we never leave a listing without its buyer types (NFR06).
      await _client.from('produce_listings').delete().eq('id', id);
      rethrow;
    }
  }

  Future<void> updateListing(FarmerListing old, ListingInput input) async {
    await _client.from('produce_listings').update(input.toRow()).eq('id', old.id);

    // Only change the buyer types that actually differ.
    final before = old.buyerTypeIds.toSet();
    final toAdd = input.buyerTypeIds.difference(before);
    final toRemove = before.difference(input.buyerTypeIds);
    await _addBuyerTypes(old.id, toAdd);
    if (toRemove.isNotEmpty) {
      await _client
          .from('listing_buyer_types')
          .delete()
          .eq('listing_id', old.id)
          .inFilter('buyer_type_id', toRemove.toList());
    }
  }

  Future<void> _addBuyerTypes(String listingId, Iterable<int> typeIds) async {
    if (typeIds.isEmpty) return;
    await _client.from('listing_buyer_types').insert([
      for (final t in typeIds) {'listing_id': listingId, 'buyer_type_id': t},
    ]);
  }

  /// FR15: mark produce as available, low or unavailable.
  Future<void> setAvailability(String id, AvailabilityStatus status) async {
    await _client
        .from('produce_listings')
        .update({'availability_status': status.name}).eq('id', id);
  }

  /// FR16: deactivate (hide) or reactivate a listing.
  Future<void> setActive(String id, bool active) async {
    await _client
        .from('produce_listings')
        .update({'is_active': active}).eq('id', id);
  }

  // ---------- Photos (FR06) ----------

  /// Uploads into the farmer's own folder, which is what the storage
  /// security rule requires. Returns the stored path.
  Future<String> uploadImage(String userId, XFile file) async {
    final bytes = await file.readAsBytes();
    final name = file.name.toLowerCase();
    final (ext, type) = name.endsWith('.png')
        ? ('png', 'image/png')
        : name.endsWith('.webp')
            ? ('webp', 'image/webp')
            : ('jpg', 'image/jpeg');
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage
        .from(_bucket)
        .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: type));
    return path;
  }

  /// Deleting an old photo is housekeeping, so failures are ignored.
  Future<void> removeImageQuietly(String path) async {
    try {
      await _client.storage.from(_bucket).remove([path]);
    } catch (_) {}
  }

  // ---------- Farmer profile (FR04) ----------

  Future<FarmerDetails?> fetchFarmerDetails(String userId) async {
    final row = await _client
        .from('farmer_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return row == null ? null : FarmerDetails.fromJson(row);
  }

  Future<void> updateFarmerProfile({
    required String userId,
    required String fullName,
    required String phone,
    required int communityId,
    required String farmName,
    String? whatsappNumber,
    String? about,
  }) async {
    await _client.from('profiles').update({
      'full_name': fullName.trim(),
      'phone': phone.trim(),
      'community_id': communityId,
    }).eq('id', userId);
    await _client.from('farmer_profiles').update({
      'farm_name': farmName.trim(),
      'whatsapp_number': whatsappNumber,
      'about': about,
    }).eq('id', userId);
  }

  // ---------- Lookup lists for the form ----------

  Future<List<LookupItem>> lookup(String table, {String orderBy = 'name'}) async {
    final rows = await _client.from(table).select('id, name').order(orderBy);
    return rows.map<LookupItem>((r) => LookupItem.fromJson(r)).toList();
  }
}
