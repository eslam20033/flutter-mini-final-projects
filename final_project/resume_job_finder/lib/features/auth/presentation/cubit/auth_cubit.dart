import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/auth_repository.dart';
import '../../domain/auth_user.dart';
import '../../domain/auth_validation.dart';
import '../../domain/password_recovery.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(AuthState(user: _repository.currentUser));

  final AuthRepository _repository;

  Future<void> requestPasswordRecovery({required String email}) async {
    if (state.isLoading || isClosed) return;
    if (_emitValidationErrors(AuthValidation.forgotPassword(email: email))) {
      return;
    }
    await _runRequest(() async {
      await _repository.requestPasswordRecovery(email: email.trim());
      return const AuthState(status: AuthStatus.recoveryRequested);
    });
  }

  Future<void> resetPassword({
    required PasswordResetRequest request,
    required String password,
    required String confirmPassword,
  }) async {
    if (state.isLoading ||
        isClosed ||
        state.status == AuthStatus.passwordReset) {
      return;
    }
    if (_emitValidationErrors(
      AuthValidation.resetPassword(
        password: password,
        confirmPassword: confirmPassword,
      ),
    )) {
      return;
    }
    await _runRequest(() async {
      if (request.code.trim().isEmpty) {
        throw const AuthException(AuthFailure.recoveryExpired);
      }
      await _repository.resetPassword(request: request, password: password);
      return const AuthState(status: AuthStatus.passwordReset);
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    if (state.isLoading || isClosed) return;
    final errors = AuthValidation.login(email: email, password: password);
    if (_emitValidationErrors(errors)) return;
    await _runAuthRequest(
      () => _repository.signIn(email: email.trim(), password: password),
      AuthStatus.authenticated,
    );
  }

  Future<void> signInWithProvider(AuthProvider provider) async {
    if (state.isLoading || isClosed) return;
    await _runAuthRequest(
      () => _repository.signInWithProvider(provider),
      AuthStatus.authenticated,
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    bool signInAfterRegistration = false,
  }) async {
    if (state.isLoading || isClosed) return;
    final errors = AuthValidation.registration(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (_emitValidationErrors(errors)) return;
    await _runAuthRequest(() async {
      final user = await _repository.register(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
      );
      if (!signInAfterRegistration || isClosed) return user;
      if (_repository.currentUser?.id == user.id) return user;
      try {
        return await _repository.signIn(email: user.email, password: password);
      } catch (_) {
        throw const AuthException(AuthFailure.registrationSignInFailed);
      }
    }, AuthStatus.registered);
  }

  bool _emitValidationErrors(Map<AuthField, AuthValidationError> errors) {
    if (errors.isEmpty) return false;
    emit(
      AuthState(status: AuthStatus.failure, errors: Map.unmodifiable(errors)),
    );
    return true;
  }

  Future<void> _runAuthRequest(
    Future<AuthUser> Function() action,
    AuthStatus successStatus,
  ) => _runRequest(
    () async => AuthState(status: successStatus, user: await action()),
  );

  Future<void> _runRequest(Future<AuthState> Function() action) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final result = await action();
      if (!isClosed) emit(result);
    } on AuthException catch (error) {
      if (!isClosed) {
        emit(AuthState(status: AuthStatus.failure, failure: error.failure));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          const AuthState(
            status: AuthStatus.failure,
            failure: AuthFailure.unavailable,
          ),
        );
      }
    }
  }

  void clearError(AuthField field) {
    if (isClosed || state.isLoading) return;
    if (state.status != AuthStatus.recoveryRequested &&
        state.failure == null &&
        !state.errors.containsKey(field) &&
        !(field == AuthField.password &&
            state.errors.containsKey(AuthField.confirmPassword))) {
      return;
    }
    final errors = Map<AuthField, AuthValidationError>.of(state.errors)
      ..remove(field);
    if (field == AuthField.password) errors.remove(AuthField.confirmPassword);
    emit(AuthState(user: state.user, errors: Map.unmodifiable(errors)));
  }

  Future<void> signOut() async {
    if (state.isLoading || isClosed) return;
    final user = state.user;
    emit(AuthState(status: AuthStatus.loading, user: user));
    try {
      await _repository.signOut();
      if (!isClosed) emit(const AuthState(status: AuthStatus.signedOut));
    } catch (_) {
      if (!isClosed) {
        emit(
          AuthState(
            status: AuthStatus.failure,
            user: user,
            failure: AuthFailure.unavailable,
          ),
        );
      }
    }
  }
}
