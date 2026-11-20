import '../../../l10n/generated/app_localizations.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_validation.dart';

extension AuthMessages on AppLocalizations {
  String? authFieldError(AuthValidationError? error) => switch (error) {
    null => null,
    AuthValidationError.nameRequired => authNameRequired,
    AuthValidationError.emailRequired => authEmailRequired,
    AuthValidationError.emailInvalid => authEmailInvalid,
    AuthValidationError.passwordRequired => authPasswordRequired,
    AuthValidationError.passwordTooShort => authPasswordTooShort(
      AuthValidation.minimumPasswordLength,
    ),
    AuthValidationError.confirmationRequired => authConfirmationRequired,
    AuthValidationError.passwordMismatch => authPasswordMismatch,
  };

  String authFailureMessage(AuthFailure failure) => switch (failure) {
    AuthFailure.invalidCredentials => authInvalidCredentials,
    AuthFailure.emailInUse => authEmailInUse,
    AuthFailure.providerUnavailable => authProviderUnavailable,
    AuthFailure.recoveryExpired => authRecoveryExpired,
    AuthFailure.registrationSignInFailed => authRegistrationSignInFailed,
    AuthFailure.unavailable => authUnavailable,
  };
}
