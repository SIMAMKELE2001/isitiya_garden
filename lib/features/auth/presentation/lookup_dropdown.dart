import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_dropdown_field.dart';
import '../models/user_profile.dart';

/// A drop-down filled from a database lookup table, with its own
/// loading and error states.
class LookupDropdown extends StatelessWidget {
  const LookupDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.onChanged,
    required this.onRetry,
    this.initialValue,
  });

  final String label;
  final String hint;
  final AsyncValue<List<LookupItem>> items;
  final ValueChanged<int?> onChanged;
  final VoidCallback onRetry;
  final int? initialValue;

  @override
  Widget build(BuildContext context) {
    return items.when(
      data: (list) => AppDropdownField<int>(
        label: label,
        hint: hint,
        initialValue: initialValue,
        items: [
          for (final i in list)
            DropdownMenuItem<int>(value: i.id, child: Text(i.name)),
        ],
        onChanged: onChanged,
        validator: (v) => v == null ? 'Please choose an option.' : null,
      ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      ),
      error: (_, _) => TextButton(
        onPressed: onRetry,
        child: Text('Could not load $label. Tap to try again.'),
      ),
    );
  }
}
