import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  // Figma component nodes 1:4413–1:4423; card reference 1:1165.
  static const _buttonRadius = BorderRadius.all(Radius.circular(14));
  static const _inputRadius = BorderRadius.all(Radius.circular(13));
  static const _cardRadius = BorderRadius.all(Radius.circular(18));
  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: _buttonRadius,
  );
  static const _buttonPadding = EdgeInsetsDirectional.symmetric(
    horizontal: AppSpacing.buttonHorizontal,
    vertical: AppSpacing.buttonVertical,
  );
  static const _buttonMinimumSize = Size(64, 52);

  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final background = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final colors = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      // A seed alone does not preserve the exact approved brand colors.
      primary: primary,
      onPrimary: Colors.white,
      secondary: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
      onSecondary: AppColors.lightInk,
      surface: surface,
      surfaceContainerLow: surface,
      onSurface: isDark ? AppColors.darkInk : AppColors.lightInk,
      onSurfaceVariant: isDark ? AppColors.darkMuted : AppColors.lightMutedText,
      outline: isDark ? AppColors.darkOutline : AppColors.lightOutline,
      outlineVariant: isDark ? AppColors.darkOutline : AppColors.lightOutline,
    );

    // The dark brand blue is suitable for fills/focus outlines but too dark
    // for small text on a dark surface. Use a generated light tone for labels.
    final actionText = isDark ? colors.onPrimaryContainer : colors.primary;

    OutlineInputBorder inputBorder(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: _inputRadius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      fontFamily: 'Inter',
      fontFamilyFallback: const ['NotoSansArabic'],
      // Confirmed component text sizes. Other roles retain Material 3's scale
      // until the corresponding product screens are implemented.
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 13, letterSpacing: 0),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: _cardRadius,
          side: BorderSide(color: colors.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surface,
        constraints: const BoxConstraints(minHeight: 54),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.inputHorizontal,
          vertical: AppSpacing.medium,
        ),
        border: inputBorder(colors.outline),
        enabledBorder: inputBorder(colors.outline),
        focusedBorder: inputBorder(colors.primary, width: 2),
        disabledBorder: inputBorder(colors.outlineVariant),
        errorBorder: inputBorder(colors.error),
        focusedErrorBorder: inputBorder(colors.error, width: 2),
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        helperStyle: TextStyle(color: colors.onSurfaceVariant),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return TextStyle(color: colors.error);
          }
          return TextStyle(
            color: states.contains(WidgetState.focused)
                ? actionText
                : colors.onSurfaceVariant,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: _buttonMinimumSize,
          padding: _buttonPadding,
          shape: _buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: colors.onSurface,
          side: BorderSide(color: colors.outline),
          minimumSize: _buttonMinimumSize,
          padding: _buttonPadding,
          shape: _buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: actionText,
          minimumSize: _buttonMinimumSize,
          padding: _buttonPadding,
          shape: _buttonShape,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: actionText,
        selectionColor: colors.primary.withValues(alpha: 0.25),
        selectionHandleColor: actionText,
      ),
    );
  }
}
