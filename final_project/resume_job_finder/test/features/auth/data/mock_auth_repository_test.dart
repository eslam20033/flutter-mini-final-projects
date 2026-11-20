import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/features/auth/data/mock_auth_repository.dart';
import 'package:resume_job_finder/features/auth/domain/auth_repository.dart';

void main() {
  late MockAuthRepository repository;
  setUp(() => repository = MockAuthRepository(delay: Duration.zero));
  tearDown(() => repository.close());

  Future<void> register({String email = 'amina@example.com'}) =>
      repository.register(
        fullName: '  أمينة حسن  ',
        email: email,
        password: ' demo-pass ',
      );

  Matcher failure(AuthFailure value) => throwsA(
    isA<AuthException>().having((error) => error.failure, 'failure', value),
  );

  for (final provider in AuthProvider.values) {
    test(
      '${provider.name} is unavailable and never creates a mock session',
      () async {
        await expectLater(
          repository.signInWithProvider(provider),
          failure(AuthFailure.providerUnavailable),
        );
        expect(repository.currentUser, isNull);
      },
    );
  }

  test(
    'registration retains the entered name and creates no signed-in session',
    () async {
      final user = await repository.register(
        fullName: ' أمينة حسن ',
        email: ' Amina@Example.COM ',
        password: 'demo-pass',
      );
      expect(user.fullName, 'أمينة حسن');
      expect(user.email, 'amina@example.com');
      expect(user.id, isNotEmpty);
      expect(repository.currentUser, isNull);
      expect(
        (await repository.signIn(
          email: 'AMINA@example.com',
          password: 'demo-pass',
        )).id,
        user.id,
      );
    },
  );

  test('unknown email and wrong password give the same failure', () async {
    await register();
    for (final email in ['nobody@example.com', 'amina@example.com']) {
      await expectLater(
        repository.signIn(email: email, password: 'wrong-pass'),
        failure(AuthFailure.invalidCredentials),
      );
      expect(repository.currentUser, isNull);
    }
  });

  test(
    'password is matched exactly without trimming or case normalization',
    () async {
      await register();
      await expectLater(
        repository.signIn(email: 'amina@example.com', password: 'demo-pass'),
        failure(AuthFailure.invalidCredentials),
      );
      final user = await repository.signIn(
        email: ' amina@EXAMPLE.com ',
        password: ' demo-pass ',
      );
      expect(repository.currentUser, same(user));
    },
  );

  test('duplicate email cannot overwrite a registered account', () async {
    await register();
    await expectLater(
      repository.register(
        fullName: 'Another person',
        email: ' AMINA@EXAMPLE.COM ',
        password: 'another-pass',
      ),
      failure(AuthFailure.emailInUse),
    );
    final user = await repository.signIn(
      email: 'amina@example.com',
      password: ' demo-pass ',
    );
    expect(user.fullName, 'أمينة حسن');
  });

  test(
    'sign-out clears the session and preserves accounts only in this instance',
    () async {
      await register();
      await repository.signIn(
        email: 'amina@example.com',
        password: ' demo-pass ',
      );
      await repository.signOut();
      expect(repository.currentUser, isNull);
      await repository.signIn(
        email: 'amina@example.com',
        password: ' demo-pass ',
      );
      expect(repository.currentUser, isNotNull);
      final fresh = MockAuthRepository(delay: Duration.zero);
      addTearDown(fresh.close);
      expect(fresh.currentUser, isNull);
      await expectLater(
        fresh.signIn(email: 'amina@example.com', password: ' demo-pass '),
        failure(AuthFailure.invalidCredentials),
      );
    },
  );

  test('independent accounts keep their own names and credentials', () async {
    await register();
    final second = await repository.register(
      fullName: 'Sam',
      email: 'sam@example.com',
      password: 'sam-password',
    );
    await expectLater(
      repository.signIn(email: second.email, password: ' demo-pass '),
      failure(AuthFailure.invalidCredentials),
    );
    final signedIn = await repository.signIn(
      email: second.email,
      password: 'sam-password',
    );
    expect(signedIn.fullName, 'Sam');
  });
}
