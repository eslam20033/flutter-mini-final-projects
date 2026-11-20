enum WorkArrangement { any, onSite, hybrid, remote }

class CareerPreferences {
  const CareerPreferences({
    required this.jobTitle,
    this.industry = '',
    this.experienceYears,
    this.experienceLevel = '',
    this.location = '',
    this.arrangement = WorkArrangement.any,
    this.qualifications = '',
  });

  final String jobTitle;
  final String industry;
  final double? experienceYears;
  final String experienceLevel;
  final String location;
  final WorkArrangement arrangement;
  final String qualifications;
}
