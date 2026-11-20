import 'package:resume_job_finder/features/home/domain/dashboard_repository.dart';
import 'package:resume_job_finder/features/home/domain/job_preview.dart';
import 'package:resume_job_finder/features/career_preferences/domain/career_preferences.dart';

/// Test-only provider responses, never shipped or registered in application DI.
class TestDashboardRepository implements DashboardRepository {
  TestDashboardRepository({this.delay = Duration.zero});
  final Duration delay;
  static const samples = [
    JobPreview(id: 'sample-care', title: 'Nurse', employer: 'Test employer', location: 'Cairo', arrangement: WorkArrangement.onSite),
    JobPreview(id: 'sample-education', title: 'Teacher', employer: 'Test school', location: 'Cairo', arrangement: WorkArrangement.hybrid),
    JobPreview(id: 'sample-trade', title: 'Electrician', employer: 'Test employer', location: 'Cairo', arrangement: WorkArrangement.onSite),
  ];
  @override
  Future<List<JobPreview>> loadRecommendations(String userId) async {
    await Future<void>.delayed(delay);
    return samples;
  }
}
