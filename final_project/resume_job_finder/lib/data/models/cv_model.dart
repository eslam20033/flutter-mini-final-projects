import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class CvModel {
  final String id;
  final String userId;
  final String fileName;
  final int fileSize;
  final String localPath;
  final String? parsedText;
  final String downloadUrl;
  final String storagePath;
  final DateTime uploadedAt;
  final bool isActive;
  final String analysisStatus; // 'not_analyzed', 'analyzing', 'analyzed'
  final int? matchScore; // e.g. 88 (out of 100)
  final Uint8List? fileBytes; // For seamless Web rendering & in-memory caching

  const CvModel({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileSize,
    required this.localPath,
    this.parsedText,
    this.downloadUrl = '',
    this.storagePath = '',
    required this.uploadedAt,
    this.isActive = false,
    this.analysisStatus = 'not_analyzed',
    this.matchScore,
    this.fileBytes,
  });

  // Create a copy with some updated fields
  CvModel copyWith({
    String? id,
    String? userId,
    String? fileName,
    int? fileSize,
    String? localPath,
    String? parsedText,
    String? downloadUrl,
    String? storagePath,
    DateTime? uploadedAt,
    bool? isActive,
    String? analysisStatus,
    int? matchScore,
    Uint8List? fileBytes,
  }) {
    return CvModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      localPath: localPath ?? this.localPath,
      parsedText: parsedText ?? this.parsedText,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      storagePath: storagePath ?? this.storagePath,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      isActive: isActive ?? this.isActive,
      analysisStatus: analysisStatus ?? this.analysisStatus,
      matchScore: matchScore ?? this.matchScore,
      fileBytes: fileBytes ?? this.fileBytes,
    );
  }

  // Convert to SQLite Map
  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'userId': userId,
      'fileName': fileName,
      'fileSize': fileSize,
      'localPath': localPath,
      'parsedText': parsedText,
      'downloadUrl': downloadUrl,
      'storagePath': storagePath,
      'uploadedAt': uploadedAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'analysisStatus': analysisStatus,
      'matchScore': matchScore,
    };
  }

  // Convert from SQLite Map
  factory CvModel.fromSqliteMap(Map<String, dynamic> map, [Uint8List? bytes]) {
    return CvModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fileName: map['fileName'] ?? 'Untitled_Resume.pdf',
      fileSize: (map['fileSize'] as num?)?.toInt() ?? 0,
      localPath: map['localPath'] ?? '',
      parsedText: map['parsedText'],
      downloadUrl: map['downloadUrl'] ?? '',
      storagePath: map['storagePath'] ?? '',
      uploadedAt: DateTime.tryParse(map['uploadedAt'] ?? '') ?? DateTime.now(),
      isActive: (map['isActive'] == 1 || map['isActive'] == true),
      analysisStatus: map['analysisStatus'] ?? 'not_analyzed',
      matchScore: (map['matchScore'] as num?)?.toInt(),
      fileBytes: bytes,
    );
  }

  // Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'fileName': fileName,
      'fileSize': fileSize,
      'localPath': localPath,
      'parsedText': parsedText,
      'downloadUrl': downloadUrl,
      'storagePath': storagePath,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'isActive': isActive,
      'analysisStatus': analysisStatus,
      'matchScore': matchScore,
    };
  }

  // Convert from Firestore DocumentSnapshot or Map
  factory CvModel.fromFirestore(Map<String, dynamic> data, String docId, [Uint8List? bytes]) {
    DateTime parsedDate;
    if (data['uploadedAt'] is Timestamp) {
      parsedDate = (data['uploadedAt'] as Timestamp).toDate();
    } else if (data['uploadedAt'] is String) {
      parsedDate = DateTime.tryParse(data['uploadedAt']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return CvModel(
      id: docId.isNotEmpty ? docId : (data['id'] ?? ''),
      userId: data['userId'] ?? '',
      fileName: data['fileName'] ?? 'Untitled_Resume.pdf',
      fileSize: (data['fileSize'] as num?)?.toInt() ?? 0,
      localPath: data['localPath'] ?? '',
      parsedText: data['parsedText'],
      downloadUrl: data['downloadUrl'] ?? '',
      storagePath: data['storagePath'] ?? '',
      uploadedAt: parsedDate,
      isActive: data['isActive'] ?? false,
      analysisStatus: data['analysisStatus'] ?? 'not_analyzed',
      matchScore: (data['matchScore'] as num?)?.toInt(),
      fileBytes: bytes,
    );
  }

  // JSON representation (for SharedPreferences local persistence)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fileName': fileName,
      'fileSize': fileSize,
      'localPath': localPath,
      'parsedText': parsedText,
      'downloadUrl': downloadUrl,
      'storagePath': storagePath,
      'uploadedAt': uploadedAt.toIso8601String(),
      'isActive': isActive,
      'analysisStatus': analysisStatus,
      'matchScore': matchScore,
      if (fileBytes != null && fileBytes!.length < 4 * 1024 * 1024)
        'fileBytesBase64': base64Encode(fileBytes!),
    };
  }

  factory CvModel.fromJson(Map<String, dynamic> json) {
    Uint8List? decodedBytes;
    if (json['fileBytesBase64'] != null) {
      try {
        decodedBytes = base64Decode(json['fileBytesBase64']);
      } catch (_) {}
    }

    return CvModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      fileName: json['fileName'] ?? 'Untitled_Resume.pdf',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      localPath: json['localPath'] ?? '',
      parsedText: json['parsedText'],
      downloadUrl: json['downloadUrl'] ?? '',
      storagePath: json['storagePath'] ?? '',
      uploadedAt: DateTime.tryParse(json['uploadedAt'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? false,
      analysisStatus: json['analysisStatus'] ?? 'not_analyzed',
      matchScore: (json['matchScore'] as num?)?.toInt(),
      fileBytes: decodedBytes,
    );
  }

  static String encodeList(List<CvModel> cvs) => json.encode(
        cvs.map<Map<String, dynamic>>((cv) => cv.toJson()).toList(),
      );

  static List<CvModel> decodeList(String cvsJson) {
    if (cvsJson.isEmpty) return [];
    try {
      final List<dynamic> list = json.decode(cvsJson);
      return list.map((item) => CvModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
