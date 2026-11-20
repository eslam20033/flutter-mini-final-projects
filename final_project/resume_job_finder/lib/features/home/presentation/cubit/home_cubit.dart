import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../career_preferences/domain/career_preferences.dart';
import '../../../career_preferences/domain/career_preferences_repository.dart';
import '../../domain/dashboard_repository.dart';
import '../../domain/job_preview.dart';

enum HomeStatus { initial, loading, ready, failure }

class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.preferences,
    this.jobs = const [],
  });
  final HomeStatus status;
  final CareerPreferences? preferences;
  final List<JobPreview> jobs;
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._preferences, this._dashboard, this._userId)
    : super(const HomeState());
  final CareerPreferencesRepository _preferences;
  final DashboardRepository _dashboard;
  final String _userId;

  Future<void> load() async {
    if (isClosed || state.status == HomeStatus.loading) return;
    emit(const HomeState(status: HomeStatus.loading));
    try {
      final (preferences, jobs) = await (
        _preferences.load(_userId),
        _dashboard.loadRecommendations(_userId),
      ).wait;
      if (!isClosed) {
        emit(
          HomeState(
            status: HomeStatus.ready,
            preferences: preferences,
            jobs: List.unmodifiable(jobs),
          ),
        );
      }
    } catch (_) {
      if (!isClosed) emit(const HomeState(status: HomeStatus.failure));
    }
  }
}
