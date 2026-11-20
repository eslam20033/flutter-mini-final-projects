import '../../domain/auth_repository.dart';
import '../../domain/auth_user.dart';
import '../../domain/auth_validation.dart';
import '../../domain/password_recovery.dart';

enum AuthStatus {
  initial,
  loading,
  failure,
  registered,
  authenticated,
  signedOut,
  recoveryRequested,
  passwordReset,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.failure,
    this.errors = const {},
    this.resetRequest,
  });

  final AuthStatus status;
  final AuthUser? user;
  final AuthFailure? failure;
  final Map<AuthField, AuthValidationError> errors;
  final PasswordResetRequest? resetRequest;

  bool get isLoading => status == AuthStatus.loading;
}
