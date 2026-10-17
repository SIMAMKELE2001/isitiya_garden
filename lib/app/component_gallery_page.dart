import 'package:flutter/material.dart';
import '../core/widgets/app_text_field.dart';
import '../core/widgets/produce_card.dart';
import '../core/widgets/state_views.dart';
import '../core/widgets/status_badge.dart';
import '../features/produce/models/produce.dart';

/// Temporary page that shows every reusable component, like a
/// component library page in Figma. We delete it before release.
class ComponentGalleryPage extends StatefulWidget {
  const ComponentGalleryPage({super.key});

  @override
  State<ComponentGalleryPage> createState() => _ComponentGalleryPageState();
}

class _ComponentGalleryPageState extends State<ComponentGalleryPage> {
  static const _samples = [
    Produce(
      id: '1',
      name: 'Fresh spinach',
      category: 'Vegetables',
      quantity: 40,
      unit: 'bunch',
      price: 12,
      isPriceNegotiable: false,
      status: AvailabilityStatus.available,
      community: 'Qunu',
      farmerName: 'Nomsa Mbatha',
    ),
    Produce(
      id: '2',
      name: 'White maize',
      category: 'Maize',
      quantity: 200,
      unit: 'kg',
      isPriceNegotiable: true,
      status: AvailabilityStatus.low,
      community: 'Mqanduli',
      farmerName: 'Thando Gqirana',
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  String _view = 'cards';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _validate() {
    final ok = _formKey.currentState!.validate();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Looks good!' : 'Please fix the errors above.')),
    );
  }

  Widget _demo() => switch (_view) {
        'loading' => const SkeletonCard(),
        'empty' => EmptyState(
            icon: Icons.eco_outlined,
            title: 'No produce available yet.',
            message: 'Check back soon, or try another community.',
            actionLabel: 'Refresh',
            onAction: () => setState(() => _view = 'cards'),
          ),
        'error' => ErrorState(
            message: 'Something went wrong. Please try again.',
            onRetry: () => setState(() => _view = 'cards'),
          ),
        _ => Column(
            children: [
              for (final p in _samples)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ProduceCard(
                    produce: p,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening ${p.name}')),
                    ),
                  ),
                ),
            ],
          ),
      };

  @override
  Widget build(BuildContext context) {
    final heading = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(fontWeight: FontWeight.w800);

    return Scaffold(
      appBar: AppBar(title: const Text('Component gallery')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Buttons', style: heading),
          const SizedBox(height: 10),
          FilledButton(onPressed: () {}, child: const Text('Primary button')),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: () {}, child: const Text('Secondary button')),
          const SizedBox(height: 24),
          Text('Status badges', style: heading),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(AvailabilityStatus.available),
              StatusBadge(AvailabilityStatus.low),
              StatusBadge(AvailabilityStatus.unavailable),
            ],
          ),
          const SizedBox(height: 24),
          Text('Form validation', style: heading),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  label: 'Produce name',
                  hint: 'e.g. Spinach',
                  controller: _name,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'This field is required.'
                      : null,
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: _validate, child: const Text('Check form')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Cards and states', style: heading),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final v in ['cards', 'loading', 'empty', 'error'])
                ChoiceChip(
                  label: Text(v),
                  selected: _view == v,
                  onSelected: (_) => setState(() => _view = v),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _demo(),
        ],
      ),
    );
  }
}
