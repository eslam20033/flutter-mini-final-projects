import '../domain/dashboard_repository.dart';
import '../domain/job_preview.dart';

/// No live vacancies or AI matching are available in the local demonstration.
class MockDashboardRepository implements DashboardRepository {
  MockDashboardRepository({this.delay = const Duration(milliseconds: 350)});
  final Duration delay;

  @override
  Future<List<JobPreview>> loadRecommendations(String userId) async {
    await Future<void>.delayed(delay);
    return const [];
  }
}
