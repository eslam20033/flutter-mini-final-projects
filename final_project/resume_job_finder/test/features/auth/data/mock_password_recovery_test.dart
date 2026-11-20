import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/features/auth/data/mock_auth_repository.dart';
import 'package:resume_job_finder/features/auth/domain/auth_repository.dart';
import 'package:resume_job_finder/features/auth/domain/auth_user.dart';
import 'package:resume_job_finder/features/auth/domain/password_recovery.dart';

void main() {
  late MockAuthRepository repository;
  late List<PasswordResetRequest> delivered;
  setUp(() async {
    delivered = [];
    repository = MockAuthRepository(
      delay: Duration.zero,
      onRecoveryRequested: delivered.add,
    );
    await repository.register(
      fullName: 'Amina',
      email: 'amina@example.com',
      password: 'old-password',
    );
  });
  tearDown(() => repository.close());

  Matcher failure(AuthFailure value) => throwsA(
    isA<AuthException>().having((error) => error.failure, 'failure', value),
  );
  Future<PasswordResetRequest> request([
    String email = 'amina@example.com',
  ]) async {
    await repository.requestPasswordRecovery(email: email);
    return delivered.last;
  }

  test('local recovery changes exact password without signing in', () async {
    final reset = await request(' AMINA@EXAMPLE.COM ');
    expect(reset.email, 'amina@example.com');
    expect(reset.code, isNotEmpty);
    await repository.resetPassword(request: reset, password: ' new-password ');
    expect(repository.currentUser, isNull);
    for (final password in ['old-password', 'new-password']) {
      await expectLater(
        repository.signIn(email: reset.email, password: password),
        failure(AuthFailure.invalidCredentials),
      );
    }
    expect(
      (await repository.signIn(
        email: reset.email,
        password: ' new-password ',
      )).fullName,
      'Amina',
    );
  });

  test(
    'unknown recovery requests complete without disclosing account existence',
    () async {
      await repository.requestPasswordRecovery(email: 'unknown@example.com');
      expect(delivered, isEmpty);
      final reset = await request();
      final fresh = MockAuthRepository(delay: Duration.zero);
      addTearDown(fresh.close);
      await fresh.requestPasswordRecovery(email: reset.email);
      await expectLater(
        fresh.resetPassword(request: reset, password: 'new-password'),
        failure(AuthFailure.recoveryExpired),
      );
    },
  );

  test(
    'unissued codes and a mismatched account cannot reset passwords',
    () async {
      final reset = await request();
      for (final invalid in [
        PasswordResetRequest(email: reset.email, code: ''),
        PasswordResetRequest(email: reset.email, code: 'invented-code'),
        PasswordResetRequest(email: 'other@example.com', code: reset.code),
      ]) {
        await expectLater(
          repository.resetPassword(request: invalid, password: 'new-password'),
          failure(AuthFailure.recoveryExpired),
        );
      }
      await repository.signIn(email: reset.email, password: 'old-password');
    },
  );

  test(
    'new requests supersede old codes and success consumes the code',
    () async {
      final old = await request();
      final current = await request();
      expect(current.code, isNot(old.code));
      await expectLater(
        repository.resetPassword(request: old, password: 'new-password'),
        failure(AuthFailure.recoveryExpired),
      );
      // Deep links can contain only the code; email is not proof of ownership.
      await repository.resetPassword(
        request: PasswordResetRequest(code: current.code),
        password: 'new-password',
      );
      await expectLater(
        repository.resetPassword(
          request: current,
          password: 'another-password',
        ),
        failure(AuthFailure.recoveryExpired),
      );
    },
  );

  test(
    'invalid password allows retry and reset emits session invalidation',
    () async {
      final reset = await request();
      for (final password in ['', '        ', 'short']) {
        await expectLater(
          repository.resetPassword(request: reset, password: password),
          failure(AuthFailure.unavailable),
        );
      }
      final events = <AuthUser?>[];
      final subscription = repository.userChanges.listen(events.add);
      addTearDown(subscription.cancel);
      await repository.signIn(email: reset.email, password: 'old-password');
      await repository.resetPassword(request: reset, password: 'new-password');
      await Future<void>.delayed(Duration.zero);
      expect(events.map((user) => user?.email), [reset.email, null]);
      expect(repository.currentUser, isNull);
    },
  );

  test(
    'resetting one account preserves the other session and recovery request',
    () async {
      await repository.register(
        fullName: 'Sam',
        email: 'sam@example.com',
        password: 'sam-password',
      );
      final first = await request();
      final second = await request('sam@example.com');
      await repository.signIn(email: second.email, password: 'sam-password');
      await repository.resetPassword(request: first, password: 'new-password');
      expect(repository.currentUser?.email, second.email);
      await repository.resetPassword(
        request: second,
        password: 'sam-new-password',
      );
      await repository.signIn(email: first.email, password: 'new-password');
      await repository.signIn(
        email: second.email,
        password: 'sam-new-password',
      );
    },
  );
}
