import 'package:flutter/material.dart';

@immutable
class AppSettingsState {
  const AppSettingsState({this.locale, this.themeMode = ThemeMode.system});

  /// Null follows the device's preferred supported language.
  final Locale? locale;
  final ThemeMode themeMode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsState &&
          other.locale == locale &&
          other.themeMode == themeMode;

  @override
  int get hashCode => Object.hash(locale, themeMode);
}
