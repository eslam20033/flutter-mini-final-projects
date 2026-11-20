import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/features/auth/domain/auth_repository.dart';
import 'package:resume_job_finder/features/auth/domain/auth_user.dart';
import 'package:resume_job_finder/features/auth/domain/auth_validation.dart';
import 'package:resume_job_finder/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:resume_job_finder/features/auth/presentation/cubit/auth_state.dart';

import '../../../support/controlled_auth_repository.dart';

const user = AuthUser(
  id: 'test-user',
  fullName: 'Amina Hassan',
  email: 'amina@example.com',
);

void main() {
  late ControlledAuthRepository repository;
  late AuthCubit cubit;
  setUp(() {
    repository = ControlledAuthRepository();
    cubit = AuthCubit(repository);
  });
  tearDown(() => cubit.close());

  for (final provider in AuthProvider.values) {
    test(
      '${provider.name} uses repository authentication and blocks duplicate submissions',
      () async {
        final pending = cubit.signInWithProvider(provider);
        expect(cubit.state.isLoading, isTrue);
        await cubit.signInWithProvider(provider);
        await cubit.signIn(email: user.email, password: 'password');
        expect(repository.providerRequests, [provider]);
        expect(repository.signInCalls, 0);
        repository.providerResult.complete(user);
        await pending;
        expect(cubit.state.status, AuthStatus.authenticated);
        expect(cubit.state.user, same(user));
      },
    );
  }

  test(
    'provider unavailability is a typed failure without a signed-in user',
    () async {
      final pending = cubit.signInWithProvider(AuthProvider.google);
      repository.providerResult.completeError(
        const AuthException(AuthFailure.providerUnavailable),
      );
      await pending;
      expect(cubit.state.failure, AuthFailure.providerUnavailable);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.user, isNull);
      expect(repository.currentUser, isNull);
    },
  );

  test('empty login fields never reach the repository', () async {
    await cubit.signIn(email: ' ', password: ' ');
    expect(cubit.state.errors, {
      AuthField.email: AuthValidationError.emailRequired,
      AuthField.password: AuthValidationError.passwordRequired,
    });
    expect(repository.signInCalls, 0);
  });

  test(
    'email validation rejects malformed addresses and accepts common addresses',
    () {
      for (final email in [
        'no-at',
        'a@@example.com',
        'a b@example.com',
        '.a@example.com',
        'a..b@example.com',
        'a@-example.com',
        'a@example..com',
        'a@example',
        'a@example.com ',
        ' a+tag@example.co.uk ',
      ]) {
        final errors = AuthValidation.login(email: email, password: 'password');
        expect(
          errors.containsKey(AuthField.email),
          email != 'a@example.com ' && email != ' a+tag@example.co.uk ',
          reason: email,
        );
      }
    },
  );

  test(
    'registration validates all fields and password confirmation centrally',
    () async {
      await cubit.register(
        fullName: ' ',
        email: 'invalid',
        password: 'short',
        confirmPassword: 'different',
      );
      expect(cubit.state.errors, {
        AuthField.fullName: AuthValidationError.nameRequired,
        AuthField.email: AuthValidationError.emailInvalid,
        AuthField.password: AuthValidationError.passwordTooShort,
        AuthField.confirmPassword: AuthValidationError.passwordMismatch,
      });
      expect(repository.registrationCalls, 0);
      await cubit.register(
        fullName: 'Amina',
        email: user.email,
        password: 'long-enough',
        confirmPassword: '',
      );
      expect(
        cubit.state.errors[AuthField.confirmPassword],
        AuthValidationError.confirmationRequired,
      );
    },
  );

  test('login emits loading, blocks duplicate requests and returns the actual user', () async {
    final pending = cubit.signIn(email: user.email, password: 'password');
    expect(cubit.state.isLoading, isTrue);
    await cubit.signIn(email: user.email, password: 'password');
    await cubit.register(
      fullName: user.fullName,
      email: user.email,
      password: 'password',
      confirmPassword: 'password',
    );
    expect(repository.signInCalls, 1);
    expect(repository.registrationCalls, 0);
    repository.signInResult.complete(user);
    await pending;
    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.user, same(user));
  });

  test(
    'registration succeeds without authenticating the new account',
    () async {
      final pending = cubit.register(
        fullName: user.fullName,
        email: user.email,
        password: 'password',
        confirmPassword: 'password',
      );
      expect(cubit.state.isLoading, isTrue);
      await cubit.register(
        fullName: user.fullName,
        email: user.email,
        password: 'password',
        confirmPassword: 'password',
      );
      expect(repository.registrationCalls, 1);
      repository.registrationResult.complete(user);
      await pending;
      expect(cubit.state.status, AuthStatus.registered);
      expect(cubit.state.user, same(user));
      expect(repository.currentUser, isNull);
    },
  );

  test(
    'repository failures remain typed and unexpected errors stay private',
    () async {
      final login = cubit.signIn(email: user.email, password: 'password');
      repository.signInResult.completeError(
        const AuthException(AuthFailure.invalidCredentials),
      );
      await login;
      expect(cubit.state.failure, AuthFailure.invalidCredentials);
      final signup = cubit.register(
        fullName: user.fullName,
        email: user.email,
        password: 'password',
        confirmPassword: 'password',
      );
      repository.registrationResult.completeError(
        StateError('Private backend detail'),
      );
      await signup;
      expect(cubit.state.failure, AuthFailure.unavailable);
      expect(cubit.state.isLoading, isFalse);
    },
  );

  test('editing a password clears its stale confirmation error only', () async {
    await cubit.register(
      fullName: '',
      email: user.email,
      password: 'long-pass',
      confirmPassword: 'different',
    );
    cubit.clearError(AuthField.password);
    expect(cubit.state.errors, {
      AuthField.fullName: AuthValidationError.nameRequired,
    });
  });

  test(
    'closing during a request does not emit or throw after disposal',
    () async {
      final pending = cubit.signIn(email: user.email, password: 'password');
      await cubit.close();
      repository.signInResult.complete(user);
      await expectLater(pending, completes);
    },
  );

  test('sign-out failure retains the user and allows retry', () async {
    final login = cubit.signIn(email: user.email, password: 'password');
    repository.signInResult.complete(user);
    await login;
    repository.failSignOut = true;
    await cubit.signOut();
    expect(cubit.state.failure, AuthFailure.unavailable);
    expect(cubit.state.user, same(user));
    repository.failSignOut = false;
    await cubit.signOut();
    expect(cubit.state.status, AuthStatus.signedOut);
    expect(repository.currentUser, isNull);
  });

  test('signup journey authenticates before emitting registered', () async {
    final pending = cubit.register(
      fullName: user.fullName,
      email: user.email,
      password: 'password',
      confirmPassword: 'password',
      signInAfterRegistration: true,
    );
    repository.registrationResult.complete(user);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isLoading, isTrue);
    expect(repository.signInCalls, 1);
    repository.signInResult.complete(user);
    await pending;
    expect(cubit.state.status, AuthStatus.registered);
    expect(repository.currentUser, same(user));
  });

  test('partial signup gives actionable feedback without pretending authentication', () async {
    final pending = cubit.register(
      fullName: user.fullName,
      email: user.email,
      password: 'password',
      confirmPassword: 'password',
      signInAfterRegistration: true,
    );
    repository.registrationResult.complete(user);
    await Future<void>.delayed(Duration.zero);
    repository.signInResult.completeError(
      StateError('Private provider failure'),
    );
    await pending;
    expect(cubit.state.failure, AuthFailure.registrationSignInFailed);
    expect(repository.currentUser, isNull);
  });
}
