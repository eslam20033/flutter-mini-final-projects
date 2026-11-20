import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/app/router/app_routes.dart';
import 'package:resume_job_finder/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:resume_job_finder/features/splash/presentation/pages/splash_page.dart';

import '../../../support/app_test_harness.dart';

void main() {
  setUpAll(loadDesignFonts);

  final layouts = [
    (name: 'reference', size: const Size(390, 844), scale: 1.0),
    (name: 'small with enlarged text', size: const Size(320, 568), scale: 2.0),
    (
      name: 'landscape with enlarged text',
      size: const Size(844, 390),
      scale: 2.0,
    ),
  ];

  for (final locale in [const Locale('en'), const Locale('ar')]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      for (final layout in layouts) {
        testWidgets(
          '${locale.languageCode} ${mode.name} ${layout.name} renders all intro screens',
          (tester) async {
            final app = await pumpApp(
              tester,
              locale: locale,
              themeMode: mode,
              size: layout.size,
              textScale: layout.scale,
              settle: false,
            );
            expect(find.byType(SplashPage), findsOneWidget);
            await tester.pumpAndSettle();
            expect(find.byType(OnboardingPage), findsOneWidget);
            final context = tester.element(find.byType(OnboardingPage));
            expect(
              Directionality.of(context),
              locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            );
            expect(
              Theme.of(context).brightness,
              mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
            );

            for (var index = 0; index < 3; index++) {
              final title = find.byKey(ValueKey('onboarding_title_$index'));
              await tester.ensureVisible(title);
              await tester.pumpAndSettle();
              expect(title, findsOneWidget);
              expect(tester.takeException(), isNull);
              final action = find.byKey(
                ValueKey(
                  index == 2 ? 'onboarding_get_started' : 'onboarding_next',
                ),
              );
              expect(action.hitTestable(), findsOneWidget);
              if (index < 2) {
                await tester.tap(action);
                await tester.pumpAndSettle();
              }
            }
            expect(
              app.router.routeInformationProvider.value.uri.path,
              AppRoutes.onboarding,
            );
          },
        );
      }
    }
  }
}
