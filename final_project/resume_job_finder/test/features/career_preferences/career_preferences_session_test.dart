import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/app/router/app_routes.dart';
import 'package:resume_job_finder/features/home/presentation/pages/home_page.dart';
import '../../support/test_auth_repository.dart';
import 'package:resume_job_finder/features/auth/domain/auth_user.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/login_page.dart';
import 'package:resume_job_finder/features/career_preferences/presentation/pages/career_preferences_page.dart';

import '../../support/app_test_harness.dart';
import '../../support/controlled_auth_repository.dart';
import '../../support/controlled_career_repositories.dart';
import '../auth/presentation/auth_flow_test.dart'
    show enter, field, fillSignup, messages, tap;

void main() {
  setUpAll(loadDesignFonts);

  testWidgets(
    'switching demo accounts isolates preferences and restores the owner',
    (tester) async {
      final auth = TestAuthRepository(delay: Duration.zero);
      final preferences = ControlledPreferencesRepository();
      final app = await pumpApp(
        tester,
        initialLocation: AppRoutes.signUp,
        authRepository: auth,
        preferencesRepository: preferences,
        size: const Size(390, 844),
      );
      await fillSignup(tester);
      await tap(tester, 'signup_submit');
      final firstUser = auth.currentUser!.id;
      await enter(tester, 'career_jobTitle', 'Ceramic artist');
      await enter(tester, 'career_experienceLevel', 'Master craftsperson');
      await tap(tester, 'career_save');
      expect(
        app.router.routeInformationProvider.value.uri.path,
        AppRoutes.home,
      );
      expect(app.router.canPop(), isFalse);
      await tap(tester, 'auth_sign_out');
      await tap(tester, 'auth_open_signup');
      await fillSignup(
        tester,
        email: 'second@example.com',
        name: 'Second User',
      );
      await tap(tester, 'signup_submit');
      final secondUser = auth.currentUser!.id;
      expect(secondUser, isNot(firstUser));
      for (final key in ['career_jobTitle', 'career_experienceLevel']) {
        expect(
          tester.widget<TextFormField>(field(key)).controller!.text,
          isEmpty,
        );
      }
      await enter(tester, 'career_jobTitle', 'مزارع');
      await tap(tester, 'career_save');
      expect(preferences.stored[firstUser]!.jobTitle, 'Ceramic artist');
      expect(preferences.stored[secondUser]!.jobTitle, 'مزارع');
      await tap(tester, 'auth_sign_out');
      await enter(tester, 'login_email', 'amina@example.com');
      await enter(tester, 'login_password', 'demo-password');
      await tap(tester, 'login_submit');
      await tap(tester, 'home_edit_preferences');
      expect(
        tester.widget<TextFormField>(field('career_jobTitle')).controller!.text,
        'Ceramic artist',
      );
      expect(
        tester
            .widget<TextFormField>(field('career_experienceLevel'))
            .controller!
            .text,
        'Master craftsperson',
      );
      await enter(tester, 'career_jobTitle', 'Unsaved');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(preferences.stored[firstUser]!.jobTitle, 'Ceramic artist');
      expect(app.router.canPop(), isFalse);
    },
  );

  testWidgets('login without preferences can complete setup from Home', (
    tester,
  ) async {
    final auth = TestAuthRepository(delay: Duration.zero);
    await tester.runAsync(
      () => auth.register(
        fullName: 'New User',
        email: 'new@example.com',
        password: 'demo-password',
      ),
    );
    await pumpApp(
      tester,
      initialLocation: AppRoutes.login,
      authRepository: auth,
    );
    await enter(tester, 'login_email', 'new@example.com');
    await enter(tester, 'login_password', 'demo-password');
    await tap(tester, 'login_submit');
    expect(find.byType(HomePage), findsOneWidget);
    await tap(tester, 'home_edit_preferences');
    expect(find.byType(CareerPreferencesPage), findsOneWidget);
    await enter(tester, 'career_jobTitle', 'Interpreter');
    await tap(tester, 'career_save');
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text(messages(tester).careerSaved), findsOneWidget);
  });

  testWidgets(
    'legacy preview redirects to Home and sign-out errors allow retry',
    (tester) async {
      final auth = ControlledAuthRepository()
        ..currentUser = const AuthUser(
          id: 'one',
          fullName: 'Sam',
          email: 'sam@example.com',
        )
        ..failSignOut = true;
      final app = await pumpApp(
        tester,
        initialLocation: AppRoutes.preview,
        authRepository: auth,
      );
      expect(
        app.router.routeInformationProvider.value.uri.path,
        AppRoutes.home,
      );
      expect(find.byType(HomePage), findsOneWidget);
      await tap(tester, 'auth_sign_out');
      expect(find.text(messages(tester).authUnavailable), findsOneWidget);
      expect(find.text(messages(tester).authWelcome('Sam')), findsOneWidget);
      auth.failSignOut = false;
      await tap(tester, 'auth_sign_out');
      expect(find.byType(LoginPage), findsOneWidget);
      for (final path in [
        AppRoutes.preview,
        AppRoutes.home,
        AppRoutes.careerPreferences,
      ]) {
        app.router.go(path);
        await tester.pumpAndSettle();
        expect(find.byType(LoginPage), findsOneWidget);
      }
    },
  );
}
