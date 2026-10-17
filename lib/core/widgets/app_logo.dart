import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Simple logo mark: a leaf on a forest-green rounded square.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: Icon(Icons.eco, color: AppColors.gold, size: size * 0.6),
    );
  }
}
