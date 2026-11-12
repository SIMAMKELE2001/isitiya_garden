import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/models/user_profile.dart';
import '../../produce/data/produce_repository.dart';
import '../../produce/models/produce.dart';

/// Which bottom-navigation tab is open (0 Home, 1 Search, 2 Profile).
class BuyerTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final buyerTabProvider = NotifierProvider<BuyerTabNotifier, int>(
  BuyerTabNotifier.new,
);

/// Everything the buyer has chosen on the Search tab.
class SearchFilters {
  const SearchFilters({
    this.query = '',
    this.category,
    this.provinceId,
    this.areaId,
    this.status,
  });

  final String query;
  final String? category;
  final int? provinceId;
  final int? areaId;
  final AvailabilityStatus? status;

  bool get isActive =>
      query.trim().isNotEmpty ||
      category != null ||
      provinceId != null ||
      areaId != null ||
      status != null;
}

class SearchFiltersNotifier extends Notifier<SearchFilters> {
  @override
  SearchFilters build() => const SearchFilters();

  void setQuery(String value) => state = SearchFilters(
    query: value,
    category: state.category,
    provinceId: state.provinceId,
    areaId: state.areaId,
    status: state.status,
  );

  void setCategory(String? value) => state = SearchFilters(
    query: state.query,
    category: value,
    provinceId: state.provinceId,
    areaId: state.areaId,
    status: state.status,
  );

  /// Choosing another province clears the district, which belonged
  /// to the old one.
  void setProvince(int? value) => state = SearchFilters(
    query: state.query,
    category: state.category,
    provinceId: value,
    areaId: null,
    status: state.status,
  );

  void setArea(int? value) => state = SearchFilters(
    query: state.query,
    category: state.category,
    provinceId: state.provinceId,
    areaId: value,
    status: state.status,
  );

  void setStatus(AvailabilityStatus? value) => state = SearchFilters(
    query: state.query,
    category: state.category,
    provinceId: state.provinceId,
    areaId: state.areaId,
    status: value,
  );

  void clear() => state = const SearchFilters();
}

final searchFiltersProvider =
    NotifierProvider<SearchFiltersNotifier, SearchFilters>(
      SearchFiltersNotifier.new,
    );

/// Re-runs the database query every time a filter changes, which also
/// gives us the loading state for free.
final searchResultsProvider = FutureProvider<List<Produce>>((ref) {
  final f = ref.watch(searchFiltersProvider);
  return ref
      .watch(produceRepositoryProvider)
      .fetchActive(
        query: f.query,
        category: f.category,
        provinceId: f.provinceId,
        areaId: f.areaId,
        status: f.status,
      );
});

/// The logged-in buyer's chosen buyer type (null for farmers).
final buyerDetailsProvider = FutureProvider<BuyerDetails?>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null || profile.role != UserRole.buyer) return null;
  return ref.watch(authRepositoryProvider).fetchBuyerDetails(profile.id);
});
