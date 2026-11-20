import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/core/theme/app_theme.dart';

double contrast(Color first, Color second) {
  final a = first.computeLuminance();
  final b = second.computeLuminance();
  final lighter = a > b ? a : b;
  final darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  final themes = [
    (
      name: 'light',
      theme: AppTheme.light,
      primary: const Color(0xFF1769E8),
      background: const Color(0xFFF6F9FD),
      surface: Colors.white,
    ),
    (
      name: 'dark',
      theme: AppTheme.dark,
      primary: const Color(0xFF2563EB),
      background: const Color(0xFF090B0F),
      surface: const Color(0xFF14171D),
    ),
  ];

  for (final spec in themes) {
    test('${spec.name} theme preserves the supplied palette', () {
      final theme = spec.theme;
      expect(theme.colorScheme.primary, spec.primary);
      expect(theme.scaffoldBackgroundColor, spec.background);
      expect(theme.appBarTheme.backgroundColor, spec.background);
      expect(theme.cardTheme.color, spec.surface);
      expect(theme.cardTheme.surfaceTintColor, Colors.transparent);
      expect(theme.inputDecorationTheme.fillColor, spec.surface);
      expect(
        theme.filledButtonTheme.style!.backgroundColor!.resolve({}),
        spec.primary,
      );
    });

    test('${spec.name} theme keeps normal text readable on its surfaces', () {
      final theme = spec.theme;
      final colors = theme.colorScheme;
      final textColors = [
        colors.onSurface,
        colors.onSurfaceVariant,
        theme.textButtonTheme.style!.foregroundColor!.resolve({})!,
        theme.outlinedButtonTheme.style!.foregroundColor!.resolve({})!,
        WidgetStateProperty.resolveAs<TextStyle>(
          theme.inputDecorationTheme.floatingLabelStyle!,
          {WidgetState.focused},
        ).color!,
      ];
      for (final background in [spec.background, spec.surface]) {
        for (final foreground in textColors) {
          expect(
            contrast(foreground, background),
            greaterThanOrEqualTo(4.5),
            reason:
                'Normal text must remain readable on page and card surfaces.',
          );
        }
      }
      expect(
        contrast(colors.onPrimary, colors.primary),
        greaterThanOrEqualTo(4.5),
        reason: 'Filled action labels must remain readable on brand blue.',
      );
      expect(
        contrast(colors.onSecondary, colors.secondary),
        greaterThanOrEqualTo(4.5),
        reason: 'Secondary accent fills also need a readable foreground.',
      );
      expect(
        contrast(colors.primary, spec.surface),
        greaterThanOrEqualTo(3),
        reason: 'Focused input outlines must stand out against the field.',
      );
    });
  }
}
