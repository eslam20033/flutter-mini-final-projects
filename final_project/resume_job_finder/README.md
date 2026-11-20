# Resume Job Finder

Flutter foundation for an automated resume matching and job finder app.

Includes feature-first organization, Cubit, GoRouter, GetIt, Material 3 themes, English/Arabic localization, RTL/LTR support, and reusable UI. Screens 01 (Splash), 02 (all three Onboarding slides), 03 (Login), and 04 (Sign Up) are implemented. Authentication is an in-memory demo; Home and backend integrations remain future work. The product serves all professions; illustrated opportunities and scores are demo content.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the folder structure, dependency boundaries, ownership rules, and screen implementation workflow.

## Run locally

Use Flutter 3.47.6 stable / Dart 3.13.5 (the version used for this setup). From this directory:

```sh
flutter pub get
flutter gen-l10n
flutter run
```

The initial route shows Splash, then Onboarding. Skip/Get Started open Login. Create a demo account, then sign in to reach the temporary session page with sign-out and introduction replay. Accounts disappear on app restart; use made-up details. Language and theme follow the device by default; the existing settings Cubit supports runtime overrides. See [ONBOARDING.md](ONBOARDING.md) and [AUTH.md](AUTH.md) for implementation, verification, and known design limitations.

## Check changes

```sh
dart format lib test
flutter analyze
flutter test
```

Keep pubspec.lock and regenerated localization files with dependency/translation changes. All project work belongs inside final_project/resume_job_finder.
