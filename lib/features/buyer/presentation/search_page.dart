import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/choice_pill.dart';
import '../../../core/widgets/produce_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/models/user_profile.dart';
import '../../produce/data/produce_repository.dart';
import '../../produce/models/produce.dart';
import '../../produce/presentation/produce_detail_page.dart';
import '../data/buyer_providers.dart';

/// Search tab: text search plus category, availability and community filters.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Wait until the user pauses typing, so we do not query on every letter.
  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchFiltersProvider.notifier).setQuery(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(searchFiltersProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(searchFiltersProvider);
    final notifier = ref.read(searchFiltersProvider.notifier);
    final results = ref.watch(searchResultsProvider);
    final categories = ref.watch(categoriesProvider).value ?? const <String>[];
    final communities =
        ref.watch(communitiesProvider).value ?? const <LookupItem>[];
    final repo = ref.read(produceRepositoryProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Search produce')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _controller,
            onChanged: _onChanged,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Search spinach, maize, eggs...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          _FilterRow(
            title: 'Category',
            pills: [
              ChoicePill(
                label: 'All',
                selected: filters.category == null,
                onTap: () => notifier.setCategory(null),
              ),
              for (final c in categories)
                ChoicePill(
                  label: c,
                  selected: filters.category == c,
                  onTap: () =>
                      notifier.setCategory(filters.category == c ? null : c),
                ),
            ],
          ),
          _FilterRow(
            title: 'Availability',
            pills: [
              ChoicePill(
                label: 'Any',
                selected: filters.status == null,
                onTap: () => notifier.setStatus(null),
              ),
              for (final s in const [
                AvailabilityStatus.available,
                AvailabilityStatus.low,
              ])
                ChoicePill(
                  label: s.label,
                  selected: filters.status == s,
                  onTap: () =>
                      notifier.setStatus(filters.status == s ? null : s),
                ),
            ],
          ),
          _FilterRow(
            title: 'Community',
            pills: [
              ChoicePill(
                label: 'Any',
                selected: filters.community == null,
                onTap: () => notifier.setCommunity(null),
              ),
              for (final c in communities)
                ChoicePill(
                  label: c.name,
                  selected: filters.community == c.name,
                  onTap: () => notifier.setCommunity(
                    filters.community == c.name ? null : c.name,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  results.when(
                    loading: () => 'Searching...',
                    error: (_, _) => '',
                    data: (items) =>
                        '${items.length} ${items.length == 1 ? 'result' : 'results'}',
                  ),
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
              ),
              if (filters.isActive)
                TextButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.close),
                  label: const Text('Clear filters'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          results.when(
            loading: () => const Column(
              children: [SkeletonCard(), SizedBox(height: 14), SkeletonCard()],
            ),
            error: (e, _) => ErrorState(
              message: 'Something went wrong. Please try again.',
              onRetry: () => ref.invalidate(searchResultsProvider),
            ),
            data: (items) => items.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: "We couldn't find that produce nearby.",
                    message: 'Try another name, or clear the filters.',
                    actionLabel: filters.isActive ? 'Clear filters' : null,
                    onAction: filters.isActive ? _clear : null,
                  )
                : Column(
                    children: [
                      for (final p in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: ProduceCard(
                            produce: p,
                            imageUrl: repo.imageUrl(p.imagePath),
                            onTap: () => openProduceDetails(context, p),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// A heading with a sideways-scrolling row of pills under it.
class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.title, required this.pills});

  final String title;
  final List<Widget> pills;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final pill in pills)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(child: pill),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
