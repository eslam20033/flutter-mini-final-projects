import 'dart:async';

import 'package:resume_job_finder/features/auth/domain/auth_repository.dart';
import 'package:resume_job_finder/features/auth/domain/auth_user.dart';
import 'package:resume_job_finder/features/auth/domain/password_recovery.dart';

class ControlledAuthRepository implements AuthRepository {
  final signInResult = Completer<AuthUser>();
  final registrationResult = Completer<AuthUser>();
  final providerResult = Completer<AuthUser>();
  final providerRequests = <AuthProvider>[];
  int signInCalls = 0;
  int registrationCalls = 0;
  bool failSignOut = false;
  final recoveryResult = Completer<void>();
  final resetResult = Completer<void>();
  int recoveryCalls = 0;
  int resetCalls = 0;
  String? recoveryEmail;
  PasswordResetRequest? resetRequest;
  String? resetPasswordValue;

  final changes = StreamController<AuthUser?>.broadcast();
  Future<void>? restoration;
  bool failRestoration = false;
  @override
  Future<void> restoreSession() async {
    if (restoration != null) await restoration;
    if (failRestoration) throw StateError('Session restoration failed');
  }

  @override
  Stream<AuthUser?> get userChanges => changes.stream;
  void setSession(AuthUser? user) {
    currentUser = user;
    changes.add(user);
  }

  @override
  Future<void> requestPasswordRecovery({required String email}) {
    recoveryCalls++;
    recoveryEmail = email;
    return recoveryResult.future;
  }

  @override
  Future<void> resetPassword({
    required PasswordResetRequest request,
    required String password,
  }) {
    resetCalls++;
    resetRequest = request;
    resetPasswordValue = password;
    return resetResult.future;
  }

  @override
  AuthUser? currentUser;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    final user = await signInResult.future;
    setSession(user);
    return user;
  }

  @override
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    registrationCalls++;
    return registrationResult.future;
  }

  @override
  Future<AuthUser> signInWithProvider(AuthProvider provider) async {
    providerRequests.add(provider);
    final user = await providerResult.future;
    setSession(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    if (failSignOut) throw StateError('Private implementation detail');
    setSession(null);
  }
}
