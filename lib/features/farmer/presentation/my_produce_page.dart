import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/choice_pill.dart';
import '../../../core/widgets/state_views.dart';
import '../data/farmer_providers.dart';
import 'listing_form_page.dart';
import 'listing_tile.dart';

/// Manage produce: edit, mark unavailable, deactivate or reactivate
/// (FR14, FR15, FR16).
class MyProducePage extends ConsumerStatefulWidget {
  const MyProducePage({super.key});

  @override
  ConsumerState<MyProducePage> createState() => _MyProducePageState();
}

class _MyProducePageState extends ConsumerState<MyProducePage> {
  bool _showDeactivated = false;

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(myListingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My produce')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myListingsProvider);
          await ref.read(myListingsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
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
                final deactivated = all.where((l) => !l.isActive).toList();
                final shown = _showDeactivated ? deactivated : active;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Center(
                              child: ChoicePill(
                                label: 'Active (${active.length})',
                                selected: !_showDeactivated,
                                onTap: () =>
                                    setState(() => _showDeactivated = false),
                              ),
                            ),
                          ),
                          Center(
                            child: ChoicePill(
                              label: 'Deactivated (${deactivated.length})',
                              selected: _showDeactivated,
                              onTap: () =>
                                  setState(() => _showDeactivated = true),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showDeactivated)
                      const Padding(
                        padding: EdgeInsets.only(top: 6, bottom: 8),
                        child: Text(
                          'Deactivated listings are hidden from buyers.',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (shown.isEmpty)
                      EmptyState(
                        icon: _showDeactivated
                            ? Icons.visibility_off_outlined
                            : Icons.eco_outlined,
                        title: _showDeactivated
                            ? 'No deactivated listings.'
                            : 'No produce available yet.',
                        message: _showDeactivated
                            ? 'Listings you deactivate will appear here.'
                            : 'Add what you have and nearby buyers can find you.',
                        actionLabel: _showDeactivated ? null : 'Add produce',
                        onAction: _showDeactivated
                            ? null
                            : () => openListingForm(context),
                      )
                    else
                      for (final l in shown) ListingTile(listing: l),
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
