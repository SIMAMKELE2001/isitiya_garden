import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A tappable rounded label for filters and categories.
/// Selected = dark green with white text; the state is also announced
/// to screen readers, so colour is not the only signal.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: selected ? AppColors.forest : Colors.white,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? AppColors.forest : AppColors.line,
              width: 2,
            ),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
