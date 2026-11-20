import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/core/theme/app_theme.dart';
import 'package:resume_job_finder/core/widgets/app_button.dart';
import 'package:resume_job_finder/core/widgets/app_card.dart';
import 'package:resume_job_finder/core/widgets/app_empty_state.dart';
import 'package:resume_job_finder/core/widgets/app_error_state.dart';
import 'package:resume_job_finder/core/widgets/app_loading.dart';
import 'package:resume_job_finder/core/widgets/app_text_field.dart';
import 'package:resume_job_finder/l10n/generated/app_localizations.dart';

Widget host(
  Widget child, {
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: theme ?? AppTheme.light,
    home: Scaffold(body: child),
  );
}

void main() {
  setUpAll(() async {
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
    final arabic = FontLoader('NotoSansArabic')
      ..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'));
    await Future.wait([inter.load(), arabic.load()]);
  });

  for (final locale in [const Locale('en'), const Locale('ar')]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'shared components render ${locale.languageCode} in ${brightness.name} with large text',
        (tester) async {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          final isArabic = locale.languageCode == 'ar';
          final theme = brightness == Brightness.dark
              ? AppTheme.dark
              : AppTheme.light;
          final label = isArabic ? 'متابعة' : 'Continue';
          await tester.pumpWidget(
            host(
              SingleChildScrollView(
                padding: const EdgeInsetsDirectional.all(16),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(label: isArabic ? 'الاسم' : 'Name'),
                      const SizedBox(height: 16),
                      AppButton(
                        label: label,
                        icon: Icons.search,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              locale: locale,
              theme: theme,
            ),
          );
          await tester.pumpAndSettle();

          final cardMaterial = tester.widget<Material>(
            find
                .descendant(
                  of: find.byType(Card),
                  matching: find.byType(Material),
                )
                .first,
          );
          expect(
            cardMaterial.color,
            brightness == Brightness.dark
                ? const Color(0xFF14171D)
                : Colors.white,
          );
          expect(
            Directionality.of(tester.element(find.byType(AppCard))),
            isArabic ? TextDirection.rtl : TextDirection.ltr,
          );

          await tester.enterText(
            find.byType(TextFormField),
            isArabic ? 'أمينة' : 'Amina',
          );
          await tester.ensureVisible(find.byType(AppButton));
          final iconX = tester.getCenter(find.byIcon(Icons.search)).dx;
          final labelX = tester.getCenter(find.text(label)).dx;
          expect(iconX, isArabic ? greaterThan(labelX) : lessThan(labelX));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('button invokes action and prevents taps while loading', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      host(AppButton(label: 'Continue', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Continue'));
    expect(taps, 1);

    await tester.pumpWidget(
      host(
        AppButton(label: 'Continue', isLoading: true, onPressed: () => taps++),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Continue'));
    expect(taps, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.pumpWidget(
      host(const AppButton(label: 'Continue', onPressed: null)),
    );
    await tester.tap(find.text('Continue'));
    expect(taps, 1);
  });

  testWidgets('field participates in form validation and saving', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    String? saved;
    await tester.pumpWidget(
      host(
        Form(
          key: formKey,
          child: AppTextField(
            label: 'Name',
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
            onSaved: (value) => saved = value,
          ),
        ),
      ),
    );
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Amina');
    expect(formKey.currentState!.validate(), isTrue);
    formKey.currentState!.save();
    expect(saved, 'Amina');
  });

  testWidgets('separate field label remains accessible to screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        host(const AppTextField(label: 'الاسم'), locale: const Locale('ar')),
      );
      await tester.pump();
      final fieldSemantics = tester.getSemantics(find.byType(TextFormField));
      expect(fieldSemantics.label, 'الاسم');
      expect(fieldSemantics.textDirection, TextDirection.rtl);
      expect(find.bySemanticsLabel('الاسم'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('loading indicator exposes a localized accessible label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        host(const AppLoading(), locale: const Locale('ar')),
      );
      await tester.pump();
      expect(find.bySemanticsLabel('جارٍ التحميل…'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('error state offers retry only when an action is supplied', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(host(AppErrorState(onRetry: () => retries++)));
    await tester.tap(find.text('Try again'));
    expect(retries, 1);

    await tester.pumpWidget(host(const AppErrorState()));
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('empty state uses Arabic text and inherited RTL direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const AppEmptyState(), locale: const Locale('ar')),
    );
    await tester.pumpAndSettle();
    expect(find.text('لا يوجد محتوى بعد'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(AppEmptyState))),
      TextDirection.rtl,
    );
  });

  testWidgets('Arabic error state fits a narrow screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      host(AppErrorState(onRetry: () {}), locale: const Locale('ar')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(AppButton));
    expect(tester.takeException(), isNull);
    expect(find.text('حاول مرة أخرى'), findsOneWidget);
  });
}
