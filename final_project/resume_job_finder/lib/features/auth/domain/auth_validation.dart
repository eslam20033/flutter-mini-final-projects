enum AuthField { fullName, email, password, confirmPassword }

enum AuthValidationError {
  nameRequired,
  emailRequired,
  emailInvalid,
  passwordRequired,
  passwordTooShort,
  confirmationRequired,
  passwordMismatch,
}

abstract final class AuthValidation {
  static const minimumPasswordLength = 8;

  static Map<AuthField, AuthValidationError> login({
    required String email,
    required String password,
  }) {
    final errors = forgotPassword(email: email);
    final passwordError = _passwordError(password);
    if (passwordError != null) errors[AuthField.password] = passwordError;
    return errors;
  }

  static Map<AuthField, AuthValidationError> forgotPassword({
    required String email,
  }) {
    final errors = <AuthField, AuthValidationError>{};
    final address = email.trim();
    if (address.isEmpty) {
      errors[AuthField.email] = AuthValidationError.emailRequired;
    } else if (!_validEmail(address)) {
      errors[AuthField.email] = AuthValidationError.emailInvalid;
    }
    return errors;
  }

  static Map<AuthField, AuthValidationError> registration({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final errors = forgotPassword(email: email)
      ..addAll(
        resetPassword(password: password, confirmPassword: confirmPassword),
      );
    if (fullName.trim().isEmpty) {
      errors[AuthField.fullName] = AuthValidationError.nameRequired;
    }
    return errors;
  }

  static Map<AuthField, AuthValidationError> resetPassword({
    required String password,
    required String confirmPassword,
  }) {
    final errors = <AuthField, AuthValidationError>{};
    final passwordError = _passwordError(password, enforceMinimum: true);
    if (passwordError != null) errors[AuthField.password] = passwordError;
    if (confirmPassword.isEmpty) {
      errors[AuthField.confirmPassword] =
          AuthValidationError.confirmationRequired;
    } else if (confirmPassword != password) {
      errors[AuthField.confirmPassword] = AuthValidationError.passwordMismatch;
    }
    return errors;
  }

  static AuthValidationError? _passwordError(
    String password, {
    bool enforceMinimum = false,
  }) {
    if (password.trim().isEmpty) return AuthValidationError.passwordRequired;
    if (enforceMinimum && password.length < minimumPasswordLength) {
      return AuthValidationError.passwordTooShort;
    }
    return null;
  }

  // Practical address validation, not a claim of mailbox ownership.
  static bool _validEmail(String email) {
    if (email.length > 254) return false;
    final parts = email.split('@');
    if (parts.length != 2) return false;
    final local = parts[0];
    if (local.isEmpty ||
        local.length > 64 ||
        local.startsWith('.') ||
        local.endsWith('.') ||
        local.contains('..') ||
        !RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+$").hasMatch(local)) {
      return false;
    }
    final labels = parts[1].split('.');
    return labels.length >= 2 &&
        labels.every(
          (label) =>
              label.isNotEmpty &&
              label.length <= 63 &&
              RegExp(r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$')
                  .hasMatch(label),
        );
  }
}
