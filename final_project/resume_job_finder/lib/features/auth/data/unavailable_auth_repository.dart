import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/password_recovery.dart';

/// Default binding until a real identity provider is integrated.
/// No credentials, accounts, recovery requests or sessions are stored.
class UnavailableAuthRepository implements AuthRepository {
  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get userChanges => const Stream.empty();

  @override
  Future<void> restoreSession() async {}

  @override
  Future<AuthUser> signIn({required String email, required String password}) async =>
      throw const AuthException(AuthFailure.unavailable);

  @override
  Future<AuthUser> register({required String fullName, required String email, required String password}) async =>
      throw const AuthException(AuthFailure.unavailable);

  @override
  Future<AuthUser> signInWithProvider(AuthProvider provider) async =>
      throw const AuthException(AuthFailure.providerUnavailable);

  @override
  Future<void> requestPasswordRecovery({required String email}) async =>
      throw const AuthException(AuthFailure.unavailable);

  @override
  Future<void> resetPassword({required PasswordResetRequest request, required String password}) async =>
      throw const AuthException(AuthFailure.unavailable);

  @override
  Future<void> signOut() async =>
      throw const AuthException(AuthFailure.unavailable);
}
