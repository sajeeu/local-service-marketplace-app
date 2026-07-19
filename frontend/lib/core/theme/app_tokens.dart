import 'package:flutter/material.dart';

/// Design tokens for spacing, color, and typography foundations.
abstract final class AppColors {
  static const Color primary = Color(0xFF0F6E56);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF1F3A33);
  static const Color surface = Color(0xFFF7F9F8);
  static const Color onSurface = Color(0xFF14201C);
  static const Color error = Color(0xFFB42318);
  static const Color outline = Color(0xFFD0D7D4);
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class AppTypography {
  static const String fontFamily = 'Roboto';

  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.onSurface,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.onSurface,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.onSurface,
  );
}
