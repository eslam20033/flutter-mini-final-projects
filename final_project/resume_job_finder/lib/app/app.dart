import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/app_settings/presentation/cubit/app_settings_cubit.dart';
import '../features/app_settings/presentation/cubit/app_settings_state.dart';
import '../l10n/generated/app_localizations.dart';

class ResumeJobFinderApp extends StatelessWidget {
  const ResumeJobFinderApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, settings) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        routerConfig: router,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.themeMode,
        locale: settings.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final theme = Theme.of(context);
          final font = Localizations.localeOf(context).languageCode == 'ar'
              ? 'NotoSansArabic'
              : 'Inter';
          return Theme(
            data: theme.copyWith(
              textTheme: theme.textTheme.apply(fontFamily: font),
              primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: font),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
