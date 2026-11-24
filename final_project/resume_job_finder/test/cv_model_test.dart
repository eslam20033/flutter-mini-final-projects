import 'package:flutter_test/flutter_test.dart';
import 'package:resume_job_finder/core/constants/app_constants.dart';
import 'package:resume_job_finder/core/utils/date_formatter.dart';
import 'package:resume_job_finder/core/utils/file_size_formatter.dart';
import 'package:resume_job_finder/data/models/cv_model.dart';

void main() {
  group('CvModel Tests', () {
    test('CvModel serialization and deserialization works correctly', () {
      final now = DateTime(2026, 11, 22, 14, 30);
      final cv = CvModel(
        id: 'test_id_123',
        userId: 'user_456',
        fileName: 'Ahmed_Resume.pdf',
        fileSize: 1048576, // 1 MB
        downloadUrl: 'https://firebase.storage.com/ahmed.pdf',
        storagePath: 'user_resumes/user_456/ahmed.pdf',
        localPath: '/local/path/ahmed.pdf',
        parsedText: 'Flutter Dart Firebase SQLite Specialist',
        uploadedAt: now,
        isActive: true,
        analysisStatus: 'analyzed',
        matchScore: 92,
      );

      final jsonMap = cv.toJson();
      final reconstructed = CvModel.fromJson(jsonMap);

      expect(reconstructed.id, equals('test_id_123'));
      expect(reconstructed.userId, equals('user_456'));
      expect(reconstructed.fileName, equals('Ahmed_Resume.pdf'));
      expect(reconstructed.fileSize, equals(1048576));
      expect(reconstructed.localPath, equals('/local/path/ahmed.pdf'));
      expect(reconstructed.parsedText, equals('Flutter Dart Firebase SQLite Specialist'));
      expect(reconstructed.isActive, isTrue);
      expect(reconstructed.matchScore, equals(92));
    });

    test('CvModel SQLite Map conversion (Page 7 Schema: id, userId, localPath, parsedText)', () {
      final now = DateTime(2026, 11, 22, 12, 00);
      final cv = CvModel(
        id: 'sqlite_cv_1',
        userId: 'user_001',
        fileName: 'Resume_2026.pdf',
        fileSize: 524288,
        localPath: '/data/user/0/app/user_resumes/user_001/resume.pdf',
        parsedText: 'Experienced Mobile Developer',
        uploadedAt: now,
        isActive: true,
      );

      final sqliteMap = cv.toSqliteMap();
      expect(sqliteMap['id'], equals('sqlite_cv_1'));
      expect(sqliteMap['userId'], equals('user_001'));
      expect(sqliteMap['localPath'], equals('/data/user/0/app/user_resumes/user_001/resume.pdf'));
      expect(sqliteMap['parsedText'], equals('Experienced Mobile Developer'));
      expect(sqliteMap['isActive'], equals(1));

      final restored = CvModel.fromSqliteMap(sqliteMap);
      expect(restored.id, equals('sqlite_cv_1'));
      expect(restored.isActive, isTrue);
      expect(restored.parsedText, equals('Experienced Mobile Developer'));
      expect(restored.localPath, equals('/data/user/0/app/user_resumes/user_001/resume.pdf'));
    });

    test('CvModel list encoding and decoding', () {
      final cv1 = CvModel(
        id: 'cv_1',
        userId: 'user_1',
        fileName: 'cv1.pdf',
        fileSize: 2048,
        localPath: '/path/cv1.pdf',
        downloadUrl: 'url1',
        storagePath: 'path1',
        uploadedAt: DateTime.now(),
        isActive: true,
      );

      final cv2 = CvModel(
        id: 'cv_2',
        userId: 'user_1',
        fileName: 'cv2.pdf',
        fileSize: 4096,
        localPath: '/path/cv2.pdf',
        downloadUrl: 'url2',
        storagePath: 'path2',
        uploadedAt: DateTime.now(),
        isActive: false,
      );

      final encoded = CvModel.encodeList([cv1, cv2]);
      final decoded = CvModel.decodeList(encoded);

      expect(decoded.length, equals(2));
      expect(decoded[0].id, equals('cv_1'));
      expect(decoded[0].isActive, isTrue);
      expect(decoded[1].id, equals('cv_2'));
      expect(decoded[1].isActive, isFalse);
    });
  });

  group('Utility Formatter Tests', () {
    test('FileSizeFormatter formats bytes to human readable string', () {
      expect(FileSizeFormatter.formatBytes(500), equals('500.0 B'));
      expect(FileSizeFormatter.formatBytes(1024), equals('1.0 KB'));
      expect(FileSizeFormatter.formatBytes(1048576), equals('1.0 MB'));
      expect(FileSizeFormatter.formatBytes(AppConstants.maxFileSizeBytes), equals('10.0 MB'));
    });

    test('DateFormatter formats dates properly', () {
      final date = DateTime(2026, 11, 22, 10, 0);
      expect(DateFormatter.formatShort(date), equals('22 Nov 2026'));
    });
  });
}
