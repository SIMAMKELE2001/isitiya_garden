import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

/// The only place that talks to Supabase about accounts.
/// Screens call these methods and never touch Supabase directly.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Creates the account. The extra details go in `data`; the database
  /// trigger `handle_new_user` reads them and creates the profile rows.
  /// Returns false if Supabase wants the email confirmed before login.
  Future<bool> register({
    required String email,
    required String password,
    required UserRole role,
    required String fullName,
    required String phone,
    required int communityId,
    String? farmName,
    int? buyerTypeId,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'role': role.name,
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        'community_id': communityId,
        'farm_name': ?farmName?.trim(),
        'buyer_type_id': ?buyerTypeId,
      },
    );
    return response.session != null;
  }

  Future<UserProfile?> fetchProfile(String userId) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return row == null ? null : UserProfile.fromJson(row);
  }

  /// The buyer's chosen type, with its name (joined from buyer_types).
  Future<BuyerDetails?> fetchBuyerDetails(String userId) async {
    final row = await _client
        .from('buyer_profiles')
        .select('buyer_type_id, buyer_types(name)')
        .eq('id', userId)
        .maybeSingle();
    return row == null ? null : BuyerDetails.fromJson(row);
  }

  /// Saves the buyer's changes (FR17, FR18). Row Level Security makes sure
  /// a user can only ever change their own rows.
  Future<void> updateBuyerProfile({
    required String userId,
    required String fullName,
    required String phone,
    required int communityId,
    required int buyerTypeId,
  }) async {
    await _client.from('profiles').update({
      'full_name': fullName.trim(),
      'phone': phone.trim(),
      'community_id': communityId,
    }).eq('id', userId);
    await _client
        .from('buyer_profiles')
        .update({'buyer_type_id': buyerTypeId}).eq('id', userId);
  }

  Future<List<LookupItem>> communities() => _lookup('communities');

  Future<List<LookupItem>> buyerTypes() => _lookup('buyer_types');

  Future<List<LookupItem>> _lookup(String table) async {
    final rows = await _client.from(table).select('id, name').order('name');
    return rows.map<LookupItem>((r) => LookupItem.fromJson(r)).toList();
  }

  Future<void> signOut() => _client.auth.signOut();
}
