import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../cubit/app_settings_cubit.dart';
import '../cubit/app_settings_state.dart';

class AppSettingsSheet extends StatelessWidget {
  const AppSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, state) {
          final l10n = context.l10n;
          final cubit = context.read<AppSettingsCubit>();
          final language = Localizations.localeOf(context).languageCode;
          final textTheme = Theme.of(context).textTheme;
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.fromSTEB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.page + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            l10n.settingsTitle,
                            style: textTheme.titleLarge,
                          ),
                        ),
                      ),
                      IconButton(
                        key: const ValueKey('settings_close'),
                        tooltip: MaterialLocalizations.of(context)
                            .closeButtonTooltip,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.settingsLanguage,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  RadioGroup<String>(
                    groupValue: language,
                    onChanged: (value) {
                      if (value != null) cubit.setLocale(Locale(value));
                    },
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          key: const ValueKey('settings_language_ar'),
                          value: 'ar',
                          selected: language == 'ar',
                          title: Text(l10n.settingsArabic),
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<String>(
                          key: const ValueKey('settings_language_en'),
                          value: 'en',
                          selected: language == 'en',
                          title: Text(l10n.settingsEnglish),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: AppSpacing.small),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.settingsAppearance,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  RadioGroup<ThemeMode>(
                    groupValue: state.themeMode,
                    onChanged: (value) {
                      if (value != null) cubit.setThemeMode(value);
                    },
                    child: Column(
                      children: [
                        for (final option in [
                          (ThemeMode.light, l10n.settingsLight),
                          (ThemeMode.dark, l10n.settingsDark),
                          (ThemeMode.system, l10n.settingsSystem),
                        ])
                          RadioListTile<ThemeMode>(
                            key: ValueKey('settings_theme_${option.$1.name}'),
                            value: option.$1,
                            selected: state.themeMode == option.$1,
                            title: Text(option.$2),
                            contentPadding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
