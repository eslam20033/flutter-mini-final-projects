# Splash and Onboarding handover

Screens 01 and 02a–02c are implemented. The application serves all professions and industries. Introductory job titles, skills, company marks, and percentages are illustrative content, never user data, supported-career lists, or matching rules. Future opportunities and skills belong to feature data contracts.

## Flow and ownership

| Path / name | Page | Behavior |
| --- | --- | --- |
| `/` / `start` | SplashPage | Introduces branding, then opens onboarding once |
| `/onboarding` / `onboarding` | OnboardingPage | Resume → Analysis → Matching |
| `/login` / `login` | LoginPage | Skip/Get Started destination; demo authentication is documented in AUTH.md |
| `/preview` / `preview` | FoundationPage | Temporary signed-in destination with sign-out and introduction replay |

All route transitions are callbacks composed by the existing GoRouter. Intro pages do not access GetIt, repositories, or navigation APIs. Existing DI, settings Cubit, app theme, localization, and deep-link behavior are retained.

- Flutter binding/DI initialization finishes in the existing startup before Splash builds. Its 1.2-second animation has no additional timer delay and represents an introduction, not backend work. Reduced motion skips the animation. A completion guard and controller disposal prevent repeated or stale navigation.
- A local PageController and page index handle Next, swipes, indicators, and transitions. Rapid Next taps cannot skip a slide. There is no shared business state requiring another Cubit.
- Android Back from slide 2/3 returns to the previous slide. Slide 1 retains normal platform Back behavior.
- Skip and Get Started use `goNamed` to open Login; completed intro routes are not retained in the navigation stack.
- A fresh launch shows the introduction again. No completion persistence is needed for this demo. Decide the first-run policy when the real authentication entry exists; do not infer authentication from onboarding completion.
- Screens 03/04 are now connected through `OnboardingPage.onCompleted` in `app_router.dart`. Auth/database calls remain outside these widgets. See [AUTH.md](AUTH.md).

## Feature structure

```text
lib/features/
  splash/presentation/
    pages/splash_page.dart
    widgets/splash_background.dart
    widgets/splash_branding.dart
  onboarding/presentation/
    models/onboarding_step.dart
    pages/onboarding_page.dart
    widgets/
      onboarding_slide.dart
      onboarding_indicators.dart
      illustration_canvas.dart
      resume_illustration.dart
      analysis_illustration.dart
      matching_illustration.dart
      match_score_indicator.dart
```

These presentation-only features intentionally have no empty domain/data layers. Shared asset paths live in `core/assets/intro_assets.dart`. The existing AppButton gained a decorative trailing adornment for the navigation arrow; it preserves button semantics. Matching artwork reuses AppCard.

## Visual reference and intentional changes

The design metadata identifies these 390 × 844 frames:

| Variant | Splash | Resume | Analysis | Matching |
| --- | --- | --- | --- | --- |
| English light | 1:2183 | 1:2197 | 1:2222 | 1:2249 |
| English dark | 1:3273 | 1:3287 | 1:3312 | 1:3339 |
| Arabic light | 1:3 | 1:17 | 1:42 | 1:69 |
| Arabic dark | 1:1093 | 1:1107 | 1:1132 | 1:1159 |

Full rendered references and design context were retrieved for English light Splash, Analysis, and Matching. Metadata supplied geometry and layer names for the other variants. Further requests hit the Figma account's call limit. This implementation therefore does not claim exact visual parity.

Confirmed geometry includes the 86px splash logo, 47px sparkle, 260px illustration circle, 24px onboarding headings, 13px body text, 8px page indicators, and 22px page insets. Controls use the existing shared minimum 52px height and 14px corners. Native system status/navigation bars remain native.

Intentional product changes requested by the user:

- Technical badges became localized Experience, Skills, Goals, and Strengths.
- The company initial and Flutter Developer/Cairo example became a briefcase, Recommended opportunity, and an explicit Illustrative example caption.
- Matching copy is career-neutral in both languages.
- The segmented match ring became `MatchScoreIndicator(percentage: ...)`. It uses a single native determinate arc, rounded ends, a neutral track, and a centered localized percentage. The illustration's 92 is a named presentation-only example, with no calculation or storage. The widget accepts 0–100 and can display future supplied values.

Existing design-system accessibility choices are retained: solid primary buttons and readable muted/action text instead of the source gradients and low-contrast text. See [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md).

Remaining reference gaps:

- The resume person vector, exact card decoration, and complete English resume copy could not be retrieved. The layout follows metadata; a 22px Material outline person icon and theme-derived card styling are used. Resume copy is reconstructed and localized.
- Complete Arabic source paragraphs and the splash tagline were unavailable beyond truncated metadata. Current Arabic copy is a coherent translation/adaptation requiring final editorial review.
- Dark decorative fills and the exact dark splash gradient were not retrieved. They derive from the existing approved dark palette while preserving known geometry.
- The design does not specify all responsive layouts or accessibility states. Exact font binaries/versions also remain unverified, as noted in the existing design-system documentation.

Original available vectors and provenance are listed in [assets/intro/README.md](assets/intro/README.md). The only new direct dependency is `flutter_svg: ^2.4.0`, for those original vector assets. No font, storage, backend, or AI package was added.

## Localization, themes, and responsive layout

All visible strings and accessibility descriptions use the existing ARBs, including decorative examples. Percentage formatting uses the existing intl/localization generator. Brand lines remain in English in both locales, following the supplied branding references.

Inter and Noto Sans Arabic remain bundled locally. The existing AppSettingsCubit can switch locale and ThemeMode at runtime without resetting the route or current slide. Arabic reverses page gestures, indicator order, action placement, and the forward arrow; text inherits RTL. Decorative illustration positions retain the reference geometry in both languages.

Page content scrolls vertically when space is limited; footer actions remain accessible. Text and controls scale with accessibility settings. Illustration labels behave as part of a fixed design canvas and are represented to assistive technology by a localized image description. This scaling exception is confined to decorative artwork.

## Verification

Original screens 01/02 verification on Flutter 3.47.6 / Dart 3.13.5 (before auth; see AUTH.md for current results):

- `flutter pub get`: succeeded.
- `dart format` on changed Dart files: completed.
- `flutter analyze`: **No issues found**.
- `flutter test`: **57 tests passed**.

The existing 27 tests remain, with startup/navigation expectations adapted to the new routes. Thirty additional tests cover:

- Splash completion once, disposal, and reduced motion.
- Next, Skip on the first/last slide, Get Started, replay, swipes and Back in English/Arabic, duplicate taps, button semantics, runtime settings changes, and neutral localized examples.
- Both languages × both themes × 390×844, 320×568, and 844×390 layouts, including 2× text scaling on compact/landscape cases.
- Actual rendered pixels around the match arc in both languages/themes, its remaining neutral track, rounded-cap configuration, input updates, label formatting, and horizontal centering.

Local visual captures were rendered for all four intro screens in both languages/themes. Review artifacts live under ignored `build/intro_review/`; they are not required application assets or permanent test fixtures.

The debug APK built, installed, and ran on connected Android 9 / API 28 emulator `emulator-5554` (V2307A, x64). English/light emulator inspection verified onboarding visuals, the continuous ring, Next, swipe, previous-slide Back, Get Started, replay, and Skip. Arabic/dark and enlarged layouts were verified in widget/rendering tests, not by changing the emulator's system preferences. Release/profile performance, physical devices, newer Android predictive gestures, and other platform builds were not verified. The emulator emitted non-fatal Android/graphics compatibility logs; the app remained usable.

## Run and review on Android

From the repository root:

```sh
cd final_project/resume_job_finder
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Use the actual device ID printed by `flutter devices`. If none is connected, start an Android Virtual Device in Android Studio's Device Manager, or use `flutter emulators` and `flutter emulators --launch <id>` for an installed AVD.

Check automatic Splash → Resume navigation, Next → Analysis, swipe → Matching, the continuous ring, Android Back → Analysis, and Get Started/Skip → Login. Register a demo account and sign in to reach the temporary preview. Replay returns to slide 1. Hot restart/relaunch replays Splash and clears demo accounts. Change the device language/theme or the existing AppSettingsCubit overrides to review the other variants.

The Login handoff is implemented. Remaining source-design gaps above are still documented; no architecture rewrite was needed.

## Exact changed-file inventory

Paths below are relative to `final_project/resume_job_finder`, compared with the completed foundation/design-system snapshot at the start of this task. Prior unrelated uncommitted foundation work was preserved.

Created:

```text
ONBOARDING.md
assets/intro/README.md
assets/intro/analysis_core.svg
assets/intro/analysis_ring.svg
assets/intro/arrow_forward.svg
assets/intro/illustration_circle.svg
assets/intro/indicator_active.svg
assets/intro/indicator_inactive.svg
assets/intro/spark_blue.svg
assets/intro/spark_white.svg
assets/intro/splash_circle_large.svg
assets/intro/splash_circle_small.svg
lib/core/assets/intro_assets.dart
lib/features/onboarding/presentation/models/onboarding_step.dart
lib/features/onboarding/presentation/pages/onboarding_page.dart
lib/features/onboarding/presentation/widgets/analysis_illustration.dart
lib/features/onboarding/presentation/widgets/illustration_canvas.dart
lib/features/onboarding/presentation/widgets/match_score_indicator.dart
lib/features/onboarding/presentation/widgets/matching_illustration.dart
lib/features/onboarding/presentation/widgets/onboarding_indicators.dart
lib/features/onboarding/presentation/widgets/onboarding_slide.dart
lib/features/onboarding/presentation/widgets/resume_illustration.dart
lib/features/splash/presentation/pages/splash_page.dart
lib/features/splash/presentation/widgets/splash_background.dart
lib/features/splash/presentation/widgets/splash_branding.dart
test/features/onboarding/presentation/match_score_indicator_test.dart
test/features/onboarding/presentation/onboarding_flow_test.dart
test/features/onboarding/presentation/onboarding_layout_test.dart
test/features/splash/presentation/splash_page_test.dart
test/support/app_test_harness.dart
```

Modified:

```text
ARCHITECTURE.md
DESIGN_SYSTEM.md
README.md
lib/app/router/app_router.dart
lib/app/router/app_routes.dart
lib/app/view/foundation_page.dart
lib/core/theme/app_colors.dart
lib/core/widgets/app_button.dart
lib/l10n/app_ar.arb
lib/l10n/app_en.arb
lib/l10n/generated/app_localizations.dart
lib/l10n/generated/app_localizations_ar.dart
lib/l10n/generated/app_localizations_en.dart
pubspec.lock
pubspec.yaml
test/widget_test.dart
```

No pre-existing file was deleted. No changes were made to `mini_project/todo_app`, branches, commits, or remotes.
