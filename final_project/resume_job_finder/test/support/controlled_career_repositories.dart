import 'package:resume_job_finder/features/career_preferences/domain/career_preferences.dart';
import 'package:resume_job_finder/features/career_preferences/domain/career_preferences_repository.dart';
import 'package:resume_job_finder/features/home/domain/dashboard_repository.dart';
import 'package:resume_job_finder/features/home/domain/job_preview.dart';

class ControlledPreferencesRepository implements CareerPreferencesRepository {
  final stored = <String, CareerPreferences>{};
  bool failLoad = false;
  bool failSave = false;
  int loadCalls = 0;
  int saveCalls = 0;
  Future<void>? loadGate;
  Future<void>? saveGate;

  @override
  Future<CareerPreferences?> load(String userId) async {
    loadCalls++;
    if (loadGate != null) await loadGate;
    if (failLoad) throw StateError('Private storage failure');
    return stored[userId];
  }

  @override
  Future<void> save(String userId, CareerPreferences preferences) async {
    saveCalls++;
    if (saveGate != null) await saveGate;
    if (failSave) throw StateError('Private save failure');
    stored[userId] = preferences;
  }
}

class ControlledDashboardRepository implements DashboardRepository {
  List<JobPreview> jobs = [];
  bool fail = false;
  int calls = 0;
  String? lastUserId;
  Future<void>? gate;

  @override
  Future<List<JobPreview>> loadRecommendations(String userId) async {
    calls++;
    lastUserId = userId;
    if (gate != null) await gate;
    if (fail) throw StateError('Private recommendations failure');
    return jobs;
  }
}
