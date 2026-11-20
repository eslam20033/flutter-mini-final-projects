# Login and Sign Up handover

**Screens 07–08 update:** Sign Up now authenticates and opens Career Preferences, and Login opens Home. The old `/preview` URL redirects to Home. See [CAREER_HOME.md](CAREER_HOME.md) for the current navigation, repository integration, and verification. Earlier descriptions below record the previous auth handover where superseded.

**Recovery update:** Screens 05 and 06 are now implemented. See [PASSWORD_RECOVERY.md](PASSWORD_RECOVERY.md) for the current recovery contract, flow, verification, and file inventory. The verification and file lists below record the earlier Login/Sign Up pass.

Screens 03 and 04 are functional demo screens. Existing Splash, all three onboarding slides, themes, fonts, localization, shared widgets, and dependency direction are retained. No profession, industry, or prefilled personal identity is required or restricted.

## Behavior and routes

| Entry/action | Result |
| --- | --- |
| Splash → Onboarding → Skip/Get Started | `/login` |
| Login → Sign Up | Push `/sign-up`; Back or the Login link returns to the existing form |
| Direct `/sign-up` link → Back | `/login` |
| Successful registration | Creates a temporary account, returns to Login, fills only the email, and shows localized success feedback |
| Successful sign-in | `/preview`, explicitly labeled Demo session, greeting the registered name |
| Sign out | Clears the session and replaces the route with Login |
| Introduction replay | Opens slide 1; the session remains until sign-out/restart |
| Signed-out `/preview` | Redirects to Login |
| Signed-in `/login` or `/sign-up` | Redirects to the demo session |
| Forgot password | Opens `/forgot-password`, then the explicitly labeled local Reset Password simulation |
| Google / Apple | Localized unavailable-in-demo feedback; no session is created |

Login Back opens Onboarding. Onboarding's previous-slide Back behavior is unchanged. During a request, form inputs, visibility controls, submit, links, social actions, and Back are disabled. The Cubit also rejects duplicate submissions independently of button state.

## Temporary authentication

`AuthRepository` defines `register`, `signIn`, `signOut`, and `currentUser`. `AuthUser` contains only ID, full name, and email. `AuthCubit` depends only on that contract and converts typed/unknown failures into state; exception details are never displayed.

GetIt owns one lazy `MockAuthRepository`; route-owned BlocProviders create and dispose their Cubits. The mock starts with no accounts. Register first, then sign in. Names are entered by the user and support Arabic/English without a profession list or multi-word-name restriction. Email addresses are trimmed and case-normalized; passwords are compared exactly. Registration requires eight characters and matching confirmation; login does not impose a new password-length rule.

Accounts, raw password strings, and session exist **only in process memory**. There are no files, preferences, databases, network calls, or credential logs. No plaintext password is persisted. Autofill contexts are cancelled instead of requesting password saving; revealed passwords still disable suggestions and autocorrect. Restart/hot restart or a new DI container discards all demo accounts. This is **not real or secure authentication**. Use invented details. Password recovery is now a local simulation described in PASSWORD_RECOVERY.md. There is no email verification, real password recovery, social SDK, Firebase, or AI.

Common unquoted email syntax, plus-addressing and multi-label domains are supported. Format validation does not verify mailbox ownership; quoted addresses and internationalized email addresses are not supported by this demo validator.

## Future Firebase integration

Implement `AuthRepository` in `features/auth/data/`, map provider users/errors to `AuthUser`/`AuthFailure`, then replace the GetIt binding in `app/di/injection_container.dart`. Preserve the contract that registration returns an account while the UI next asks for sign-in (an adapter may need to sign out after Firebase account creation). Screens and Cubit do not need Firebase imports or rewrites.

When real session restoration, expiration, or external sign-out is introduced, add an auth-session stream and router refresh at the composition boundary. The present mock changes session only through explicit actions, which already navigate and reevaluate guards. Firebase initialization/configuration, provider password policy, email verification, and provider-backed recovery remain future work. The expanded recovery contract and adapter requirements are in PASSWORD_RECOVERY.md.

## UI, localization and design limits

Both screens reuse AppButton, AppTextField, AppCard and AppErrorState. AppButton supplies the loading indicator. AppTextField gained optional suggestion/autocorrect overrides and wrapping errors; its existing API and behavior remain compatible. Password visibility is local presentation state. Validation rules live in the domain helper and are dispatched by AuthCubit; all displayed messages come from ARBs.

English/Arabic, LTR/RTL, Blue Light and Black Dark use the existing AppSettingsCubit and theme. Switching settings preserves entered form text and translates existing errors. Scrollable forms use the available keyboard height, bounded tablet width, flexible labels and scaled text. The app bar identifies both forms as demos even before scrolling to the detailed notice.

Figma metadata, design context and screenshot requests were blocked by the account's Starter-plan MCP limit. The implementation uses documented measurements in DESIGN_SYSTEM.md, including the previously inspected Arabic-dark Login reference `1:1184`, and the existing components/palette. Exact screen layout, copy, and social-logo artwork could not be retrieved or compared. Google/Apple currently use themed text buttons; original screen-specific assets and exact Figma parity remain unverified. No new asset, package or design-system replacement was introduced.

## Verification — 2026-11-18

- `dart format` completed for all modified/new Dart source and tests.
- `flutter analyze`: **No issues found** (exit 0).
- `flutter test`: **102 tests passed** (exit 0): all 57 existing tests retained, plus 45 auth tests. Existing onboarding assertions were updated only for the intentional Login handoff and authenticated replay.
- New coverage: repository account/session behavior, duplicate email, credential errors, centralized field validation, password confirmation/visibility, Cubit loading/duplicate prevention/disposal, safe failures, complete registration/login/sign-out, direct links, Android Back events, redirects, replay, unavailable actions, and live language/theme changes.
- Layout checks cover both pages × both languages × both themes at 390×844, 320×568, 844×390, and 1024×1366. Compact/landscape cases use 2× text and simulated keyboard insets. Actions remain reachable after validation expands the form.
- Local rendered images were generated and visually inspected for both screens in both languages/themes. Ignored `build/auth_review/` holds eight PNGs and its temporary render script; its separate render test passed and is not counted in the 102-test suite.
- **No emulator verification in this pass:** `flutter devices` found no Android device; `flutter emulators` found no installed emulator. No physical-device, release-performance, or exact Figma visual verification is claimed.

## Exact files created or modified in this pass

Paths are relative to `final_project/resume_job_finder`. Earlier uncommitted foundation/onboarding work was preserved.

Created:

```text
AUTH.md
lib/features/auth/domain/auth_repository.dart
lib/features/auth/domain/auth_user.dart
lib/features/auth/domain/auth_validation.dart
lib/features/auth/data/mock_auth_repository.dart
lib/features/auth/presentation/auth_messages.dart
lib/features/auth/presentation/cubit/auth_cubit.dart
lib/features/auth/presentation/cubit/auth_state.dart
lib/features/auth/presentation/pages/login_page.dart
lib/features/auth/presentation/pages/sign_up_page.dart
lib/features/auth/presentation/widgets/auth_error_feedback.dart
lib/features/auth/presentation/widgets/auth_password_field.dart
lib/features/auth/presentation/widgets/auth_scaffold.dart
lib/features/auth/presentation/widgets/auth_social_buttons.dart
test/features/auth/data/mock_auth_repository_test.dart
test/features/auth/presentation/auth_cubit_test.dart
test/features/auth/presentation/auth_flow_test.dart
test/features/auth/presentation/auth_layout_test.dart
test/support/controlled_auth_repository.dart
```

Modified:

```text
README.md
ARCHITECTURE.md
DESIGN_SYSTEM.md
ONBOARDING.md
lib/app/di/injection_container.dart
lib/app/router/app_router.dart
lib/app/router/app_routes.dart
lib/app/view/foundation_page.dart
lib/core/widgets/app_text_field.dart
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
lib/l10n/generated/app_localizations.dart
lib/l10n/generated/app_localizations_en.dart
lib/l10n/generated/app_localizations_ar.dart
test/app/di/injection_container_test.dart
test/features/onboarding/presentation/onboarding_flow_test.dart
test/support/app_test_harness.dart
```

Generated local review artifacts (ignored): `build/auth_review/preview_test.dart` and `en_light_login.png`, `en_light_signup.png`, `en_dark_login.png`, `en_dark_signup.png`, `ar_light_login.png`, `ar_light_signup.png`, `ar_dark_login.png`, `ar_dark_signup.png` in that directory. Normal Flutter build/test caches are also regenerated by verification commands.

No existing file was deleted. No changes were made to mini_project/todo_app, Git branches, commits or remotes. Screens 07–25 remain unimplemented; recovery is documented in PASSWORD_RECOVERY.md.
