import '../../career_preferences/domain/career_preferences.dart';

class JobPreview {
  const JobPreview({
    required this.id,
    required this.title,
    required this.employer,
    required this.location,
    required this.arrangement,
  });

  final String id;
  final String title;
  final String employer;
  final String location;
  final WorkArrangement arrangement;
}
