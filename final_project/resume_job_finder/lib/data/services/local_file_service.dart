import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalFileService {
  static const String resumesDirectoryName = 'user_resumes';

  /// Saves a picked file into the app's persistent documents directory (on Mobile/Desktop)
  static Future<String> savePermanentPdfFile({
    File? sourceFile,
    Uint8List? sourceBytes,
    required String userId,
    required String uniqueId,
    required String originalFileName,
  }) async {
    if (kIsWeb) {
      // On Web, local filesystem paths do not exist in the browser sandbox
      return 'web://user_resumes/$userId/${uniqueId}_${originalFileName.replaceAll(' ', '_')}';
    }

    final appDocsDir = await getApplicationDocumentsDirectory();
    final userResumesDir = Directory(p.join(appDocsDir.path, resumesDirectoryName, userId));

    if (!await userResumesDir.exists()) {
      await userResumesDir.create(recursive: true);
    }

    final sanitizedName = originalFileName.replaceAll(' ', '_');
    final permanentPath = p.join(userResumesDir.path, '${uniqueId}_$sanitizedName');

    if (sourceBytes != null) {
      final file = File(permanentPath);
      await file.writeAsBytes(sourceBytes);
      return permanentPath;
    } else if (sourceFile != null) {
      final copied = await sourceFile.copy(permanentPath);
      return copied.path;
    }

    return permanentPath;
  }

  /// Delete a local CV file if it exists
  static Future<void> deleteLocalPdfFile(String? localPath) async {
    if (kIsWeb || localPath == null || localPath.isEmpty || localPath.startsWith('web://')) {
      return;
    }
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
