import 'package:flutter/material.dart';

/// Colors from the Movies App design. Screens must use these tokens instead
/// of hardcoded values.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFFF6BD00);
  static const Color primaryDark = Color(0xFFD9A600);

  // Backgrounds
  static const Color background = Color(0xFF121312);
  static const Color surface = Color(0xFF1A1B1A);
  static const Color surfaceLight = Color(0xFF282A28);

  // Text
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF121312);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8B8);
  static const Color textTertiary = Color(0xFF7A7A7A);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE82626);
  static const Color warning = Color(0xFFFFC107);

  // Other
  static const Color overlay = Color(0xB3121312);
  static const Color divider = Color(0xFF303130);
  static const Color shimmerBase = Color(0xFF282A28);
  static const Color shimmerHighlight = Color(0xFF3A3C3A);
  static const Color transparent = Colors.transparent;
}
