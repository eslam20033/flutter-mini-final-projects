# Password recovery handover

Screens 05 (Forgot Password) and 06 (Reset Password) extend the existing Auth feature. No Firebase, new package, additional Cubit, or DI registration was added. The existing GetIt singleton keeps accounts available across the route-owned AuthCubits.

## Local demo

Register an account through Sign Up, save preferences or use Back to reach Home, then sign out. On Login, choose Forgot password and enter that account's email. Continue to Reset Password, enter matching passwords of at least eight characters, and submit. The success view offers Back to sign in. The old password fails and the new password opens Home. See CAREER_HOME.md for the updated screens 07–08 journey.

Both recovery screens explicitly describe an insecure local simulation: no email, identity check, or token verification takes place. Anyone can reset a registered demo account. Credentials, accounts, and pending requests exist only in process memory; restarting the app discards them. Nothing is persisted or logged, and autofill saving remains disabled.

`MockAuthRepository` owns all demo behavior. It normalizes email, rejects unknown accounts, retains the account identity, updates only its password, and never signs the user in as a recovery side effect. Requests are plain in-memory objects, not secure tokens. Reissuing a request invalidates the previous one for that account; success consumes it. Invented requests, requests from another repository instance, and consumed requests fail. Invalid passwords leave the original password intact.

## Navigation and states

- Login pushes `/forgot-password`; Forgot pushes `/reset-password` with a domain request in route extras.
- Back from Reset returns to Forgot with its email intact. Back from Forgot returns to Login with the existing form intact. Direct entry to Forgot falls back to Login on Back.
- Reset success shows localized feedback and clears both password controllers. Its primary action and Android Back replace the stack with Login.
- A bare reset URL, email query, or incorrect extra redirects to Forgot. Nothing in a URL is treated as verified.
- Signed-in users on either recovery route retain the existing redirect to the session page. Splash, Onboarding, Sign Up, and sign-out behavior are preserved.
- Initial, loading, field failure, repository failure, request success, and reset success are distinct states. Loading blocks duplicate requests, inputs, visibility toggles, submit, links, and Back. Error feedback supports retry; unavailable requests also offer Start recovery again.

## Firebase integration boundary

Implement the expanded `AuthRepository` contract in a real data adapter, then replace the existing GetIt binding. Set `passwordRecoveryMode` to `emailLink`. `requestPasswordRecovery` should ask the provider to send instructions and return null, so Forgot shows generic inbox guidance without revealing whether an account exists. Only the mock returns a request directly without verification.

Add the provider's external-link handling at the app/router boundary. Supply its code and account email to `PasswordResetRequest` and open the existing reset route. The request object is **not** verification: the real repository must validate the provider code and confirm the reset with the provider before returning success. Reject missing, expired, and invalid codes; never implement an email-only fallback or reuse the mock's account map. Map provider failures to domain failures (including `recoveryExpired`).

The screens and AuthCubit already support both delivery modes. Controlled-adapter tests exercise generic email guidance and code-based reset presentation, but no actual provider or external-link integration is implemented. Existing session-restoration/refresh integration remains future work as described in AUTH.md.

## UI and verification

Verified on 2026-11-18: `dart format` completed; `flutter analyze` reported **No issues found** (exit 0); the full `flutter test` suite reported **159 tests passed** (exit 0), including 48 new recovery tests and all retained existing tests. The separate ignored rendering test also passed and is not counted in 159.

The forms reuse AuthScaffold, AuthPasswordField, AppTextField, AppButton, AppCard, and AuthErrorFeedback, plus one shared recovery disclosure. Validation is centralized in AuthValidation; Sign Up and Reset use the same new-password rule. All copy is in the existing English/Arabic ARBs and regenerated localization classes. Existing Inter/Noto Sans Arabic fonts, LTR/RTL, palette, and Light/Dark themes are reused.

Layout tests cover both forms in both languages and themes at 390×844, 320×568, 844×390, and 1024×1366, including 2× text and simulated keyboard insets. Twelve local PNGs (Forgot, Reset, success × two languages × two themes) were rendered and visually inspected. These ignored artifacts and the rendering test are under `build/recovery_review/`.

The Figma metadata, design-context, and screenshot requests were blocked by the account's Starter-plan MCP limit. The implementation follows the existing auth components and documented tokens; exact screen-specific Figma layout and asset parity remain unverified.

Android emulator verification was not possible: `flutter devices --device-timeout 10` listed Windows/Chrome/Edge only, and `flutter emulators` reported no emulators. Widget tests include simulated Android Back and keyboard behavior; these are not device verification.

## Files in this change

Created:

```text
PASSWORD_RECOVERY.md
lib/features/auth/domain/password_recovery.dart
lib/features/auth/presentation/pages/forgot_password_page.dart
lib/features/auth/presentation/pages/reset_password_page.dart
lib/features/auth/presentation/widgets/auth_recovery_notice.dart
test/features/auth/data/mock_password_recovery_test.dart
test/features/auth/presentation/password_recovery_cubit_test.dart
test/features/auth/presentation/password_recovery_flow_test.dart
test/features/auth/presentation/password_recovery_layout_test.dart
```

Modified:

```text
AUTH.md
lib/app/router/app_router.dart
lib/app/router/app_routes.dart
lib/features/auth/domain/auth_repository.dart
lib/features/auth/domain/auth_validation.dart
lib/features/auth/data/mock_auth_repository.dart
lib/features/auth/presentation/auth_messages.dart
lib/features/auth/presentation/cubit/auth_cubit.dart
lib/features/auth/presentation/cubit/auth_state.dart
lib/features/auth/presentation/pages/login_page.dart
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
lib/l10n/generated/app_localizations.dart
lib/l10n/generated/app_localizations_en.dart
lib/l10n/generated/app_localizations_ar.dart
test/support/controlled_auth_repository.dart
test/features/auth/presentation/auth_flow_test.dart
```

Existing tests are retained; the former Forgot Password dialog assertions now expect the working recovery screen. The recovery pass did not change screens 07–25 or `mini_project/todo_app`. Screens 07–08 were implemented subsequently as documented in CAREER_HOME.md. No branch change, commit, or push was performed.
