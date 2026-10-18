import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import 'auth_repository.dart';

/// Gives any screen access to the one Supabase client.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(supabaseClientProvider)),
);

/// Emits when someone logs in or out. Hourly token refreshes are ignored,
/// otherwise the screen would reload for no visible reason.
final authChangesProvider = StreamProvider<AuthState>((ref) {
  return ref
      .watch(supabaseClientProvider)
      .auth
      .onAuthStateChange
      .where((state) => state.event != AuthChangeEvent.tokenRefreshed);
});

/// The profile (name, role...) of whoever is logged in, or null.
/// Watching authChangesProvider makes it reload on login and logout.
final currentProfileProvider = FutureProvider<UserProfile?>((ref) async {
  ref.watch(authChangesProvider);
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;
  return ref.watch(authRepositoryProvider).fetchProfile(user.id);
});

final communitiesProvider = FutureProvider<List<LookupItem>>(
  (ref) => ref.watch(authRepositoryProvider).communities(),
);

final buyerTypesProvider = FutureProvider<List<LookupItem>>(
  (ref) => ref.watch(authRepositoryProvider).buyerTypes(),
);
