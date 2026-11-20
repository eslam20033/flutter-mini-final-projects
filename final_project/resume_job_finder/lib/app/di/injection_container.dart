import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/app_settings/presentation/cubit/app_settings_cubit.dart';
import '../../features/auth/data/mock_auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/career_preferences/data/mock_career_preferences_repository.dart';
import '../../features/career_preferences/domain/career_preferences_repository.dart';
import '../../features/home/data/mock_dashboard_repository.dart';
import '../../features/home/domain/dashboard_repository.dart';
import '../router/app_router.dart';
import '../router/app_routes.dart';
import '../router/auth_session.dart';

final getIt = GetIt.instance;

/// Call once before runApp. Tests pass GetIt.asNewInstance() for isolation.
void configureDependencies(GetIt services) {
  // BlocProvider owns and closes each factory-created Cubit.
  services.registerFactory<AppSettingsCubit>(AppSettingsCubit.new);
  services.registerLazySingleton<AuthRepository>(
    () => MockAuthRepository(
      onRecoveryRequested: (request) {
        // Local-only substitute for opening a provider's emailed reset link.
        final router = services<GoRouter>();
        if (router.state.matchedLocation == AppRoutes.forgotPassword) {
          unawaited(
            router.pushNamed<void>(AppRoutes.resetPasswordName, extra: request),
          );
        }
      },
    ),
    dispose: (repository) => (repository as MockAuthRepository).close(),
  );
  services.registerLazySingleton<AuthSession>(
    () => AuthSession(services<AuthRepository>()),
    dispose: (session) => session.dispose(),
  );
  services.registerLazySingleton<CareerPreferencesRepository>(
    MockCareerPreferencesRepository.new,
  );
  services.registerLazySingleton<DashboardRepository>(
    MockDashboardRepository.new,
  );

  // Keep one router across locale/theme rebuilds. The container owns disposal.
  services.registerLazySingleton<GoRouter>(
    () => createAppRouter(
      session: services<AuthSession>(),
      preferencesRepository: services<CareerPreferencesRepository>(),
      dashboardRepository: services<DashboardRepository>(),
    ),
    dispose: (router) => router.dispose(),
  );
}
