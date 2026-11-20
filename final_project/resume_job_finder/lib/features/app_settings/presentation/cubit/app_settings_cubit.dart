import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_localizations.dart';
import 'app_settings_state.dart';

/// Session-only UI preferences. Persistence can be added through a repository.
class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(const AppSettingsState());

  void setThemeMode(ThemeMode themeMode) {
    emit(AppSettingsState(locale: state.locale, themeMode: themeMode));
  }

  /// Pass null to resume following the device language.
  void setLocale(Locale? locale) {
    final normalized = locale == null ? null : Locale(locale.languageCode);
    if (normalized != null &&
        !AppLocalizations.supportedLocales.contains(normalized)) {
      throw ArgumentError.value(locale, 'locale', 'Unsupported app language');
    }

    emit(AppSettingsState(locale: normalized, themeMode: state.themeMode));
  }
}
