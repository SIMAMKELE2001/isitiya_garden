import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App-wide theme: colours, typography and default component styles.
abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.forest,
      onPrimary: Colors.white,
      secondary: AppColors.gold,
      error: AppColors.error,
      surface: AppColors.cream,
      onSurface: AppColors.ink,
    );

    // 'Figtree' is bundled in assets/fonts and declared in pubspec.yaml.
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Figtree',
    );
    final textTheme =
        base.textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    OutlineInputBorder border(Color color, [double width = 2]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    final buttonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    final buttonText =
        textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.cream,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle:
            textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: AppColors.forest,
          side: const BorderSide(color: AppColors.forest, width: 2),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFCFE6B8),
        height: 72,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: border(AppColors.line),
        enabledBorder: border(AppColors.line),
        focusedBorder: border(AppColors.forest),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error),
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
