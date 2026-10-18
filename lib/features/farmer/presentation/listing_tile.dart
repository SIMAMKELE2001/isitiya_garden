import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../produce/data/produce_repository.dart';
import '../../produce/models/produce.dart';
import '../data/farmer_providers.dart';
import '../models/farmer_models.dart';
import 'listing_form_page.dart';

/// One of the farmer's listings, with Edit and the manage actions
/// (FR14, FR15, FR16).
class ListingTile extends ConsumerWidget {
  const ListingTile({super.key, required this.listing});

  final FarmerListing listing;

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
    String successMessage,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      ref.invalidate(myListingsProvider);
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Something went wrong. Please try again.'),
      ));
    }
  }

  Future<void> _toggleAvailability(BuildContext context, WidgetRef ref) {
    final repo = ref.read(farmerRepositoryProvider);
    final makeAvailable = listing.status == AvailabilityStatus.unavailable;
    return _run(
      context,
      ref,
      () => repo.setAvailability(
        listing.id,
        makeAvailable ? AvailabilityStatus.available : AvailabilityStatus.unavailable,
      ),
      makeAvailable
          ? '${listing.name} is available again.'
          : '${listing.name} is now marked unavailable.',
    );
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(farmerRepositoryProvider);

    if (!listing.isActive) {
      return _run(context, ref, () => repo.setActive(listing.id, true),
          '${listing.name} is active again.');
    }

    // Deactivating hides the listing, so ask first.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deactivate this listing?'),
        content: Text(
            'Buyers will no longer see ${listing.name}. You can reactivate it later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    return _run(context, ref, () => repo.setActive(listing.id, false),
        '${listing.name} has been deactivated.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final text = Theme.of(context).textTheme;
    final imageUrl = ref.read(produceRepositoryProvider).imageUrl(l.imagePath);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumb(url: imageUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.name,
                        style: text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('${l.quantityLabel} ${l.unitName} · ${l.priceLabel}',
                        style: text.bodyMedium),
                    const SizedBox(height: 2),
                    Text(l.communityName,
                        style: text.bodyMedium?.copyWith(color: AppColors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StatusBadge(l.status),
                        if (!l.isActive) const _DeactivatedBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => openListingForm(context, existing: l),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: 'More actions',
                onSelected: (value) {
                  if (value == 'availability') _toggleAvailability(context, ref);
                  if (value == 'active') _toggleActive(context, ref);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'availability',
                    child: Text(l.status == AvailabilityStatus.unavailable
                        ? 'Mark as available'
                        : 'Mark as unavailable'),
                  ),
                  PopupMenuItem(
                    value: 'active',
                    child: Text(l.isActive ? 'Deactivate listing' : 'Reactivate listing'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: const Color(0xFFE3EFD3),
      alignment: Alignment.center,
      child: const Icon(Icons.eco, size: 32, color: AppColors.leaf),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 80,
        height: 80,
        child: url == null
            ? placeholder
            : Image.network(
                url!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : placeholder,
                errorBuilder: (context, error, stack) => placeholder,
              ),
      ),
    );
  }
}

class _DeactivatedBadge extends StatelessWidget {
  const _DeactivatedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey, width: 1.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_off, size: 14, color: AppColors.grey),
          SizedBox(width: 4),
          Text('Deactivated',
              style: TextStyle(
                  color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
