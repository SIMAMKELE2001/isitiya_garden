import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_providers.dart';
import '../../auth/models/user_profile.dart';
import '../models/farmer_models.dart';
import 'farmer_repository.dart';

final farmerRepositoryProvider = Provider<FarmerRepository>(
  (ref) => FarmerRepository(ref.watch(supabaseClientProvider)),
);

/// Which bottom-navigation tab is open (0 Home, 1 My produce, 2 Profile).
class FarmerTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final farmerTabProvider = NotifierProvider<FarmerTabNotifier, int>(
  FarmerTabNotifier.new,
);

/// The logged-in farmer's own listings. Call ref.invalidate(...) after any
/// change and every screen showing it refreshes.
final myListingsProvider = FutureProvider<List<FarmerListing>>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) return const [];
  return ref.watch(farmerRepositoryProvider).fetchMyListings(profile.id);
});

final farmerDetailsProvider = FutureProvider<FarmerDetails?>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null || profile.role != UserRole.farmer) return null;
  return ref.watch(farmerRepositoryProvider).fetchFarmerDetails(profile.id);
});

final categoryLookupProvider = FutureProvider<List<LookupItem>>(
  (ref) => ref
      .watch(farmerRepositoryProvider)
      .lookup('categories', orderBy: 'sort_order'),
);

final unitLookupProvider = FutureProvider<List<LookupItem>>(
  (ref) => ref.watch(farmerRepositoryProvider).lookup('units', orderBy: 'id'),
);
