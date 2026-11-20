import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:resume_job_finder/app/app.dart';
import 'package:resume_job_finder/app/router/app_router.dart';
import 'package:resume_job_finder/app/router/auth_session.dart';
import 'package:resume_job_finder/features/app_settings/presentation/cubit/app_settings_cubit.dart';
import 'test_auth_repository.dart';
import 'package:resume_job_finder/features/auth/domain/auth_repository.dart';
import 'test_career_preferences_repository.dart';
import 'package:resume_job_finder/features/career_preferences/domain/career_preferences_repository.dart';
import 'test_dashboard_repository.dart';
import 'package:resume_job_finder/features/home/domain/dashboard_repository.dart';

Future<void> loadDesignFonts() async {
  final inter = FontLoader('Inter')
    ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
  final arabic = FontLoader('NotoSansArabic')
    ..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'));
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await Future.wait([inter.load(), arabic.load(), icons.load()]);
}

Future<({AppSettingsCubit settings, GoRouter router})> pumpApp(
  WidgetTester tester, {
  String? initialLocation,
  Locale? locale,
  ThemeMode themeMode = ThemeMode.system,
  Size? size,
  double textScale = 1,
  bool settle = true,
  AuthRepository? authRepository,
  CareerPreferencesRepository? preferencesRepository,
  DashboardRepository? dashboardRepository,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  if (textScale != 1) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  final settings = AppSettingsCubit()
    ..setLocale(locale)
    ..setThemeMode(themeMode);
  final session = AuthSession(authRepository ?? TestAuthRepository());
  final router = createAppRouter(
    initialLocation: initialLocation,
    session: session,
    preferencesRepository:
        preferencesRepository ??
        TestCareerPreferencesRepository(delay: Duration.zero),
    dashboardRepository:
        dashboardRepository ?? TestDashboardRepository(delay: Duration.zero),
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await settings.close();
    router.dispose();
    session.dispose();
  });
  await tester.pumpWidget(
    BlocProvider.value(
      value: settings,
      child: ResumeJobFinderApp(router: router),
    ),
  );
  if (settle) await tester.pumpAndSettle();
  return (settings: settings, router: router);
}
