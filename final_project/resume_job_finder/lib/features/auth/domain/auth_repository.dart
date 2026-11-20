import 'auth_user.dart';
import 'password_recovery.dart';

enum AuthProvider { google, apple }

enum AuthFailure {
  invalidCredentials,
  emailInUse,
  providerUnavailable,
  recoveryExpired,
  registrationSignInFailed,
  unavailable,
}

class AuthException implements Exception {
  const AuthException(this.failure);

  final AuthFailure failure;
}

abstract interface class AuthRepository {
  AuthUser? get currentUser;

  /// Complete after the provider's initial session restoration. Never create
  /// an account or infer authentication from locally entered credentials.
  Future<void> restoreSession();

  /// Broadcast provider session changes, including sign-out/expiry and account
  /// replacement. Update currentUser before emitting; forward restoration errors.
  Stream<AuthUser?> get userChanges;

  /// Send provider recovery instructions. Never return a reset token from an
  /// email-only request or disclose whether the account exists.
  Future<void> requestPasswordRecovery({
    required String email,
  });

  /// A production implementation MUST verify the provider code. It must never
  /// use an email-only reset.
  Future<void> resetPassword({
    required PasswordResetRequest request,
    required String password,
  });

  Future<AuthUser> signIn({required String email, required String password});

  /// Returns a user only after the provider has authenticated successfully.
  Future<AuthUser> signInWithProvider(AuthProvider provider);

  /// Creates a real account. If the provider also signs in, update currentUser
  /// and userChanges before completing. Otherwise the Cubit requests sign-in.
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> signOut();
}
