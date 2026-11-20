# Screen 07 — Career Preferences

## Current Screen 07–08 integration — 2026-11-18

The existing Home Dashboard is ready for the local demo, so `/preview` is obsolete
as a destination and now redirects to `/home` while retaining the authentication
guard. Sign Up opens Career Preferences and its first save opens Home. Login and
successful provider adapters open Home. Home pushes the existing preferences
editor; successful edits return `true`, triggering the existing Home refresh.
Back returns without saving, and initial setup Back opens Home. Authenticated-user
state and account-specific preferences are preserved; no screen or Cubit redesign
was required.

Only the router, five existing navigation/layout test files, and these two handover
documents changed. Existing tests now verify the actual journeys without manually
navigating to Home after a save. They also assert reuse of the Home state, preference
reload after editing, user identity preservation, root Back behavior, account
isolation, and guarded legacy links. English/Arabic, LTR/RTL, Light/Dark and the
existing responsive layout matrix passed.

Verification: `dart format` completed for all six modified Dart files;
`flutter analyze` reported **No issues found**; `flutter test` reported **201 passed**.
No Android device/emulator or Figma verification was performed during this focused
integration task. No integration blocker remains for the existing mock flow;
Firebase, AI, and the existing Coming Soon dashboard actions remain out of scope.

## Earlier Screen 07-only handover

The record below describes the previous task. Its temporary `/preview` navigation
has been superseded by the integration above.

Completed by continuing the existing implementation on 2026-11-18. The worktree
already contained Screen 07, Home, and their tests. Existing changes were retained;
no branch change, reset, stash, commit, push, package installation, or edit outside
`final_project/resume_job_finder` was made. Completed authentication implementation
was left unchanged. Existing Home source, DI bindings and direct `/home` route were
preserved; no Screen 08 development was performed in this continuation.

## Working behavior

- Required preferred job title is free text. Industry, years of experience,
  experience level, preferred location, and skills/qualifications are optional.
  Experience level is also free text so different professional grading systems
  remain valid. No profession or technical-skill whitelist exists.
- Years support Western, Arabic-Indic and Persian digits, including decimals,
  from 0 to 100. Text limits are 120 characters for title, industry and level,
  160 for location, and 1,000 for qualifications. Saving trims surrounding spaces.
- Work arrangement supports Any, On-site, Hybrid and Remote.
- Loading disables interaction. Load failure offers Retry; save failure preserves
  the draft and permits another save. Invalid values produce localized errors.
  Successful saves show localized confirmation and navigate to `/preview`.
- Registration opens setup. Login and successful provider adapters open the
  existing `FoundationPage` at `/preview`, which offers **Set or edit career
  preferences**, introduction replay, and sign-out. Users without preferences can
  start setup there; users with preferences get their stored values for editing.
  The mock Google/Apple behavior is unchanged.
- Saving clears the editing route stack and returns to `/preview`; this is the
  single transition to replace when Screen 08 is approved. Back from initial
  setup opens preview without saving. Back from a pushed editor returns to the
  caller without saving. Busy setup blocks Back. Preview and preferences require
  authentication; sign-out returns to Login. Existing recovery routes remain intact.
- English/Arabic, LTR/RTL, Light/Dark, keyboard-safe scrolling and responsive
  layouts reuse existing shared components and theme tokens. Live language/theme
  changes preserve entered text, selected arrangement and validation feedback.

## Storage and Firebase handoff

`CareerPreferencesCubit` depends only on `CareerPreferencesRepository`; the UI
does not import the mock implementation. Existing GetIt registration owns one
`MockCareerPreferencesRepository`. Its in-memory map is keyed by the authenticated
user ID supplied by the router. Saved values survive navigation and sign-out/sign-in
within that process, and edits replace that account's previous preferences.
Restarting the application or resetting DI loses all preferences and demo accounts.
There is no persistent storage, Firebase connection or AI behavior.

Implement the existing `load(userId)` / `save(userId, preferences)` contract in the
data layer and replace the `CareerPreferencesRepository` GetIt binding for Firebase.
Map the entity fields, including optional `experienceLevel`, to provider data.
Enforce ownership using the authenticated Firebase UID and backend rules; accepting
a user ID parameter is not itself authorization. No form or Cubit rewrite is needed.

## Actual verification

- `dart format`: succeeded on all 15 created/modified Dart files. The first attempt
  was blocked from writing Dart configuration under AppData. After the escalation
  request was declined, formatting succeeded inside the sandbox with `APPDATA`
  scoped to `build/dart_config` for that command. It warned that the cached lint
  include could not be read; Flutter analysis below independently passed.
- Focused tests: **69 passed**, exit 0.
- `flutter analyze`: **No issues found**, exit 0.
- Full `flutter test`: **201 passed**, exit 0. All 197 existing tests retained,
  with navigation expectations updated to the temporary destination, plus four
  additional tests covering experience-level validation/editing, real demo-account
  switching, setup after Login, and preview sign-out errors/route guards.
- Existing layout matrix passed in both languages and themes at 390×844,
  320×568, 844×390 and 1024×1366. Compact/landscape checks include 2× text and
  keyboard insets. Draft preservation and error translation are widget-tested.
- Additional ignored rendering test: **1 passed**, generating eight Screen 07
  screenshots. English/light and Arabic/dark top/bottom renders were visually
  inspected. These are Flutter widget renders, not Android device captures.
- `flutter devices` found Windows, Chrome and Edge only. `flutter emulators`
  reported **No emulators available**. Android emulator verification was not performed.
- Figma metadata access was blocked by the Starter-plan MCP limit. The existing
  implementation and design system were reused; exact approved Figma geometry,
  copy and asset parity remain unverified.

## Exact file inventory for this continuation

Created:

```text
CAREER_PREFERENCES.md
test/features/career_preferences/career_preferences_session_test.dart
```

Modified existing worktree files:

```text
CAREER_HOME.md
lib/app/router/app_router.dart
lib/app/view/foundation_page.dart
lib/features/career_preferences/domain/career_preferences.dart
lib/features/career_preferences/domain/career_preferences_validation.dart
lib/features/career_preferences/presentation/cubit/career_preferences_cubit.dart
lib/features/career_preferences/presentation/widgets/career_preferences_form.dart
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
lib/l10n/generated/app_localizations.dart
lib/l10n/generated/app_localizations_en.dart
lib/l10n/generated/app_localizations_ar.dart
test/features/career_preferences/career_preferences_test.dart
test/features/home/career_home_flow_test.dart
test/features/home/career_home_layout_test.dart
test/features/auth/presentation/auth_flow_test.dart
test/features/auth/presentation/password_recovery_flow_test.dart
```

Ignored verification artifacts: `build/screen07_test_results.txt`,
`build/screen07_review/preview_test.dart`, its eight PNGs, and project-local Dart
configuration under `build/dart_config/`. Normal Flutter build/cache artifacts are
also ignored. The earlier tracked modifications and untracked project foundation
are still present and were not reset or replaced.
