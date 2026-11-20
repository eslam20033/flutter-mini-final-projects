import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:resume_job_finder/app/app.dart';
import 'package:resume_job_finder/app/di/injection_container.dart';
import 'package:resume_job_finder/app/router/app_routes.dart';
import 'package:resume_job_finder/features/app_settings/presentation/cubit/app_settings_cubit.dart';
import 'package:resume_job_finder/features/auth/domain/auth_repository.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/login_page.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/reset_password_page.dart';
import 'package:resume_job_finder/features/home/presentation/pages/home_page.dart';
import 'package:resume_job_finder/features/onboarding/presentation/pages/onboarding_page.dart';

import '../features/auth/presentation/auth_flow_test.dart'
    show field, enter, tap, fillSignup, messages;
import '../support/app_test_harness.dart' show loadDesignFonts;

void main() {
  setUpAll(loadDesignFonts);
  for (final language in ['en', 'ar']) {
    testWidgets('runtime GetIt bindings complete flows A-H in $language', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final services = GetIt.asNewInstance();
      configureDependencies(services);
      final settings = services<AppSettingsCubit>()
        ..setLocale(Locale(language))
        ..setThemeMode(ThemeMode.light);
      final router = services<GoRouter>();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await settings.close();
        await services.reset();
      });
      await tester.pumpWidget(
        BlocProvider.value(
          value: settings,
          child: ResumeJobFinderApp(router: router),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingPage), findsOneWidget);
      await tap(tester, 'onboarding_next');
      await tap(tester, 'onboarding_next');
      await tap(tester, 'onboarding_get_started');
      expect(find.byType(LoginPage), findsOneWidget);
      await tap(tester, 'auth_open_signup');
      await fillSignup(tester, name: 'Amina');
      await tap(tester, 'signup_submit');
      await enter(tester, 'career_jobTitle', 'Landscape gardener');
      await tap(tester, 'career_save');
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text(messages(tester).authWelcome('Amina')), findsOneWidget);
      expect(find.text(messages(tester).homeJobsEmptyTitle), findsOneWidget);
      final home = tester.state(find.byType(HomePage));
      await tap(tester, 'home_edit_preferences');
      await enter(tester, 'career_jobTitle', 'فنانة خزف');
      settings
        ..setLocale(Locale(language == 'en' ? 'ar' : 'en'))
        ..setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextFormField>(field('career_jobTitle')).controller!.text,
        'فنانة خزف',
      );
      await tap(tester, 'career_save');
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(HomePage)), same(home));
      expect(find.text('فنانة خزف'), findsOneWidget);
      final context = tester.element(find.byType(HomePage));
      expect(
        Directionality.of(context),
        language == 'en' ? TextDirection.rtl : TextDirection.ltr,
      );
      expect(
        Theme.of(context).scaffoldBackgroundColor,
        const Color(0xFF090B0F),
      );
      await tap(tester, 'auth_sign_out');
      await tap(tester, 'auth_open_signup');
      await fillSignup(tester, name: 'Sam', email: 'sam@example.com');
      await tap(tester, 'signup_submit');
      expect(
        tester.widget<TextFormField>(field('career_jobTitle')).controller!.text,
        isEmpty,
      );
      await enter(tester, 'career_jobTitle', 'Teacher');
      await tap(tester, 'career_save');
      expect(find.text(messages(tester).authWelcome('Sam')), findsOneWidget);
      expect(find.text('فنانة خزف'), findsNothing);
      await tap(tester, 'auth_sign_out');
      await enter(tester, 'login_email', 'amina@example.com');
      await enter(tester, 'login_password', 'demo-password');
      await tap(tester, 'login_submit');
      expect(find.text(messages(tester).authWelcome('Amina')), findsOneWidget);
      expect(find.text('فنانة خزف'), findsOneWidget);
      expect(find.text('Teacher'), findsNothing);
      await tap(tester, 'auth_sign_out');
      await tap(tester, 'auth_forgot_password');
      await enter(tester, 'forgot_email', 'amina@example.com');
      await tap(tester, 'forgot_submit');
      expect(find.byType(ResetPasswordPage), findsOneWidget);
      await enter(tester, 'reset_password', 'updated-password');
      await enter(tester, 'reset_confirmation', 'updated-password');
      await tap(tester, 'reset_submit');
      await tap(tester, 'reset_success_login');
      await enter(tester, 'login_email', 'amina@example.com');
      await enter(tester, 'login_password', 'demo-password');
      await tap(tester, 'login_submit');
      expect(find.text(messages(tester).authInvalidCredentials), findsWidgets);
      await enter(tester, 'login_password', 'updated-password');
      await tap(tester, 'login_submit');
      expect(find.byType(HomePage), findsOneWidget);
      expect(
        services<AuthRepository>().currentUser?.email,
        'amina@example.com',
      );
      expect(find.text('فنانة خزف'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
      expect(tester.takeException(), isNull);
    });
  }
}
