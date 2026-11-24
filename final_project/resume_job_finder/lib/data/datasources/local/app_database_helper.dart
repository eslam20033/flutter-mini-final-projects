import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/cv_model.dart';

class AppDatabaseHelper {
  static const String _databaseName = 'job_finder_app.db';
  static const int _databaseVersion = 1;

  // Table names as per System Design (Page 7)
  static const String tableResumes = 'resumes';
  static const String tableUsers = 'users';
  static const String tableJobs = 'jobs';
  static const String tableApplications = 'applications';
  static const String tableMatchResults = 'match_results';
  static const String tableSkills = 'skills';
  static const String tableCandidateSkills = 'candidate_skills';
  static const String tableSavedJobs = 'saved_jobs';

  // Web fallback storage key
  static const String _webResumesPrefKey = 'web_sqlite_resumes_fallback';

  AppDatabaseHelper._internal();
  static final AppDatabaseHelper instance = AppDatabaseHelper._internal();

  static Database? _database;

  Future<Database?> get database async {
    if (kIsWeb) return null; // Web uses SharedPreferences fallback
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Table resumes (Page 7: id, userId, localPath, parsedText + metadata)
    await db.execute('''
      CREATE TABLE $tableResumes (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        fileName TEXT NOT NULL,
        fileSize INTEGER NOT NULL,
        localPath TEXT NOT NULL,
        parsedText TEXT,
        downloadUrl TEXT,
        storagePath TEXT,
        uploadedAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 0,
        analysisStatus TEXT DEFAULT 'not_analyzed',
        matchScore INTEGER
      )
    ''');

    // 2. Table users (Page 7: id, name, email, role)
    await db.execute('''
      CREATE TABLE $tableUsers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'job_seeker'
      )
    ''');

    // 3. Table jobs (Page 7: id, title, requirements, source)
    await db.execute('''
      CREATE TABLE $tableJobs (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        requirements TEXT NOT NULL,
        source TEXT NOT NULL
      )
    ''');

    // 4. Table applications (Page 7: id, userId, jobId, status)
    await db.execute('''
      CREATE TABLE $tableApplications (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        jobId TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    // 5. Table match_results (Page 7: userId, jobId, score, gaps)
    await db.execute('''
      CREATE TABLE $tableMatchResults (
        userId TEXT NOT NULL,
        jobId TEXT NOT NULL,
        score INTEGER NOT NULL,
        gaps TEXT,
        PRIMARY KEY (userId, jobId)
      )
    ''');

    // 6. Table skills (Page 7: id, name)
    await db.execute('''
      CREATE TABLE $tableSkills (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // 7. Table candidate_skills (Page 7: userId, skillId, level)
    await db.execute('''
      CREATE TABLE $tableCandidateSkills (
        userId TEXT NOT NULL,
        skillId TEXT NOT NULL,
        level TEXT,
        PRIMARY KEY (userId, skillId)
      )
    ''');

    // 8. Table saved_jobs (Page 7: userId, jobId, savedAt)
    await db.execute('''
      CREATE TABLE $tableSavedJobs (
        userId TEXT NOT NULL,
        jobId TEXT NOT NULL,
        savedAt TEXT NOT NULL,
        PRIMARY KEY (userId, jobId)
      )
    ''');
  }

  // ----------------- CRUD for Resumes (Member #3) -----------------

  /// Insert a new CV into SQLite database (or Web fallback storage)
  Future<int> insertResume(CvModel cv) async {
    if (kIsWeb) {
      final list = await _loadWebResumes(cv.userId);
      final updated = list.where((item) => item.id != cv.id).toList();
      if (cv.isActive) {
        for (int i = 0; i < updated.length; i++) {
          updated[i] = updated[i].copyWith(isActive: false);
        }
      }
      updated.insert(0, cv);
      await _saveWebResumes(updated);
      return 1;
    }

    final db = await database;
    if (db == null) return 0;

    // If marked active, set other CVs for this user to inactive first
    if (cv.isActive) {
      await db.update(
        tableResumes,
        {'isActive': 0},
        where: 'userId = ?',
        whereArgs: [cv.userId],
      );
    }

    return await db.insert(
      tableResumes,
      cv.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all CVs for a specific user, ordered by upload date descending
  Future<List<CvModel>> getResumesByUserId(String userId) async {
    if (kIsWeb) {
      return await _loadWebResumes(userId);
    }

    final db = await database;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      tableResumes,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'uploadedAt DESC',
    );

    return List.generate(maps.length, (i) => CvModel.fromSqliteMap(maps[i]));
  }

  /// Get the currently Active CV for a user
  Future<CvModel?> getActiveResume(String userId) async {
    if (kIsWeb) {
      final list = await _loadWebResumes(userId);
      try {
        return list.firstWhere((cv) => cv.isActive);
      } catch (_) {
        return list.isNotEmpty ? list.first : null;
      }
    }

    final db = await database;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      tableResumes,
      where: 'userId = ? AND isActive = 1',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return CvModel.fromSqliteMap(maps.first);
    }

    // Fallback: if no CV is marked active but resumes exist, return the most recent one
    final fallback = await getResumesByUserId(userId);
    return fallback.isNotEmpty ? fallback.first : null;
  }

  /// Mark a specific CV as Active in SQLite (or Web fallback storage)
  Future<void> setActiveResume(String cvId, String userId) async {
    if (kIsWeb) {
      final list = await _loadWebResumes(userId);
      final updated = list.map((cv) {
        return cv.copyWith(isActive: cv.id == cvId);
      }).toList();
      await _saveWebResumes(updated);
      return;
    }

    final db = await database;
    if (db == null) return;

    await db.transaction((txn) async {
      // 1. Deactivate all for this user
      await txn.update(
        tableResumes,
        {'isActive': 0},
        where: 'userId = ?',
        whereArgs: [userId],
      );

      // 2. Activate selected CV
      await txn.update(
        tableResumes,
        {'isActive': 1},
        where: 'id = ? AND userId = ?',
        whereArgs: [cvId, userId],
      );
    });
  }

  /// Delete CV from SQLite database (or Web fallback storage)
  Future<int> deleteResume(String cvId) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_webResumesPrefKey) ?? '';
      final list = CvModel.decodeList(jsonStr);
      final filtered = list.where((cv) => cv.id != cvId).toList();
      await _saveWebResumes(filtered);
      return 1;
    }

    final db = await database;
    if (db == null) return 0;

    return await db.delete(
      tableResumes,
      where: 'id = ?',
      whereArgs: [cvId],
    );
  }

  /// Update parsed text extracted by AI (for Member #4 handoff)
  Future<int> updateResumeParsedText(String cvId, String parsedText) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_webResumesPrefKey) ?? '';
      final list = CvModel.decodeList(jsonStr);
      final updated = list.map((cv) {
        if (cv.id == cvId) {
          return cv.copyWith(parsedText: parsedText, analysisStatus: 'analyzing');
        }
        return cv;
      }).toList();
      await _saveWebResumes(updated);
      return 1;
    }

    final db = await database;
    if (db == null) return 0;

    return await db.update(
      tableResumes,
      {
        'parsedText': parsedText,
        'analysisStatus': 'analyzing',
      },
      where: 'id = ?',
      whereArgs: [cvId],
    );
  }

  // Web fallback storage helpers
  Future<List<CvModel>> _loadWebResumes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_webResumesPrefKey) ?? '';
    final all = CvModel.decodeList(jsonStr);
    return all.where((cv) => cv.userId == userId || userId.isEmpty).toList();
  }

  Future<void> _saveWebResumes(List<CvModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_webResumesPrefKey, CvModel.encodeList(list));
  }
}
