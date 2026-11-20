import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/features/career_preferences/domain/career_preferences.dart';
import 'package:resume_job_finder/features/home/data/unavailable_dashboard_repository.dart';
import 'package:resume_job_finder/features/home/domain/dashboard_repository.dart';
import 'package:resume_job_finder/features/home/domain/job_preview.dart';
import 'package:resume_job_finder/features/home/presentation/cubit/home_cubit.dart';

import '../../support/controlled_career_repositories.dart';

void main() {
  test('unconnected dashboard never returns invented recommendations', () async {
    await expectLater(UnavailableDashboardRepository().loadRecommendations('user'), throwsA(isA<DashboardUnavailable>()));
  });

  test(
    'dashboard supports empty data and arbitrary real provider titles',
    () async {
      final preferences = ControlledPreferencesRepository();
      final dashboard = ControlledDashboardRepository();
      final cubit = HomeCubit(preferences, dashboard, 'one');
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.status, HomeStatus.ready);
      expect(cubit.state.jobs, isEmpty);
      expect(cubit.state.preferences, isNull);
      preferences.stored['one'] = const CareerPreferences(
        jobTitle: 'Archivist',
      );
      dashboard.jobs = [
        const JobPreview(
          id: 'arbitrary',
          title: 'Museum archivist',
          employer: 'Provider employer',
          location: 'Anywhere',
          arrangement: WorkArrangement.any,
        ),
      ];
      await cubit.load();
      expect(cubit.state.preferences!.jobTitle, 'Archivist');
      expect(cubit.state.jobs.single.title, 'Museum archivist');
      expect(dashboard.lastUserId, 'one');
    },
  );

  test('either repository failure gives a safe retryable state', () async {
    final preferences = ControlledPreferencesRepository()..failLoad = true;
    final dashboard = ControlledDashboardRepository();
    final cubit = HomeCubit(preferences, dashboard, 'one');
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.status, HomeStatus.failure);
    preferences.failLoad = false;
    dashboard.fail = true;
    await cubit.load();
    expect(cubit.state.status, HomeStatus.failure);
    dashboard.fail = false;
    await cubit.load();
    expect(cubit.state.status, HomeStatus.ready);
  });

  test(
    'dashboard ignores duplicate loads and completion after disposal',
    () async {
      final gate = Completer<void>();
      final dashboard = ControlledDashboardRepository()..gate = gate.future;
      final cubit = HomeCubit(
        ControlledPreferencesRepository(),
        dashboard,
        'one',
      );
      final pending = cubit.load();
      expect(cubit.state.status, HomeStatus.loading);
      await cubit.load();
      expect(dashboard.calls, 1);
      await cubit.close();
      gate.complete();
      await expectLater(pending, completes);
    },
  );
}
