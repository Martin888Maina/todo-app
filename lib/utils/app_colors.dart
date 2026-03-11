import 'package:flutter/material.dart';

// All colours used across the app — keeps styling consistent and easy to update
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF009688);
  static const Color primaryDark = Color(0xFF00796B);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textCompleted = Color(0xFFBDBDBD);

  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityMedium = Color(0xFFFFB300);
  static const Color priorityLow = Color(0xFF43A047);

  static const Color overdueRed = Color(0xFFD32F2F);

  // Category colours for quick visual scanning
  static const Color categoryWork = Color(0xFF546E7A);
  static const Color categoryPersonal = Color(0xFFFB8C00);
  static const Color categoryShopping = Color(0xFF26A69A);
  static const Color categoryHealth = Color(0xFFEC407A);
  static const Color categoryOther = Color(0xFF78909C);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
}
