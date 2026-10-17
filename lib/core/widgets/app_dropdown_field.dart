import 'package:flutter/material.dart';

/// A labelled drop-down with the same look as AppTextField.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.hint,
    this.validator,
    this.initialValue,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? Function(T?)? validator;
  final T? initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: initialValue,
          items: items,
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
