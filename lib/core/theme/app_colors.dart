import 'package:flutter/material.dart';

/// Central color palette for Smart Pump 2.0.
///
/// Keep every raw color value here so theming stays consistent
/// across light & dark mode and future rebrands only touch one file.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF009688); // Teal
  static const Color primaryDark = Color(0xFF00695C);
  static const Color primaryLight = Color(0xFF4DB6AC);

  static const Color secondary = Color(0xFF4CAF50); // Green
  static const Color secondaryDark = Color(0xFF2E7D32);
  static const Color secondaryLight = Color(0xFF81C784);

  // Status
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color success = Color(0xFF4CAF50);

  // Neutrals - Light theme
  static const Color lightBackground = Color(0xFFF5F7F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEDF2F1);
  static const Color lightOnSurface = Color(0xFF1B1F1E);
  static const Color lightOutline = Color(0xFFDDE4E3);

  // Neutrals - Dark theme
  static const Color darkBackground = Color(0xFF0F1413);
  static const Color darkSurface = Color(0xFF171D1C);
  static const Color darkSurfaceVariant = Color(0xFF212827);
  static const Color darkOnSurface = Color(0xFFE3E9E8);
  static const Color darkOutline = Color(0xFF2E3634);

  // Data visualization palette (charts)
  static const List<Color> chartPalette = [
    Color(0xFF009688),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFFF44336),
  ];

  // Gradients
  static const LinearGradient tealGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient waterGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFB74D), warning],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFE57373), danger],
  );
}
