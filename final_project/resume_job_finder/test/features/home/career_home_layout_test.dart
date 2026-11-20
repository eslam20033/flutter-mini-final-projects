import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/app/router/app_routes.dart';

import 'package:resume_job_finder/features/career_preferences/presentation/pages/career_preferences_page.dart';
import 'package:resume_job_finder/features/home/presentation/pages/home_page.dart';

import '../../support/app_test_harness.dart';
import '../auth/presentation/auth_flow_test.dart' show keyed, tap, enter;
import 'career_home_flow_test.dart' show signedInRepository;

void main() {
  setUpAll(loadDesignFonts);
  final layouts = [
    (size: const Size(390, 844), scale: 1.0, keyboard: 0.0),
    (size: const Size(320, 568), scale: 2.0, keyboard: 200.0),
    (size: const Size(844, 390), scale: 2.0, keyboard: 140.0),
    (size: const Size(1024, 1366), scale: 1.0, keyboard: 0.0),
  ];
  for (final language in ['en', 'ar']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final layout in layouts) {
        testWidgets(
          'career and Home $language ${theme.name} ${layout.size} remain reachable',
          (tester) async {
            final app = await pumpApp(
              tester,
              initialLocation: AppRoutes.careerPreferences,
              authRepository: await signedInRepository(tester),
              locale: Locale(language),
              themeMode: theme,
              size: layout.size,
              textScale: layout.scale,
            );
            tester.view.viewInsets = FakeViewPadding(bottom: layout.keyboard);
            addTearDown(tester.view.resetViewInsets);
            await tester.pumpAndSettle();
            final context = tester.element(find.byType(CareerPreferencesPage));
            expect(
              Directionality.of(context),
              language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            );
            expect(
              Theme.of(context).brightness,
              theme == ThemeMode.dark ? Brightness.dark : Brightness.light,
            );
            await tap(tester, 'career_save');
            await enter(
              tester,
              'career_jobTitle',
              'Professional role with a long descriptive title',
            );
            await enter(
              tester,
              'career_location',
              'A long region name with several descriptive words',
            );
            await tester.ensureVisible(keyed('career_save'));
            await tester.pumpAndSettle();
            expect(keyed('career_save').hitTestable(), findsOneWidget);
            tester.view.resetViewInsets();
            await tap(tester, 'career_save');
            expect(find.byType(HomePage), findsOneWidget);
            // The save confirmation temporarily covers the bottom of compact
            // viewports. Check content reachability after it dismisses.
            await tester.pump(const Duration(seconds: 5));
            await tester.pumpAndSettle();
            await tester.ensureVisible(keyed('home_edit_preferences'));
            expect(
              keyed('home_edit_preferences').hitTestable(),
              findsOneWidget,
            );
            expect(
              app.router.routeInformationProvider.value.uri.path,
              AppRoutes.home,
            );
            expect(find.byType(HomePage), findsOneWidget);
            final homeContext = tester.element(find.byType(HomePage));
            expect(
              Directionality.of(homeContext),
              language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            );
            expect(
              Theme.of(homeContext).brightness,
              theme == ThemeMode.dark ? Brightness.dark : Brightness.light,
            );
            for (final key in [
              'home_upload_cv',
              'home_edit_preferences',
              'home_details_sample-trade',
              'home_nav_jobs',
            ]) {
              await tester.ensureVisible(keyed(key));
              await tester.pumpAndSettle();
              expect(keyed(key).hitTestable(), findsOneWidget);
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
