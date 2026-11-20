# Architecture and team handover

This project is the Flutter foundation for the Automated Resume Matching & Job Finder app. Screens 01 (Splash), 02 (three Onboarding slides), 03 (Login), and 04 (Sign Up) use its navigation, dependency injection, localization, themes, and reusable UI. Authentication is an in-memory demo behind a repository contract; a temporary signed-in page and unknown-route fallback complete the route tree. Resume processing, job searching, matching logic, Firebase, and AI are not implemented. The product supports all professions; future job titles and skills must come from feature data, not onboarding examples. See [AUTH.md](AUTH.md) for the auth handover.

## Getting started

Run these commands from `final_project/resume_job_finder`:

```sh
flutter pub get
flutter gen-l10n
dart format lib test
flutter analyze
flutter test
flutter run
```

The foundation was developed with Flutter **3.47.6 stable / Dart 3.13.5**. The existing Dart constraint `^3.13.4`, application name, version `1.0.0+1`, and platform scaffolds are preserved. Use the same Flutter version across the team initially. The existing platform files were complete, so `flutter create` was unnecessary.

Track `pubspec.lock` for reproducible application dependencies. The project-local `.gitignore` overrides the repository-wide lockfile ignore rule. No code-generation package or build runner is required; localization uses Flutter's built-in generator.

## Current structure

```text
lib/
  main.dart                          # Binding initialization and root composition
  app/
    app.dart                         # MaterialApp.router and settings binding
    di/injection_container.dart      # GetIt registrations and ownership
    router/
      app_router.dart                # Route tree and error destination
      app_routes.dart                # Stable route names and paths
    view/
      foundation_page.dart           # Explicit temporary signed-in preview
      route_not_found_page.dart      # Localized navigation fallback
  core/
    assets/intro_assets.dart          # Bundled intro vector paths
    localization/l10n_extension.dart  # context.l10n convenience getter
    theme/
      app_colors.dart                # Confirmed colors and readable variants
      app_spacing.dart               # Shared component/layout spacing
      app_theme.dart                 # Material 3 light/dark component themes
    widgets/
      app_button.dart
      app_card.dart
      app_text_field.dart
      app_loading.dart
      app_error_state.dart
      app_empty_state.dart
  features/
    README.md                        # New feature directory template
    splash/presentation/             # Splash page and branding/background widgets
    onboarding/presentation/         # PageView, slide enum, illustrations and score widget
    auth/
      domain/                        # User, repository contract, failures, validation
      data/mock_auth_repository.dart # Volatile demo accounts and session
      presentation/                  # AuthCubit, Login/Sign Up, feature widgets
    app_settings/
      README.md
      presentation/cubit/
        app_settings_cubit.dart      # In-memory language/theme selection
        app_settings_state.dart      # Immutable, value-equal UI state
  l10n/
    app_en.arb                       # English source and message descriptions
    app_ar.arb                       # Arabic translations
    generated/                       # Generated Dart; do not edit by hand
test/
  widget_test.dart                    # Startup, navigation, locales and themes
  app/di/injection_container_test.dart
  core/localization/translations_test.dart
  core/widgets/shared_widgets_test.dart
  core/theme/app_theme_test.dart
  features/app_settings/presentation/cubit/app_settings_cubit_test.dart
  features/splash/presentation/splash_page_test.dart
  features/onboarding/presentation/   # Flow, responsive layout and arc rendering tests
  features/auth/                      # Repository, Cubit, form/flow and layout tests
  support/app_test_harness.dart       # Isolated router/settings and bundled fonts
l10n.yaml
ARCHITECTURE.md
DESIGN_SYSTEM.md
ONBOARDING.md
AUTH.md
README.md
assets/fonts/                        # Inter, Noto Sans Arabic, and licenses
assets/intro/                        # Original Figma SVGs and provenance
```

The existing `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`, and analyzer configuration remain. Android declares RTL support; iOS and macOS declare English and Arabic bundle localizations.

## Feature-first boundaries

Organize product code by capability. `auth` is implemented; `resume`, `jobs`, `matching`, and `profile` remain suggestions for future assignments. Do not create a top-level folder per screen number or a global collection of all Cubits/repositories.

For a feature with data, use:

```text
features/<feature>/
  domain/
    entities/
    repositories/      # Abstract contracts, pure Dart
  data/
    models/            # External DTOs and entity conversion
    datasources/       # SDK, API, file, or local storage access
    repositories/      # Concrete implementations of domain contracts
  presentation/
    cubit/
    pages/
    widgets/
```

Add directories when they contain real code. A presentational feature does not need an empty domain/data layer. App settings currently has only presentation because it changes UI preferences without persistence or business rules.

Dependency direction:

```text
presentation -> domain <- data
app composition -> presentation + domain + data
features -> core
core must not depend on features or app
```

- Domain entities and repository interfaces do not import Flutter, GetIt, Firebase, or transport DTOs.
- Cubits receive repository interfaces through constructors. They translate results into immutable UI state.
- Pages and widgets read state and dispatch user intent. They do not query databases, read files, or resolve repositories.
- Data implementations convert external models and errors into the feature's domain contracts.
- `app/` is the composition boundary: it connects interfaces, implementations, Cubits, and routes.
- Keep feature-only widgets inside the feature. Move something to `core/` only when it is useful across features.
- Add a use case only for business rules or orchestration that merit reuse. Avoid generic base repositories, base Cubits, universal result wrappers, and pass-through use cases.

## Dependency injection and lifecycle

`main()` initializes Flutter bindings, calls `configureDependencies(getIt)`, and provides an `AppSettingsCubit` above `ResumeJobFinderApp`. The app takes its router explicitly; it does not look up dependencies in `build()`.

Current registrations:

| Type | Lifetime | Owner |
| --- | --- | --- |
| `AppSettingsCubit` | Factory | The creating `BlocProvider` closes it |
| `AuthRepository` | Lazy singleton (`MockAuthRepository`) | In-memory accounts/session live for this container |
| `GoRouter` | Lazy singleton | GetIt disposes it during reset |

Register future long-lived repository implementations as lazy singletons. AuthCubit is created at each route's BlocProvider boundary with the injected AuthRepository contract, and is closed by that provider. The app-wide settings factory is resolved once at startup; access that existing instance with `context.read<AppSettingsCubit>()`.

Do not call GetIt from domain objects, ordinary widgets, or Cubits. Use constructor injection. Do not close a shared singleton in a page. `BlocProvider.value` does not take ownership; its caller must close the supplied Cubit.

Tests use `GetIt.asNewInstance()` and `await services.reset()`. Configuration is called once per container; duplicate registration should remain visible as an error.

When the registrations grow, extract feature registration functions and invoke them from `injection_container.dart`. Keep the composition entry point readable.

## Replaceable mock and Firebase repositories

No repository contract is invented before the required operations and entities are known. When the team agrees a feature contract:

1. Define its entities and abstract repository under that feature's `domain/`.
2. Implement that interface in `data/repositories/`. An explicit mock implementation can use agreed fixtures; it must follow the same return types, error behavior, and stream contracts as the eventual real implementation.
3. Inject the interface into the feature Cubit. Never expose mock classes, SDK snapshots, or Firebase types in UI state.
4. Bind the interface to one implementation in GetIt.
5. Add contract tests that can exercise both implementations.

For example, the following is a **future wiring example**, not existing app code:

```dart
services.registerLazySingleton<JobsRepository>(() => MockJobsRepository());
services.registerFactory<JobsCubit>(
  () => JobsCubit(services<JobsRepository>()),
);
```

Later, replace the first factory with a Firebase-backed implementation. Data sources own SDK calls and DTO mapping. Cubit constructors and widgets keep the same interface. SDK initialization and credentials belong in startup/platform configuration when that work is explicitly introduced. No Firebase packages or configuration are included now.

## Navigation

`app_routes.dart` holds route constants; `app_router.dart` builds the route tree once. The entry flow is `/` → `/onboarding` → `/login`. Login pushes `/sign-up`; registration returns to Login with only the email, never a password. Successful Login replaces the auth stack with `/preview`, an explicitly temporary demo session page. Completion callbacks are wired in the router; feature pages do not import GoRouter. Android Back on slides 2/3 goes to the previous slide; Back on slide 1 retains normal system behavior. Auth Back returns Sign Up → Login → Onboarding, and is disabled during requests. Use named navigation:

```dart
context.goNamed(AppRoutes.startName);
```

Use `pushNamed` for a screen that should return to the current page; use `goNamed` to change the route destination. Add stable paths and names before wiring buttons. Use path/query parameters for identifiers that must survive reloads and deep links.

Register each product page in the central tree with its page-scoped `BlocProvider(create: ...)`. Larger features may export a route list from `presentation/routes/` for the central router to compose. Keep DI resolution at that composition boundary.

The router is not recreated when language or theme changes. Production leaves `initialLocation` unset so a platform-provided deep link is honored. Unknown destinations show a localized fallback with a return action; internal exceptions are not displayed. Guards send signed-out `/preview` requests to Login and signed-in Login/Sign Up requests to `/preview`. Explicit sign-in/sign-out navigation reevaluates the guards; a future Firebase integration should add session-stream refresh for external auth changes.

## Localization and direction

Flutter generates `AppLocalizations` from the two ARB files using `l10n.yaml`. Generation runs during Flutter tooling with `generate: true`; run `flutter gen-l10n` explicitly after translation changes. Keep generated Dart files alongside this foundation for direct IDE navigation; regenerate them instead of editing them.

Read messages via `context.l10n`. Add each new message to both ARBs and give it a description in the English template. Prefer feature-prefixed keys, for example `authSignInTitle`, to reduce naming collisions. Use ARB placeholders/plurals instead of concatenating translated sentences. Translation parity is tested.

The app starts with the device language, resolves regional Arabic/English variants to supported languages, and falls back to English for unsupported device languages. `AppSettingsCubit.setLocale(null)` restores device selection; explicit unsupported languages are rejected.

```dart
context.read<AppSettingsCubit>().setLocale(const Locale('ar'));
context.read<AppSettingsCubit>().setLocale(const Locale('en'));
context.read<AppSettingsCubit>().setLocale(null);
```

The localization delegates establish RTL for Arabic and LTR for English. Do not wrap the app in a hardcoded `Directionality`. Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `TextAlign.start/end`, and start/end positioned values. Use direction-aware navigation icons. Email addresses and other intentionally LTR values can use `AppTextField.textDirection` locally.

Use flexible sizing, scrollable content, and text wrapping. Review every product screen in both languages, both themes, narrow layouts, and enlarged text. RTL readiness in this foundation does not automatically validate future screens.

## Themes and shared UI

`AppTheme` applies the supplied palette, confirmed Figma component dimensions, bundled Inter/Noto Sans Arabic fonts, and shared button, field, and card styling. The default is `ThemeMode.system`; use `setThemeMode(ThemeMode.light/dark/system)` to change it. See [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) for source nodes, color values, accessibility adjustments, and details still requiring design decisions.

Read `Theme.of(context).colorScheme` and `textTheme` in widgets. Avoid hardcoded foreground/background colors. Keep page text and controls responsive to system text scaling. Intro illustrations use a fixed design canvas with an accessible localized image description; only their decorative internal labels keep image-like sizing.

- `AppButton`: filled action, optional leading icon or trailing adornment, disabled and loading behavior; loading blocks duplicate taps. A trailing adornment requires a bounded-width parent.
- `AppCard`: themed surface with directional content padding; parent layouts own spacing between cards.
- `AppTextField`: Form validation/saving, controller or initial value, localized labels, keyboard/autofill options, password obscuring, and optional local text direction. Callers own controllers/focus nodes.
- `AppLoading`: accessible localized progress indicator.
- `AppErrorState`: localized fallback messages and optional retry callback. Supply user-facing text rather than raw exception strings.
- `AppEmptyState`: localized defaults, custom icon/message/action, scrolling for constrained layouts.

Both language and theme choices are currently session-only. There is no settings screen or storage package. When persistence is required, add a settings repository and map persisted values into the existing presentation state.

## Team workflow for screens 1–25

The project owner implements screens 1–8; the other team members implement screens 9–25. Before dividing code, agree on the screen-to-feature mapping, route names, shared entity/repository contracts, and Figma tokens. Screens 01/02 belong to `splash` and `onboarding`. Agree the remaining screen-to-feature mapping before adding feature contracts.

For each assigned screen:

1. Place the page, private widgets, and meaningful Cubit state under its feature.
2. Reuse shared widgets and add English/Arabic copy together.
3. Agree repository operations before implementing data access.
4. Register dependencies and integrate the route through the composition files.
5. Test interactions and navigation, plus RTL and light/dark rendering.
6. Run formatting, analysis, and the test suite from this project directory.

Coordinate edits to `app_router.dart`, `app_routes.dart`, `injection_container.dart`, `app_theme.dart`, the ARBs, and `pubspec.yaml`. Keep feature changes otherwise self-contained. Do not import another feature's data implementation.

## Validation and remaining work

Infrastructure tests cover actual startup and Cubit disposal, factory/singleton lifetimes, preference changes, English fallback, Arabic direction, system brightness, navigation preservation, initial deep links, missing-route recovery, translation parity, form validation, loading/disabled buttons, retry behavior, loading semantics, and narrow Arabic layouts with enlarged text.

Before screens 05–08: review [AUTH.md](AUTH.md), [ONBOARDING.md](ONBOARDING.md), and [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md), agree the next routes/contracts, and obtain the remaining screen assets. Login is already connected to onboarding completion. No new architecture package is required. Splash/onboarding retain local animation/page state; their presentation-only behavior does not need a repository, use case, or Cubit.

Native release identifiers, signing, launcher branding, backend contracts, preference persistence, Firebase, and matching/AI are later tasks. Platform release builds and physical-device QA are separate from the infrastructure tests; iOS/macOS builds require a Mac.

References: [Flutter localization](https://docs.flutter.dev/ui/internationalization), [GoRouter](https://pub.dev/packages/go_router), [flutter_bloc](https://pub.dev/packages/flutter_bloc), and [GetIt](https://pub.dev/packages/get_it).
