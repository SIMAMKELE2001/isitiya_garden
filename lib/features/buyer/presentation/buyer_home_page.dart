import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/choice_pill.dart';
import '../../../core/widgets/produce_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/data/auth_providers.dart';
import '../../location/data/location_repository.dart';
import '../../produce/data/produce_repository.dart';
import '../../produce/models/produce.dart';
import '../../produce/presentation/produce_detail_page.dart';
import '../data/buyer_providers.dart';

/// Buyer Home tab: "What is available near you?"
class BuyerHomePage extends ConsumerWidget {
  const BuyerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    final listings = ref.watch(activeListingsProvider);
    final categories = ref.watch(categoriesProvider);
    final myPlace = ref.watch(placeDetailsProvider(profile?.communityId)).value;
    final repo = ref.read(produceRepositoryProvider);
    final text = Theme.of(context).textTheme;

    Widget cardFor(Produce p) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ProduceCard(
        produce: p,
        imageUrl: repo.imageUrl(p.imagePath),
        onTap: () => openProduceDetails(context, p),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            AppLogo(size: 32),
            SizedBox(width: 10),
            Text('isitiyaGarden'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeListingsProvider);
          await ref.read(activeListingsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 18,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  myPlace == null
                      ? 'South Africa'
                      : '${myPlace.name}, ${myPlace.provinceName}',
                  style: text.bodyMedium?.copyWith(color: AppColors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Molo, ${profile?.firstName ?? ''}',
              style: text.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.forest,
              ),
            ),
            Text(
              'What is available near you?',
              style: text.titleMedium?.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: 16),
            _SearchBarButton(
              onTap: () => ref.read(buyerTabProvider.notifier).select(1),
            ),
            const SizedBox(height: 20),
            Text(
              'Categories',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            categories.when(
              loading: () => const SizedBox(height: 48),
              error: (_, _) => const SizedBox.shrink(),
              data: (names) => SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final name in names)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Center(
                          child: ChoicePill(
                            label: name,
                            selected: false,
                            onTap: () {
                              // Jump to Search with this category chosen.
                              ref
                                  .read(searchFiltersProvider.notifier)
                                  .setCategory(name);
                              ref.read(buyerTabProvider.notifier).select(1);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            listings.when(
              loading: () => const Column(
                children: [
                  SkeletonCard(),
                  SizedBox(height: 14),
                  SkeletonCard(),
                ],
              ),
              error: (e, _) => ErrorState(
                message: 'Something went wrong. Please try again.',
                onRetry: () => ref.invalidate(activeListingsProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.eco_outlined,
                    title: 'No produce available yet.',
                    message: 'Check back soon. Farmers add produce every day.',
                  );
                }
                // Nearest first: the buyer's own place, then the same
                // district, then the rest of South Africa.
                final placeId = profile?.communityId;
                final areaId = myPlace?.areaId;
                final inPlace = items
                    .where((p) => placeId != null && p.communityId == placeId)
                    .toList();
                final inArea = items
                    .where(
                      (p) =>
                          areaId != null &&
                          p.areaId == areaId &&
                          p.communityId != placeId,
                    )
                    .toList();
                final elsewhere = items
                    .where((p) => !inPlace.contains(p) && !inArea.contains(p))
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (inPlace.isNotEmpty) ...[
                      _SectionTitle(
                        'Available in ${myPlace?.name ?? 'your place'}',
                      ),
                      for (final p in inPlace) cardFor(p),
                    ],
                    if (inArea.isNotEmpty) ...[
                      _SectionTitle(
                        'Also in ${myPlace?.areaName ?? 'your district'}',
                      ),
                      for (final p in inArea) cardFor(p),
                    ],
                    if (elsewhere.isNotEmpty) ...[
                      _SectionTitle(
                        inPlace.isEmpty && inArea.isEmpty
                            ? 'Available across South Africa'
                            : 'Elsewhere in South Africa',
                      ),
                      for (final p in elsewhere) cardFor(p),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _SearchBarButton extends StatelessWidget {
  const _SearchBarButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Search produce',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.line, width: 2),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.grey),
                  SizedBox(width: 10),
                  Text(
                    'Search spinach, maize, eggs...',
                    style: TextStyle(color: AppColors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
