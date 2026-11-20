import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/app/router/app_routes.dart';
import 'package:resume_job_finder/features/app_settings/presentation/widgets/app_settings_sheet.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/login_page.dart';
import 'package:resume_job_finder/features/career_preferences/presentation/widgets/career_preferences_form.dart';
import 'package:resume_job_finder/features/home/presentation/pages/home_page.dart';

import '../../../support/app_test_harness.dart';
import '../../../support/controlled_career_repositories.dart';
import '../../auth/presentation/auth_flow_test.dart'
    show keyed, field, enter, tap, messages;
import '../../home/career_home_flow_test.dart' show signedInRepository;

void main() {
  setUpAll(loadDesignFonts);

  testWidgets(
    'switches both ways live, preserves login fields and validation',
    (tester) async {
      final app = await pumpApp(
        tester,
        initialLocation: AppRoutes.login,
        locale: const Locale('ar'),
        themeMode: ThemeMode.light,
        size: const Size(390, 844),
      );
      await enter(tester, 'login_email', 'invalid@');
      await enter(tester, 'login_password', 'my-password');
      await tap(tester, 'login_submit');
      final loginState = tester.state(find.byType(LoginPage));
      final emailController = tester
          .widget<TextFormField>(field('login_email'))
          .controller;
      await tap(tester, 'app_settings');
      final semantics = tester.ensureSemantics();
      for (final language in ['en', 'ar']) {
        await tap(tester, 'settings_language_$language');
        final context = tester.element(find.byType(AppSettingsSheet));
        expect(
          Directionality.of(context),
          language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        expect(
          Theme.of(context).textTheme.bodyMedium!.fontFamily,
          language == 'ar' ? 'NotoSansArabic' : 'Inter',
        );
        expect(
          tester.getSemantics(keyed('settings_language_$language')),
          isSemantics(
            hasCheckedState: true,
            isChecked: true,
            isSelected: true,
            isInMutuallyExclusiveGroup: true,
            isFocusable: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
            hasFocusAction: true,
            label: language == 'ar' ? 'العربية' : 'English',
          ),
        );
        expect(app.settings.state.locale, Locale(language));
      }
      for (final mode in [ThemeMode.dark, ThemeMode.light, ThemeMode.system]) {
        await tap(tester, 'settings_theme_${mode.name}');
        expect(app.settings.state.themeMode, mode);
        expect(
          tester
              .widget<RadioGroup<ThemeMode>>(find.byType(RadioGroup<ThemeMode>))
              .groupValue,
          mode,
        );
        if (mode != ThemeMode.system) {
          expect(
            Theme.of(tester.element(find.byType(AppSettingsSheet))).brightness,
            mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
          );
        }
      }
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(AppSettingsSheet))).brightness,
        Brightness.dark,
      );
      await tap(tester, 'settings_close');
      expect(find.byType(AppSettingsSheet), findsNothing);
      expect(tester.state(find.byType(LoginPage)), same(loginState));
      expect(
        tester.widget<TextFormField>(field('login_email')).controller,
        same(emailController),
      );
      expect(emailController!.text, 'invalid@');
      expect(
        tester.widget<TextFormField>(field('login_password')).controller!.text,
        'my-password',
      );
      expect(find.text(messages(tester).authEmailInvalid), findsOneWidget);
      expect(
        app.router.routeInformationProvider.value.uri.path,
        AppRoutes.login,
      );
      semantics.dispose();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Home, career draft, repositories, logout and login preserve settings',
    (tester) async {
      final auth = await signedInRepository(tester);
      final user = auth.currentUser;
      final preferences = ControlledPreferencesRepository();
      final dashboard = ControlledDashboardRepository();
      final app = await pumpApp(
        tester,
        initialLocation: AppRoutes.home,
        authRepository: auth,
        preferencesRepository: preferences,
        dashboardRepository: dashboard,
        locale: const Locale('en'),
        size: const Size(390, 844),
      );
      final homeState = tester.state(find.byType(HomePage));
      await tap(tester, 'app_settings');
      await tap(tester, 'settings_language_ar');
      await tap(tester, 'settings_theme_dark');
      await tap(tester, 'settings_close');
      expect(auth.currentUser, same(user));
      expect(tester.state(find.byType(HomePage)), same(homeState));
      expect(dashboard.calls, 1);
      await tap(tester, 'home_edit_preferences');
      await enter(tester, 'career_jobTitle', 'Landscape gardener');
      await enter(tester, 'career_location', 'Alexandria');
      final formState = tester.state(find.byType(CareerPreferencesForm));
      final loadCalls = preferences.loadCalls;
      await tap(tester, 'app_settings');
      await tap(tester, 'settings_language_en');
      await tap(tester, 'settings_theme_light');
      await tap(tester, 'settings_close');
      expect(tester.state(find.byType(CareerPreferencesForm)), same(formState));
      expect(preferences.loadCalls, loadCalls);
      expect(
        tester.widget<TextFormField>(field('career_jobTitle')).controller!.text,
        'Landscape gardener',
      );
      expect(
        tester.widget<TextFormField>(field('career_location')).controller!.text,
        'Alexandria',
      );
      expect(app.router.canPop(), isTrue);
      await tap(tester, 'career_save');
      expect(find.byType(HomePage), findsOneWidget);
      expect(preferences.stored[user!.id]!.jobTitle, 'Landscape gardener');
      await tap(tester, 'auth_sign_out');
      expect(find.byType(LoginPage), findsOneWidget);
      expect(app.settings.state.locale, const Locale('en'));
      expect(app.settings.state.themeMode, ThemeMode.light);
      await tap(tester, 'app_settings');
      expect(
        tester
            .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
            .groupValue,
        'en',
      );
      await tap(tester, 'settings_close');
      await enter(tester, 'login_email', 'amina@example.com');
      await enter(tester, 'login_password', 'demo-password');
      await tap(tester, 'login_submit');
      expect(find.byType(HomePage), findsOneWidget);
      expect(app.settings.state.locale, const Locale('en'));
      expect(app.settings.state.themeMode, ThemeMode.light);
      expect(auth.currentUser, same(user));
      expect(preferences.stored[user.id]!.jobTitle, 'Landscape gardener');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('onboarding entry supports keyboard focus and dismissal', (
    tester,
  ) async {
    await pumpApp(tester, initialLocation: AppRoutes.onboarding);
    await tap(tester, 'app_settings');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.context, isNotNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(AppSettingsSheet), findsNothing);
    await tap(tester, 'onboarding_skip');
    expect(find.byType(LoginPage), findsOneWidget);
    expect(keyed('app_settings'), findsOneWidget);
  });

  for (final language in ['ar', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final layout in [
        (const Size(320, 568), 2.0),
        (const Size(390, 844), 1.0),
        (const Size(568, 320), 2.0),
      ]) {
        testWidgets(
          'settings reachable $language $theme $layout with keyboard',
          (tester) async {
            await pumpApp(
              tester,
              initialLocation: AppRoutes.login,
              locale: Locale(language),
              themeMode: theme,
              size: layout.$1,
              textScale: layout.$2,
            );
            tester.view.viewInsets = const FakeViewPadding(bottom: 120);
            addTearDown(tester.view.resetViewInsets);
            await tap(tester, 'app_settings');
            for (final key in [
              'settings_language_ar',
              'settings_language_en',
              'settings_theme_light',
              'settings_theme_dark',
              'settings_theme_system',
            ]) {
              await tester.ensureVisible(keyed(key));
              await tester.pumpAndSettle();
              expect(keyed(key).hitTestable(), findsOneWidget);
              expect(
                tester.getSize(keyed(key)).height,
                greaterThanOrEqualTo(48),
              );
              await tester.tap(keyed(key));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
            await tap(tester, 'settings_close');
            expect(find.byType(AppSettingsSheet), findsNothing);
          },
        );
      }
    }
  }
}
