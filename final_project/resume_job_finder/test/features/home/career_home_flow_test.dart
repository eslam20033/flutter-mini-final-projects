import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/app/router/app_routes.dart';

import '../../support/test_auth_repository.dart';
import 'package:resume_job_finder/features/auth/domain/auth_user.dart';
import 'package:resume_job_finder/features/auth/presentation/pages/login_page.dart';
import 'package:resume_job_finder/features/career_preferences/domain/career_preferences.dart';
import 'package:resume_job_finder/features/career_preferences/presentation/pages/career_preferences_page.dart';
import 'package:resume_job_finder/features/home/presentation/pages/home_page.dart';

import '../../support/app_test_harness.dart';
import '../../support/controlled_auth_repository.dart';
import '../../support/controlled_career_repositories.dart';
import '../auth/presentation/auth_flow_test.dart'
    show keyed, field, enter, tap, messages, fillSignup;

Future<TestAuthRepository> signedInRepository(
  WidgetTester tester, {
  String name = 'أمينة حسن',
}) async {
  final repository = TestAuthRepository(delay: Duration.zero);
  await tester.runAsync(() async {
    await repository.register(
      fullName: name,
      email: 'amina@example.com',
      password: 'demo-password',
    );
    await repository.signIn(
      email: 'amina@example.com',
      password: 'demo-password',
    );
  });
  return repository;
}

void main() {
  setUpAll(loadDesignFonts);

  for (final language in ['en', 'ar']) {
    testWidgets(
      'signup saves any profession, edits preferences and login restores Home in $language',
      (tester) async {
        final repository = TestAuthRepository(delay: Duration.zero);
        final preferences = ControlledPreferencesRepository();
        final app = await pumpApp(
          tester,
          initialLocation: AppRoutes.signUp,
          locale: Locale(language),
          size: const Size(390, 844),
          authRepository: repository,
          preferencesRepository: preferences,
        );
        await fillSignup(tester, name: 'ليلى مراد');
        await tap(tester, 'signup_submit');
        expect(find.byType(CareerPreferencesPage), findsOneWidget);
        expect(repository.currentUser!.fullName, 'ليلى مراد');
        final signedInUser = repository.currentUser;
        expect(app.router.canPop(), isFalse);
        await tap(tester, 'career_save');
        expect(find.text(messages(tester).careerTitleRequired), findsOneWidget);
        await enter(tester, 'career_jobTitle', '  Landscape gardener  ');
        await enter(tester, 'career_industry', 'Horticulture');
        await enter(tester, 'career_experience', '٣٫٥');
        await enter(
          tester,
          'career_experienceLevel',
          'Qualified horticulturist',
        );
        await enter(tester, 'career_location', 'Alexandria');
        await tap(tester, 'career_arrangement_onSite');
        await enter(
          tester,
          'career_qualifications',
          'Plant care; irrigation certification',
        );
        await tap(tester, 'career_save');
        expect(find.byType(HomePage), findsOneWidget);
        expect(find.text(messages(tester).careerSaved), findsOneWidget);
        expect(app.router.canPop(), isFalse);
        expect(
          app.router.routeInformationProvider.value.uri.path,
          AppRoutes.home,
        );
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(HomePage), findsOneWidget);
        final l10n = messages(tester);
        expect(find.text(l10n.authWelcome('ليلى مراد')), findsOneWidget);
        expect(find.text('Landscape gardener'), findsOneWidget);
        final saved = preferences.stored[repository.currentUser!.id]!;
        expect(saved.experienceYears, 3.5);
        expect(saved.experienceLevel, 'Qualified horticulturist');
        expect(saved.arrangement, WorkArrangement.onSite);
        final homeState = tester.state(find.byType(HomePage));
        final loadsBeforeEditing = preferences.loadCalls;
        await tap(tester, 'home_edit_preferences');
        expect(app.router.canPop(), isTrue);
        expect(
          tester
              .widget<TextFormField>(field('career_jobTitle'))
              .controller!
              .text,
          'Landscape gardener',
        );
        await enter(tester, 'career_jobTitle', 'فنانة خزف');
        await enter(tester, 'career_industry', '');
        await enter(tester, 'career_experience', '');
        expect(
          tester
              .widget<TextFormField>(field('career_experienceLevel'))
              .controller!
              .text,
          'Qualified horticulturist',
        );
        await enter(tester, 'career_experienceLevel', '');
        await enter(tester, 'career_location', '');
        await enter(tester, 'career_qualifications', '');
        await tap(tester, 'career_arrangement_any');
        await tap(tester, 'career_save');
        expect(find.byType(HomePage), findsOneWidget);
        expect(
          preferences.stored[repository.currentUser!.id]!.experienceLevel,
          isEmpty,
        );
        expect(tester.state(find.byType(HomePage)), same(homeState));
        expect(preferences.loadCalls, loadsBeforeEditing + 2);
        expect(repository.currentUser, same(signedInUser));
        expect(app.router.canPop(), isFalse);
        expect(find.text('فنانة خزف'), findsOneWidget);
        expect(
          preferences.stored[repository.currentUser!.id]!.experienceYears,
          isNull,
        );
        await tap(tester, 'auth_sign_out');
        expect(find.byType(LoginPage), findsOneWidget);
        await enter(tester, 'login_email', 'amina@example.com');
        await enter(tester, 'login_password', 'demo-password');
        await tap(tester, 'login_submit');
        expect(find.byType(HomePage), findsOneWidget);
        expect(app.router.canPop(), isFalse);
        expect(
          app.router.routeInformationProvider.value.uri.path,
          AppRoutes.home,
        );
        await tap(tester, 'home_edit_preferences');
        expect(
          tester
              .widget<TextFormField>(field('career_jobTitle'))
              .controller!
              .text,
          'فنانة خزف',
        );
      },
    );
  }

  testWidgets(
    'preferences loading, validation, save error and retry retain entered values',
    (tester) async {
      final auth = await signedInRepository(tester);
      final loadGate = Completer<void>();
      final repository = ControlledPreferencesRepository()
        ..loadGate = loadGate.future;
      await pumpApp(
        tester,
        initialLocation: AppRoutes.careerPreferences,
        authRepository: auth,
        preferencesRepository: repository,
        size: const Size(390, 844),
        settle: false,
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<IconButton>(keyed('career_back')).onPressed, isNull);
      loadGate.complete();
      await tester.pumpAndSettle();
      await enter(tester, 'career_jobTitle', 'Nurse');
      await enter(tester, 'career_experience', '-3');
      await tap(tester, 'career_save');
      expect(
        find.text(messages(tester).careerExperienceInvalid),
        findsOneWidget,
      );
      expect(repository.saveCalls, 0);
      await enter(tester, 'career_experience', '0');
      final saveGate = Completer<void>();
      repository
        ..saveGate = saveGate.future
        ..failSave = true;
      await tester.ensureVisible(keyed('career_save'));
      await tester.tap(keyed('career_save'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      for (final field in tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      )) {
        expect(field.enabled, isFalse);
      }
      for (final chip in tester.widgetList<ChoiceChip>(
        find.byType(ChoiceChip),
      )) {
        expect(chip.onSelected, isNull);
      }
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(CareerPreferencesPage), findsOneWidget);
      saveGate.complete();
      await tester.pumpAndSettle();
      expect(find.text(messages(tester).careerSaveError), findsOneWidget);
      expect(
        tester.widget<TextFormField>(field('career_jobTitle')).controller!.text,
        'Nurse',
      );
      expect(find.textContaining('Private'), findsNothing);
      repository
        ..saveGate = null
        ..failSave = false;
      await tap(tester, 'career_save');
      expect(find.byType(HomePage), findsOneWidget);
    },
  );

  testWidgets(
    'failed preference load retries without exposing a blank editable form',
    (tester) async {
      final repository = ControlledPreferencesRepository()..failLoad = true;
      await pumpApp(
        tester,
        initialLocation: AppRoutes.careerPreferences,
        authRepository: await signedInRepository(tester),
        preferencesRepository: repository,
      );
      expect(find.text(messages(tester).careerLoadError), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      repository.failLoad = false;
      await tester.tap(find.text(messages(tester).retry));
      await tester.pumpAndSettle();
      expect(keyed('career_jobTitle'), findsOneWidget);
    },
  );

  testWidgets(
    'dashboard loading, failure, retry and empty states show the actual user',
    (tester) async {
      final gate = Completer<void>();
      final dashboard = ControlledDashboardRepository()
        ..gate = gate.future
        ..fail = true;
      await pumpApp(
        tester,
        initialLocation: AppRoutes.home,
        authRepository: await signedInRepository(tester, name: 'Noor'),
        dashboardRepository: dashboard,
        size: const Size(390, 844),
        settle: false,
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      gate.complete();
      await tester.pumpAndSettle();
      expect(find.text(messages(tester).homeLoadError), findsOneWidget);
      dashboard.fail = false;
      await tester.tap(find.text(messages(tester).retry));
      await tester.pumpAndSettle();
      expect(find.text(messages(tester).authWelcome('Noor')), findsOneWidget);
      expect(find.text(messages(tester).homeJobsEmptyTitle), findsOneWidget);
      expect(find.text(messages(tester).homePreferencesEmpty), findsOneWidget);
      await tap(tester, 'home_edit_preferences');
      expect(find.byType(CareerPreferencesPage), findsOneWidget);
    },
  );

  testWidgets('unconnected teammate actions are disabled without placeholder dialogs', (
    tester,
  ) async {
    final repository = await signedInRepository(tester);
    await pumpApp(
      tester,
      initialLocation: AppRoutes.home,
      authRepository: repository,
      locale: const Locale('ar'),
      size: const Size(390, 844),
    );
    for (final key in [
      'home_notifications',
      'home_upload_cv',
      'home_view_jobs',
      'home_nav_cv',
      'home_nav_jobs',
      'home_nav_saved',
      'home_details_sample-care',
      'home_save_sample-care',
      'home_details_sample-education',
      'home_save_sample-education',
      'home_details_sample-trade',
      'home_save_sample-trade',
    ]) {
      await tester.ensureVisible(keyed(key));
      final target = tester.widget(keyed(key));
      if (target is IconButton) {
        expect(target.onPressed, isNull);
      } else if (target is TextButton) {
        expect(target.onPressed, isNull);
      } else {
        expect(tester.widget<FilledButton>(find.descendant(of: keyed(key), matching: find.byType(FilledButton))).onPressed, isNull);
      }
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
      expect(repository.currentUser, isNotNull);
    }
    await tap(tester, 'home_nav_home');
    expect(keyed('home_greeting').hitTestable(), findsOneWidget);
  });

  testWidgets(
    'guards, legacy preview and system Back do not re-enter auth screens',
    (tester) async {
      final app = await pumpApp(tester, initialLocation: AppRoutes.home);
      expect(find.byType(LoginPage), findsOneWidget);
      app.router.go(AppRoutes.careerPreferences);
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      await tap(tester, 'auth_open_signup');
      await fillSignup(tester);
      await tap(tester, 'signup_submit');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      await tap(tester, 'home_edit_preferences');
      await enter(tester, 'career_jobTitle', 'Unsaved draft');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Unsaved draft'), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text(messages(tester).homePreferencesEmpty), findsOneWidget);
      app.router.go(AppRoutes.preview);
      await tester.pumpAndSettle();
      expect(
        app.router.routeInformationProvider.value.uri.path,
        AppRoutes.home,
      );
      expect(app.router.canPop(), isFalse);
    },
  );

  testWidgets(
    'language and theme changes keep drafts and translate current errors',
    (tester) async {
      final app = await pumpApp(
        tester,
        initialLocation: AppRoutes.careerPreferences,
        authRepository: await signedInRepository(tester),
        locale: const Locale('en'),
        size: const Size(390, 844),
      );
      await enter(tester, 'career_industry', 'Hospitality');
      await enter(tester, 'career_experienceLevel', 'Apprentice');
      await tap(tester, 'career_save');
      final english = messages(tester).careerTitleRequired;
      app.settings
        ..setLocale(const Locale('ar'))
        ..setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text(english), findsNothing);
      expect(find.text(messages(tester).careerTitleRequired), findsOneWidget);
      expect(
        tester.widget<TextFormField>(field('career_industry')).controller!.text,
        'Hospitality',
      );
      expect(
        tester
            .widget<TextFormField>(field('career_experienceLevel'))
            .controller!
            .text,
        'Apprentice',
      );
    },
  );

  testWidgets('Home sign-out failure retains the user and permits retry', (
    tester,
  ) async {
    final repository = ControlledAuthRepository()
      ..currentUser = const AuthUser(
        id: 'one',
        fullName: 'Sam',
        email: 'sam@example.com',
      )
      ..failSignOut = true;
    await pumpApp(
      tester,
      initialLocation: AppRoutes.home,
      authRepository: repository,
    );
    await tap(tester, 'auth_sign_out');
    expect(find.text(messages(tester).authUnavailable), findsOneWidget);
    expect(find.text(messages(tester).authWelcome('Sam')), findsOneWidget);
    repository.failSignOut = false;
    await tap(tester, 'auth_sign_out');
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
