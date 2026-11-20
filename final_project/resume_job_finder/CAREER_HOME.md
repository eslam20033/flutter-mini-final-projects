# Career Preferences and Home Dashboard

> Integration verified on 2026-11-18: Sign Up → Career Preferences → Home;
> Login → Home; Home → Career Preferences → the same Home instance with refreshed
> preferences. `/preview` is now a guarded compatibility redirect to `/home`.
> Formatting completed, analysis found no issues, and all 201 tests passed.
> See [CAREER_PREFERENCES.md](CAREER_PREFERENCES.md) for the integration update.
> Verification figures below describe the earlier implementation session.

Screens 07 and 08 are implemented using the existing design system, localization, GoRouter, GetIt, and Cubit conventions. Screens 01–06 remain functional. No package, Firebase/AI connection, or screen 09–25 implementation was added.

## Behavior and integration

- Sign Up registers the account, then signs in through the existing AuthRepository before opening `/career-preferences`. AuthCubit exposes this as the optional `signInAfterRegistration` flag; the repository's separate register/sign-in contract is preserved. If account creation succeeds but sign-in fails, localized feedback directs the user to Sign in.
- Saving preferences opens `/home`. Existing-account Login and successful social-provider adapters also open Home. `/preview` remains a redirect for old links. Home and preferences require a signed-in user.
- Home shows the actual AuthCubit user's name. Edit preferences pushes the form with stored values, saves return to Home and reload its summary, and Back leaves stored values unchanged. Back from the initial preferences screen opens Home without saving; Home offers the setup entry point again. Home is a root route, so Back cannot reopen a stale authentication form.
- Job title is required free text. Industry, location, qualifications, and experience are optional. Work arrangement defaults to Any. There is no profession, industry, or skills whitelist. Years accept Western, Arabic-Indic, and Persian digits and decimals from 0 to 100. Text limits are 120 characters for title/industry, 160 for location, and 1,000 for qualifications.
- Preferences are stored by user ID in memory. They survive navigation and sign-out/sign-in in the same app process. Restarting the app or resetting the DI container discards accounts and preferences. No credentials or preferences are written to storage.
- Home supports loading, retryable errors, missing preferences, empty recommendations, sample listings, and pull-to-refresh. CV upload, notification, job details, save-job, Jobs, CV, and Saved actions show localized Coming Soon dialogs. They perform no upload, analysis, application, or save operation.
- Sample listings cover healthcare, education, and skilled trades. ARB strings supply sample content, and both the section notice and individual cards label it as illustrative. There are no fabricated match scores, live vacancies, or CV analysis results.

For Firebase, implement `CareerPreferencesRepository` and `DashboardRepository` in their data folders and replace the two GetIt bindings. Use the authenticated provider UID and access rules for preferences; the user ID parameter alone is not authorization. `JobPreview` accepts arbitrary provider title/employer/location strings; `SampleJob` identifies only localized mock fixtures and does not restrict real professions. Replace the Coming Soon callbacks as teammates provide screens 09–25. The forms, states, and shared UI do not depend on either mock implementation. Real auth-session restoration/router refresh remains a separate integration task.

## Verification — 2026-11-18

- `dart format`: completed on changed source, generated localization, and tests.
- `flutter analyze`: **No issues found**, exit 0.
- `flutter test`: **197 passed**, exit 0: the previous 159 tests retained plus 38 new tests. Existing navigation assertions now follow Preferences/Home, and the recovery tests still exercise the complete recovery journey.
- Coverage includes validation, optional/cleared values, saving/editing, per-account isolation, failures/retry, disposal and concurrent requests, registration/session handoff, personalized names, route guards/Back, sample/empty data, every unavailable dashboard action, and live language/theme changes.
- Both screens were checked in English/Arabic, LTR/RTL, Light/Dark, at phone, compact, landscape, and tablet sizes; compact cases include 2× text and keyboard insets. An additional ignored rendering test passed and produced top/bottom screenshots under `build/career_home_review/`.
- Figma design-context and screenshot requests were blocked by the Starter-plan MCP limit. Existing components and documented design tokens were used. Exact Figma geometry, screen-specific copy, and asset parity remain unverified.
- **No Android emulator verification:** Flutter found Windows/Chrome/Edge only; `flutter emulators` reported no emulators. Widget-based layout and Back checks are not device verification.

## File inventory

Created:

```text
CAREER_HOME.md
lib/features/career_preferences/domain/career_preferences.dart
lib/features/career_preferences/domain/career_preferences_repository.dart
lib/features/career_preferences/domain/career_preferences_validation.dart
lib/features/career_preferences/data/mock_career_preferences_repository.dart
lib/features/career_preferences/presentation/career_preferences_messages.dart
lib/features/career_preferences/presentation/cubit/career_preferences_cubit.dart
lib/features/career_preferences/presentation/cubit/career_preferences_state.dart
lib/features/career_preferences/presentation/pages/career_preferences_page.dart
lib/features/career_preferences/presentation/widgets/career_preferences_form.dart
lib/features/home/domain/dashboard_repository.dart
lib/features/home/domain/job_preview.dart
lib/features/home/data/mock_dashboard_repository.dart
lib/features/home/presentation/cubit/home_cubit.dart
lib/features/home/presentation/pages/home_page.dart
lib/features/home/presentation/widgets/home_content.dart
lib/features/home/presentation/widgets/home_feedback.dart
lib/features/home/presentation/widgets/home_job_card.dart
lib/features/home/presentation/widgets/home_navigation.dart
lib/features/home/presentation/widgets/home_preferences_card.dart
test/features/career_preferences/career_preferences_test.dart
test/features/home/home_cubit_test.dart
test/features/home/career_home_flow_test.dart
test/features/home/career_home_layout_test.dart
test/support/controlled_career_repositories.dart
```

Modified:

```text
AUTH.md
PASSWORD_RECOVERY.md
lib/app/di/injection_container.dart
lib/app/router/app_router.dart
lib/app/router/app_routes.dart
lib/features/auth/domain/auth_repository.dart
lib/features/auth/presentation/auth_messages.dart
lib/features/auth/presentation/cubit/auth_cubit.dart
lib/features/auth/presentation/pages/sign_up_page.dart
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
lib/l10n/generated/app_localizations.dart
lib/l10n/generated/app_localizations_en.dart
lib/l10n/generated/app_localizations_ar.dart
test/app/di/injection_container_test.dart
test/features/auth/presentation/auth_cubit_test.dart
test/features/auth/presentation/auth_flow_test.dart
test/features/auth/presentation/password_recovery_flow_test.dart
test/features/onboarding/presentation/onboarding_flow_test.dart
test/support/app_test_harness.dart
```

Ignored review artifacts: `build/career_home_review/preview_test.dart` and 16 PNGs. Earlier uncommitted work was preserved. No file deletion, branch change, commit, push, or change to `mini_project/todo_app` was made.
