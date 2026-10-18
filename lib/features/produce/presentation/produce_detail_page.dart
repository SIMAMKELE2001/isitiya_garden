import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/data/auth_providers.dart';
import '../../buyer/data/buyer_providers.dart';
import '../data/produce_repository.dart';
import '../models/produce.dart';
import 'contact_sheet.dart';

/// Opens the details screen for one listing.
void openProduceDetails(BuildContext context, Produce produce) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ProduceDetailPage(produce: produce),
    ),
  );
}

/// Everything a buyer needs to decide (FR22, FR23, FR24) and the
/// Contact farmer button (FR25).
class ProduceDetailPage extends ConsumerWidget {
  const ProduceDetailPage({super.key, required this.produce});

  final Produce produce;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = produce;
    final text = Theme.of(context).textTheme;
    final imageUrl = ref.read(produceRepositoryProvider).imageUrl(p.imagePath);
    final myType = ref.watch(buyerDetailsProvider).value?.buyerTypeName;
    final location = p.locationNote == null || p.locationNote!.trim().isEmpty
        ? p.community
        : '${p.community} · ${p.locationNote}';

    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: ListView(
        children: [
          _Hero(url: imageUrl),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        p.name,
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(p.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  p.priceLabel,
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(height: 16),
                _Panel(
                  children: [
                    InfoRow(
                      icon: Icons.scale_outlined,
                      label: 'Quantity',
                      value: '${p.quantityLabel} ${p.unit}',
                    ),
                    InfoRow(
                      icon: Icons.event_available_outlined,
                      label: 'Availability',
                      value: Format.availability(
                        p.availableFrom,
                        p.availableUntil,
                      ),
                    ),
                    InfoRow(
                      icon: Icons.place_outlined,
                      label: 'Location',
                      value: location,
                    ),
                    InfoRow(
                      icon: Icons.schedule,
                      label: 'Listed',
                      value: Format.listed(p.createdAt),
                    ),
                  ],
                ),
                if (p.description != null &&
                    p.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'About this produce',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(p.description!, style: text.bodyLarge),
                ],
                if (p.buyerTypes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Who is this for?',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in p.buyerTypes) Chip(label: Text(t)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Suitability(types: p.buyerTypes, myType: myType),
                ],
                const SizedBox(height: 20),
                Text(
                  'Farmer',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                _Panel(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.leaf,
                          child: Text(
                            p.farmerName.isEmpty
                                ? '?'
                                : p.farmerName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.farmerName,
                                style: text.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (p.farmName != null) Text(p.farmName!),
                              Text(
                                p.community,
                                style: text.bodyMedium?.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: FilledButton.icon(
            onPressed: () => showContactSheet(
              context,
              produce: p,
              buyerName: ref.read(currentProfileProvider).value?.firstName,
            ),
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Contact farmer'),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: const Color(0xFFE3EFD3),
      alignment: Alignment.center,
      child: const Icon(Icons.eco, size: 90, color: AppColors.leaf),
    );
    return SizedBox(
      height: 230,
      width: double.infinity,
      child: url == null
          ? placeholder
          : Image.network(
              url!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : placeholder,
              errorBuilder: (context, error, stack) => placeholder,
            ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(children: children),
    );
  }
}

/// Tells the buyer whether the listing is aimed at their buyer type
/// (FR24). It never blocks anything: every buyer can still make contact.
class _Suitability extends StatelessWidget {
  const _Suitability({required this.types, required this.myType});

  final List<String> types;
  final String? myType;

  @override
  Widget build(BuildContext context) {
    final suits = myType != null && types.contains(myType);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          suits ? Icons.check_circle : Icons.info_outline,
          color: suits ? AppColors.leaf : AppColors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            suits ? 'This listing is aimed at buyers like you ($myType).' : 'This listing is aimed at the buyer types above. You can still contact the farmer.',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
