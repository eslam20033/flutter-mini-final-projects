import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/features/auth/domain/auth_repository.dart';
import 'package:resume_job_finder/features/auth/domain/auth_validation.dart';
import 'package:resume_job_finder/features/auth/domain/password_recovery.dart';
import 'package:resume_job_finder/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:resume_job_finder/features/auth/presentation/cubit/auth_state.dart';

import '../../../support/controlled_auth_repository.dart';

void main() {
  late ControlledAuthRepository repository;
  late AuthCubit cubit;
  late PasswordResetRequest request;
  setUp(() {
    repository = ControlledAuthRepository();
    cubit = AuthCubit(repository);
    request = PasswordResetRequest(email: 'amina@example.com', code: 'test-recovery-code');
  });
  tearDown(() => cubit.close());

  Future<void> reset({
    String password = 'new-password',
    String confirmation = 'new-password',
  }) => cubit.resetPassword(
    request: request,
    password: password,
    confirmPassword: confirmation,
  );

  test('forgot password validates required and malformed emails without repository calls', () async {
    expect(cubit.state.status, AuthStatus.initial);
    for (final email in [' ', 'invalid', 'a@@example.com', 'a@-example.com']) {
      await cubit.requestPasswordRecovery(email: email);
      expect(cubit.state.status, AuthStatus.failure);
      expect(
        cubit.state.errors[AuthField.email],
        email.trim().isEmpty
            ? AuthValidationError.emailRequired
            : AuthValidationError.emailInvalid,
      );
    }
    expect(repository.recoveryCalls, 0);
    cubit.clearError(AuthField.email);
    expect(cubit.state.errors, isEmpty);
  });

  test(
    'reset shares Sign Up rules including required fields and mismatch',
    () async {
      for (final pair in [
        ('', ''),
        ('        ', '        '),
        ('short', 'short'),
        ('new-password', ''),
        ('new-password', 'different'),
      ]) {
        await reset(password: pair.$1, confirmation: pair.$2);
        expect(
          cubit.state.errors,
          AuthValidation.registration(
            fullName: 'Amina',
            email: request.email,
            password: pair.$1,
            confirmPassword: pair.$2,
          ),
        );
        expect(cubit.state.status, AuthStatus.failure);
      }
      expect(repository.resetCalls, 0);
      cubit.clearError(AuthField.password);
      expect(cubit.state.errors, isEmpty);
    },
  );

  test('recovery blocks concurrent requests and sends only the email without a user', () async {
    final states = expectLater(
      cubit.stream.map((state) => state.status),
      emitsInOrder([AuthStatus.loading, AuthStatus.recoveryRequested]),
    );
    final pending = cubit.requestPasswordRecovery(email: ' amina@example.com ');
    expect(cubit.state.isLoading, isTrue);
    await cubit.requestPasswordRecovery(email: request.email);
    await reset();
    expect(repository.recoveryCalls, 1);
    expect(repository.resetCalls, 0);
    expect(repository.recoveryEmail, request.email);
    repository.recoveryResult.complete();
    await pending;
    expect(repository.recoveryEmail, request.email);
    expect(cubit.state.user, isNull);
    await states;
  });

  test(
    'reset passes exact password, blocks duplicates and never authenticates',
    () async {
      final pending = reset(
        password: ' new-password ',
        confirmation: ' new-password ',
      );
      expect(cubit.state.isLoading, isTrue);
      await reset();
      expect(repository.resetCalls, 1);
      expect(repository.resetRequest, same(request));
      expect(repository.resetPasswordValue, ' new-password ');
      repository.resetResult.complete();
      await pending;
      expect(cubit.state.status, AuthStatus.passwordReset);
      expect(cubit.state.user, isNull);
      await reset();
      expect(repository.resetCalls, 1);
    },
  );

  test('real email-link adapter returns no local reset request', () async {
    final pending = cubit.requestPasswordRecovery(email: request.email);
    repository.recoveryResult.complete();
    await pending;
    expect(cubit.state.status, AuthStatus.recoveryRequested);
    expect(repository.resetCalls, 0);
  });

  for (final isReset in [false, true]) {
    for (final typed in [false, true]) {
      test(
        '${isReset ? 'reset' : 'recovery'} maps ${typed ? 'typed' : 'private'} failures safely',
        () async {
          final pending = isReset
              ? reset()
              : cubit.requestPasswordRecovery(email: request.email);
          final error = typed
              ? const AuthException(AuthFailure.recoveryExpired)
              : StateError('Private backend detail');
          if (isReset) {
            repository.resetResult.completeError(error);
          } else {
            repository.recoveryResult.completeError(error);
          }
          await pending;
          expect(cubit.state.status, AuthStatus.failure);
          expect(
            cubit.state.failure,
            typed ? AuthFailure.recoveryExpired : AuthFailure.unavailable,
          );
          cubit.clearError(isReset ? AuthField.password : AuthField.email);
          expect(cubit.state.failure, isNull);
        },
      );
    }

    test(
      '${isReset ? 'reset' : 'recovery'} completion after disposal does not emit',
      () async {
        final pending = isReset
            ? reset()
            : cubit.requestPasswordRecovery(email: request.email);
        await cubit.close();
        if (isReset) {
          repository.resetResult.complete();
        } else {
          repository.recoveryResult.complete();
        }
        await expectLater(pending, completes);
      },
    );
  }
}
