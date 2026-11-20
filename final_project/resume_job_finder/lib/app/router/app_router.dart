import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/password_recovery.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/career_preferences/domain/career_preferences_repository.dart';
import '../../features/career_preferences/presentation/cubit/career_preferences_cubit.dart';
import '../../features/career_preferences/presentation/pages/career_preferences_page.dart';
import '../../features/home/domain/dashboard_repository.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../core/localization/l10n_extension.dart';
import 'app_routes.dart';
import 'auth_session.dart';

GoRouter createAppRouter({
  required AuthSession session,
  required CareerPreferencesRepository preferencesRepository,
  required DashboardRepository dashboardRepository,
  String? initialLocation,
}) {
  final authRepository = session.repository;
  PasswordResetRequest? resetRequest(GoRouterState state) {
    final extra = state.extra;
    if (extra is PasswordResetRequest && extra.code.trim().isNotEmpty) return extra;
    final code = state.uri.queryParameters['oobCode'];
    if (state.uri.queryParameters['mode'] == 'resetPassword' &&
        code != null && code.trim().isNotEmpty) {
      return PasswordResetRequest(code: code);
    }
    return null;
  }
  return GoRouter(
    refreshListenable: session,
    onException: (context, state, router) => router.go(
      session.user == null ? AppRoutes.login : AppRoutes.home,
    ),
    // Null preserves the platform's initial deep link; tests can override it.
    initialLocation: initialLocation,
    redirect: (context, state) {
      final path = state.matchedLocation;
      if (!session.ready || session.failed) {
        if (path != AppRoutes.start) {
          session.pendingLocation ??= state.uri.toString();
          return AppRoutes.start;
        }
        return null;
      }
      final signedIn = session.user != null;
      if (path == AppRoutes.start && session.introductionFinished) {
        final pending = session.pendingLocation;
        session.pendingLocation = null;
        return pending ?? (signedIn ? AppRoutes.home : AppRoutes.onboarding);
      }
      if ([
            AppRoutes.preview,
            AppRoutes.home,
            AppRoutes.careerPreferences,
          ].contains(path) &&
          !signedIn) {
        return AppRoutes.login;
      }
      if (signedIn &&
          [
            AppRoutes.login,
            AppRoutes.signUp,
            AppRoutes.forgotPassword,
            AppRoutes.resetPassword,
          ].contains(path)) {
        return path == AppRoutes.signUp ? AppRoutes.careerPreferences : AppRoutes.home;
      }
      if (path == AppRoutes.resetPassword &&
          resetRequest(state) == null) {
        return AppRoutes.forgotPassword;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.start,
        name: AppRoutes.startName,
        builder: (context, state) => AnimatedBuilder(
          animation: session,
          builder: (context, _) => SplashPage(
            onFinished: session.finishIntroduction,
            isRestoring: !session.ready && !session.failed,
            errorMessage: session.failed ? context.l10n.sessionUnavailable : null,
            onRetry: session.restore,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        builder: (context, state) => OnboardingPage(
          onCompleted: () => context.goNamed(AppRoutes.loginName),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => BlocProvider(
          create: (_) => AuthCubit(authRepository),
          child: LoginPage(
            registeredEmail: state.extra is String
                ? state.extra as String
                : null,
            onBack: () => context.goNamed(AppRoutes.onboardingName),
            onSignUp: () => context.pushNamed<String>(AppRoutes.signUpName),
            onSignedIn: () => context.goNamed(AppRoutes.homeName),
            onForgotPassword: () =>
                context.pushNamed(AppRoutes.forgotPasswordName),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: AppRoutes.signUpName,
        builder: (context, state) => BlocProvider(
          create: (_) => AuthCubit(authRepository),
          child: SignUpPage(
            onSignedIn: () => context.goNamed(AppRoutes.homeName),
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(AppRoutes.loginName);
              }
            },
            onRegistered: (_) =>
                context.goNamed(AppRoutes.careerPreferencesName),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        builder: (context, state) => BlocProvider(
          create: (_) => AuthCubit(authRepository),
          child: ForgotPasswordPage(
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(AppRoutes.loginName);
              }
            },
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: AppRoutes.resetPasswordName,
        builder: (context, state) => BlocProvider(
          create: (_) => AuthCubit(authRepository),
          child: ResetPasswordPage(
            request: resetRequest(state)!,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(AppRoutes.forgotPasswordName);
              }
            },
            onLogin: () => context.goNamed(AppRoutes.loginName),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.preview,
        name: AppRoutes.previewName,
        redirect: (_, _) => AppRoutes.home,
      ),
      GoRoute(
        path: AppRoutes.careerPreferences,
        name: AppRoutes.careerPreferencesName,
        builder: (context, state) => BlocProvider(
          key: ValueKey('career-${session.user!.id}'),
          create: (_) => CareerPreferencesCubit(
            preferencesRepository,
            session.user!.id,
          )..load(),
          child: CareerPreferencesPage(
            onBack: () {
              if (context.canPop()) {
                context.pop(false);
              } else {
                context.goNamed(AppRoutes.homeName);
              }
            },
            onSaved: () {
              if (context.canPop()) {
                // Home reloads its summary when the editor returns true.
                context.pop(true);
              } else {
                context.goNamed(AppRoutes.homeName);
              }
            },
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (context, state) => MultiBlocProvider(
          key: ValueKey('home-${session.user!.id}'),
          providers: [
            BlocProvider(create: (_) => AuthCubit(authRepository)),
            BlocProvider(
              create: (_) => HomeCubit(
                preferencesRepository,
                dashboardRepository,
                session.user!.id,
              )..load(),
            ),
          ],
          child: HomePage(
            onEditPreferences: () =>
                context.pushNamed<bool>(AppRoutes.careerPreferencesName),
            onSignedOut: () => context.goNamed(AppRoutes.loginName),
          ),
        ),
      ),
    ],
  );
}

