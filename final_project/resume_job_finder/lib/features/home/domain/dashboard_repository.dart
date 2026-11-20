import 'job_preview.dart';

class DashboardUnavailable implements Exception {
  const DashboardUnavailable();
}

abstract interface class DashboardRepository {
  /// Return only provider data for the authenticated user. Empty means a
  /// successful query with no results; unavailable services must throw.
  Future<List<JobPreview>> loadRecommendations(String userId);
}
