import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/features/app_settings/presentation/cubit/app_settings_cubit.dart';
import 'package:resume_job_finder/features/app_settings/presentation/cubit/app_settings_state.dart';

void main() {
  late AppSettingsCubit cubit;

  setUp(() => cubit = AppSettingsCubit());
  tearDown(() => cubit.close());

  test('defaults to device language and system theme', () {
    expect(cubit.state.locale, isNull);
    expect(cubit.state.themeMode, ThemeMode.system);
  });

  test('normalizes locale and preserves independent preferences', () {
    cubit.setThemeMode(ThemeMode.dark);
    cubit.setLocale(const Locale('ar', 'EG'));
    expect(cubit.state.locale, const Locale('ar'));
    expect(cubit.state.themeMode, ThemeMode.dark);

    cubit.setThemeMode(ThemeMode.light);
    expect(cubit.state.locale, const Locale('ar'));
    cubit.setLocale(null);
    expect(cubit.state.locale, isNull);
    expect(cubit.state.themeMode, ThemeMode.light);
  });

  test('rejects unsupported languages without changing state', () {
    expect(() => cubit.setLocale(const Locale('fr')), throwsArgumentError);
    expect(cubit.state, const AppSettingsState());
  });

  test(
    'emits meaningful changes without repeating identical settings',
    () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const AppSettingsState(themeMode: ThemeMode.dark),
          const AppSettingsState(
            locale: Locale('ar'),
            themeMode: ThemeMode.dark,
          ),
        ]),
      );

      cubit.setThemeMode(ThemeMode.dark);
      cubit.setThemeMode(ThemeMode.dark);
      cubit.setLocale(const Locale('ar'));
      await expectation;
    },
  );
}
