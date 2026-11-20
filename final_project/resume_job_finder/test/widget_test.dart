import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/app/di/injection_container.dart';
import 'package:resume_job_finder/app/router/app_routes.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/login_page.dart';
import 'package:resume_job_finder/features/app_settings/presentation/cubit/app_settings_cubit.dart';
import 'package:resume_job_finder/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:resume_job_finder/features/splash/presentation/pages/splash_page.dart';
import 'package:resume_job_finder/main.dart' as entrypoint;

import 'support/app_test_harness.dart';

void main() {
  setUpAll(loadDesignFonts);

  testWidgets(
    'main boots splash, opens onboarding and owns its settings Cubit',
    (tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      addTearDown(getIt.reset);

      entrypoint.main();
      await tester.pump();
      expect(find.byType(SplashPage), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingPage), findsOneWidget);
      final context = tester.element(find.byType(OnboardingPage));
      expect(Directionality.of(context), TextDirection.ltr);
      expect(Theme.of(context).useMaterial3, isTrue);
      final settings = context.read<AppSettingsCubit>();

      await tester.pumpWidget(const SizedBox.shrink());
      expect(settings.isClosed, isTrue);
    },
  );

  testWidgets('language and theme update without resetting the current route', (
    tester,
  ) async {
    final app = await pumpApp(tester, initialLocation: '/missing');
    expect(find.byType(LoginPage), findsOneWidget);

    app.settings.setLocale(const Locale('ar'));
    app.settings.setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(LoginPage));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(Theme.of(context).useMaterial3, isTrue);
    expect(app.router.routeInformationProvider.value.uri.path, AppRoutes.login);


    await tester.tap(find.byKey(const ValueKey('auth_back')));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(
      app.router.routeInformationProvider.value.uri.path,
      AppRoutes.onboarding,
    );

    app.settings.setLocale(const Locale('en'));
    app.settings.setThemeMode(ThemeMode.light);
    await tester.pumpAndSettle();
    final introContext = tester.element(find.byType(OnboardingPage));
    expect(Directionality.of(introContext), TextDirection.ltr);
    expect(Theme.of(introContext).brightness, Brightness.light);
    expect(find.text('One resume. Smarter opportunities.'), findsOneWidget);
  });

  testWidgets('follows device Arabic locale and system brightness', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = [const Locale('ar', 'EG')];
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final app = await pumpApp(tester);

    expect(find.text('سيرتك الذاتية هي بداية فرصتك'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(OnboardingPage))).brightness,
      Brightness.dark,
    );

    app.settings.setLocale(const Locale('en'));
    await tester.pumpAndSettle();
    expect(find.text('One resume. Smarter opportunities.'), findsOneWidget);
    app.settings.setLocale(null);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(find.text('سيرتك الذاتية هي بداية فرصتك'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(OnboardingPage))).brightness,
      Brightness.light,
    );
  });

  testWidgets('unsupported device language falls back to English', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = [const Locale('fr', 'FR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await pumpApp(tester);
    expect(find.text('One resume. Smarter opportunities.'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(OnboardingPage))),
      TextDirection.ltr,
    );
  });

  testWidgets('unknown platform links return safely to Login', (tester) async {
    tester.platformDispatcher.defaultRouteNameTestValue = '/external-link';
    addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
    final app = await pumpApp(tester);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(
      app.router.routeInformationProvider.value.uri.path,
      AppRoutes.login,
    );

    app.router.goNamed(AppRoutes.startName);
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage), findsOneWidget);
  });
}
