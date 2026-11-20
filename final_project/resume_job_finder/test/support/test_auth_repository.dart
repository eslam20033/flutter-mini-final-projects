import 'dart:async';
import 'package:resume_job_finder/features/auth/domain/auth_repository.dart';
import 'package:resume_job_finder/features/auth/domain/auth_user.dart';
import 'package:resume_job_finder/features/auth/domain/auth_validation.dart';
import 'package:resume_job_finder/features/auth/domain/password_recovery.dart';

/// Test-only fixture for navigation and form contracts; never in runtime DI.
class TestAuthRepository implements AuthRepository {
  TestAuthRepository({this.delay = const Duration(milliseconds: 500)});

  final Duration delay;
  final _accounts = <String, ({AuthUser user, String password})>{};
  AuthUser? _currentUser;
  final _recoveryRequests = <PasswordResetRequest, String>{};

  @override
  AuthUser? get currentUser => _currentUser;

  final _changes = StreamController<AuthUser?>.broadcast();
  @override
  Stream<AuthUser?> get userChanges => _changes.stream;
  @override
  Future<void> restoreSession() async {}
  void setSession(AuthUser? user) {
    _currentUser = user;
    _changes.add(user);
  }
  Future<void> close() => _changes.close();

  @override
  Future<void> requestPasswordRecovery({
    required String email,
  }) async {
    await Future<void>.delayed(delay);
    final address = email.trim().toLowerCase();
    if (!_accounts.containsKey(address)) {
      throw const AuthException(AuthFailure.recoveryExpired);
    }
    // Flow bookkeeping only, NOT a secure token or identity check.
    _recoveryRequests.removeWhere((_, value) => value == address);
    final request = PasswordResetRequest(email: address, code: 'test-recovery-code');
    _recoveryRequests[request] = address;
    return;
  }

  @override
  Future<void> resetPassword({
    required PasswordResetRequest request,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    final address = request.code == 'test-recovery-code' ? request.email.toLowerCase() : null;
    final account = _accounts[address];
    if (address == null || account == null) {
      throw const AuthException(AuthFailure.recoveryExpired);
    }
    if (AuthValidation.resetPassword(
      password: password,
      confirmPassword: password,
    ).isNotEmpty) {
      throw const AuthException(AuthFailure.unavailable);
    }
    _accounts[address] = (user: account.user, password: password);
    _recoveryRequests.removeWhere((_, value) => value == address);
    if (_currentUser?.id == account.user.id) _currentUser = null;
  }

  @override
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    final address = email.trim().toLowerCase();
    if (_accounts.containsKey(address)) {
      throw const AuthException(AuthFailure.emailInUse);
    }
    final user = AuthUser(
      id: 'test-${_accounts.length + 1}',
      fullName: fullName.trim(),
      email: address,
    );
    _accounts[address] = (user: user, password: password);
    return user;
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }
    setSession(account.user);
    return account.user;
  }

  @override
  Future<AuthUser> signInWithProvider(AuthProvider provider) async {
    throw const AuthException(AuthFailure.providerUnavailable);
  }

  @override
  Future<void> signOut() async {
    setSession(null);
  }
}
