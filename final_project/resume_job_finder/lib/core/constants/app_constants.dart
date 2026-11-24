class AppConstants {
  static const String appName = 'Resume & Job Finder';
  
  // Validation limits for CV upload
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB maximum
  static const String allowedExtension = 'pdf';
  static const List<String> allowedExtensions = ['pdf'];

  // Firestore Collections & Keys
  static const String usersCollection = 'users';
  static const String cvsCollection = 'cvs';
  static const String defaultUserId = 'user_demo_01'; // Used when FirebaseAuth is pending
  
  // Storage Paths
  static const String cvStorageFolder = 'user_resumes';
  
  // SharedPreferences keys
  static const String prefsActiveCvId = 'active_cv_id';
  static const String prefsLocalCvs = 'cached_user_cvs_v1';
}
