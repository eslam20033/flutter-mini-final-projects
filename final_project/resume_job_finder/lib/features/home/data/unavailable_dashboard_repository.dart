import '../domain/dashboard_repository.dart';
import '../domain/job_preview.dart';

class UnavailableDashboardRepository implements DashboardRepository {
  @override
  Future<List<JobPreview>> loadRecommendations(String userId) async =>
      throw const DashboardUnavailable();
}
