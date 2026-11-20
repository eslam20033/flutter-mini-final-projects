import 'package:flutter/material.dart';

/// Colors from the brief and Figma's Design System & Components page.
/// Accessibility adjustments are called out separately below.
abstract final class AppColors {
  static const lightPrimary = Color(0xFF1769E8);
  static const lightSecondary = Color(0xFF5BA5FA);
  static const lightBackground = Color(0xFFF6F9FD);
  static const lightSurface = Colors.white;
  static const lightInk = Color(0xFF0F172A);
  static const lightMuted = Color(0xFF6B7890);
  static const lightOutline = Color(0xFFE2E9F4);
  static const lightPale = Color(0xFFE8F2FF);
  static const splashBlueStart = Color(0xFF0C4B9B);
  static const splashBlueEnd = Color(0xFF2286F1);
  static const matchSuccess = Color(0xFF059F79);

  // The source muted tone is below 4.5:1 on the light page background.
  static const lightMutedText = Color(0xFF626F86);

  static const darkPrimary = Color(0xFF2563EB);
  static const darkSecondary = Color(0xFF3D7EF1);
  static const darkBackground = Color(0xFF090B0F);
  static const darkSurface = Color(0xFF14171D);
  static const darkInk = Color(0xFFF7F9FD);
  static const darkMuted = Color(0xFFA1AAB9);
  static const darkOutline = Color(0xFF2B313C);
}
