import 'package:resume_job_finder/features/career_preferences/domain/career_preferences.dart';
import 'package:resume_job_finder/features/career_preferences/domain/career_preferences_repository.dart';

/// Per-account, in-memory storage. A new container/restart clears preferences.
class TestCareerPreferencesRepository implements CareerPreferencesRepository {
  TestCareerPreferencesRepository({
    this.delay = const Duration(milliseconds: 350),
  });
  final Duration delay;
  final _preferences = <String, CareerPreferences>{};

  @override
  Future<CareerPreferences?> load(String userId) async {
    await Future<void>.delayed(delay);
    return _preferences[userId];
  }

  @override
  Future<void> save(String userId, CareerPreferences preferences) async {
    await Future<void>.delayed(delay);
    _preferences[userId] = preferences;
  }
}
