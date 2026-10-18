import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../features/produce/models/produce.dart';
import 'status_badge.dart';

/// Reusable card for one produce listing.
class ProduceCard extends StatelessWidget {
  const ProduceCard({
    super.key,
    required this.produce,
    this.imageUrl,
    this.onTap,
  });

  final Produce produce;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: '${produce.name}, ${produce.status.label}, '
          'from ${produce.farmerName}, ${produce.community}',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.line),
          ),
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Photo(url: imageUrl),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              produce.name,
                              style: text.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(produce.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('From ${produce.farmerName}',
                          style: text.bodyMedium
                              ?.copyWith(color: AppColors.grey)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 16, color: AppColors.grey),
                          const SizedBox(width: 4),
                          Text(produce.community,
                              style: text.bodyMedium
                                  ?.copyWith(color: AppColors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${produce.quantityLabel} ${produce.unit} available',
                        style: text.bodyMedium,
                      ),
                      Text(
                        produce.priceLabel,
                        style: text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('View produce'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: const Color(0xFFE3EFD3),
      alignment: Alignment.center,
      child: const Icon(Icons.eco, size: 48, color: AppColors.leaf),
    );

    return SizedBox(
      height: 130,
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
