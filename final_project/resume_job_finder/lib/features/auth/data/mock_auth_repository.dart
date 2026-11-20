import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/auth_validation.dart';
import '../domain/password_recovery.dart';

/// Local demonstration only: accounts, plaintext passwords and session remain
/// in memory. No identity is verified, no email is sent, and restart clears data.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    this.delay = const Duration(milliseconds: 500),
    this.onRecoveryRequested,
  });

  final Duration delay;

  /// Simulates opening an emailed link. Only the mock composition root uses it;
  /// a real provider delivers its own link outside the app.
  final void Function(PasswordResetRequest request)? onRecoveryRequested;
  final _accounts = <String, ({AuthUser user, String password})>{};
  final _recoveryRequests = <String, String>{};
  final _changes = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get userChanges => _changes.stream;

  @override
  Future<void> restoreSession() async {}

  void _setSession(AuthUser? user) {
    _currentUser = user;
    _changes.add(user);
  }

  Future<void> close() async {
    _accounts.clear();
    _recoveryRequests.clear();
    _currentUser = null;
    await _changes.close();
  }

  @override
  Future<void> requestPasswordRecovery({required String email}) async {
    await Future<void>.delayed(delay);
    final address = email.trim().toLowerCase();
    if (!_accounts.containsKey(address)) return;
    _recoveryRequests.removeWhere((_, value) => value == address);
    final random = Random.secure();
    final code = base64Url.encode(
      List.generate(24, (_) => random.nextInt(256)),
    );
    _recoveryRequests[code] = address;
    onRecoveryRequested?.call(PasswordResetRequest(email: address, code: code));
  }

  @override
  Future<void> resetPassword({
    required PasswordResetRequest request,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    final address = _recoveryRequests[request.code];
    final account = _accounts[address];
    if (address == null ||
        account == null ||
        (request.email.isNotEmpty &&
            request.email.trim().toLowerCase() != address)) {
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
    if (_currentUser?.id == account.user.id) _setSession(null);
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
      id: 'demo-${_accounts.length + 1}',
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
    _setSession(account.user);
    return account.user;
  }

  @override
  Future<AuthUser> signInWithProvider(AuthProvider provider) async {
    throw const AuthException(AuthFailure.providerUnavailable);
  }

  @override
  Future<void> signOut() async => _setSession(null);
}
