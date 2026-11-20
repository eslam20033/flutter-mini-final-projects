import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:resume_job_finder/app/di/injection_container.dart';
import 'package:resume_job_finder/features/app_settings/presentation/cubit/app_settings_cubit.dart';
import 'package:resume_job_finder/features/auth/domain/auth_repository.dart';
import 'package:resume_job_finder/features/career_preferences/domain/career_preferences_repository.dart';
import 'package:resume_job_finder/features/home/domain/dashboard_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DI creates independent Cubits and shares one router', () async {
    final services = GetIt.asNewInstance();
    configureDependencies(services);
    addTearDown(services.reset);

    final first = services<AppSettingsCubit>();
    final second = services<AppSettingsCubit>();
    addTearDown(first.close);
    addTearDown(second.close);

    expect(first, isNot(same(second)));
    expect(services<GoRouter>(), same(services<GoRouter>()));
    expect(services<AuthRepository>(), same(services<AuthRepository>()));
    expect(
      services<CareerPreferencesRepository>(),
      same(services<CareerPreferencesRepository>()),
    );
    expect(
      services<DashboardRepository>(),
      same(services<DashboardRepository>()),
    );
  });

  test('DI can be reset and configured for an isolated test', () async {
    final services = GetIt.asNewInstance();
    configureDependencies(services);
    final originalRouter = services<GoRouter>();
    final originalRepository = services<AuthRepository>();
    await services.reset();

    expect(services.isRegistered<GoRouter>(), isFalse);
    configureDependencies(services);
    addTearDown(services.reset);
    expect(services<GoRouter>(), isNot(same(originalRouter)));
    expect(services<AuthRepository>(), isNot(same(originalRepository)));
  });
}
