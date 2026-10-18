import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/data/auth_providers.dart';
import '../../produce/models/produce.dart';
import '../data/farmer_providers.dart';
import 'listing_form_page.dart';
import 'listing_tile.dart';

/// Farmer Home: a quick summary and the most recent listings.
class FarmerHomePage extends ConsumerWidget {
  const FarmerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    final listings = ref.watch(myListingsProvider);
    final text = Theme.of(context).textTheme;

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
          ref.invalidate(myListingsProvider);
          await ref.read(myListingsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            Text(
              'Molo, ${profile?.firstName ?? ''}',
              style: text.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.forest,
              ),
            ),
            Text(
              'Let buyers know what you have today.',
              style: text.titleMedium?.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: 16),
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
                onRetry: () => ref.invalidate(myListingsProvider),
              ),
              data: (all) {
                final active = all.where((l) => l.isActive).toList();
                final visible = active.where((l) => l.isVisibleToBuyers).length;
                final low = active
                    .where((l) => l.status == AvailabilityStatus.low)
                    .length;
                final unavailable = active
                    .where((l) => l.status == AvailabilityStatus.unavailable)
                    .length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.forest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$visible',
                            style: text.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            visible == 1
                                ? 'listing visible to buyers'
                                : 'listings visible to buyers',
                            style: text.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          if (low > 0 || unavailable > 0) ...[
                            const SizedBox(height: 6),
                            Text(
                              '$low low availability · $unavailable unavailable',
                              style: text.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: () => openListingForm(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add produce'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: const Color(0xFF2A1D00),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Your active listings',
                            style: text.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (active.length > 3)
                          TextButton(
                            onPressed: () =>
                                ref.read(farmerTabProvider.notifier).select(1),
                            child: const Text('See all'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (active.isEmpty)
                      EmptyState(
                        icon: Icons.eco_outlined,
                        title: 'No produce available yet.',
                        message:
                            'Add what you have and nearby buyers can find you.',
                        actionLabel: 'Add produce',
                        onAction: () => openListingForm(context),
                      )
                    else
                      for (final l in active.take(3)) ListingTile(listing: l),
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
