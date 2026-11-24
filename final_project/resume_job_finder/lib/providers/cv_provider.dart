import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/app_constants.dart';
import '../../core/utils/file_size_formatter.dart';
import '../data/models/cv_model.dart';
import '../data/services/cv_storage_service.dart';

class CvProvider extends ChangeNotifier {
  final CvStorageService _storageService;
  final String _currentUserId;

  List<CvModel> _cvList = [];
  CvModel? _activeCv;
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';
  String? _errorMessage;

  CvProvider({
    CvStorageService? storageService,
    String? currentUserId,
  })  : _storageService = storageService ?? CvStorageService(),
        _currentUserId = currentUserId ?? AppConstants.defaultUserId;

  // Getters
  List<CvModel> get cvList => List.unmodifiable(_cvList);
  CvModel? get activeCv => _activeCv;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String get uploadStatus => _uploadStatus;
  String? get errorMessage => _errorMessage;
  int get totalCvsCount => _cvList.length;

  /// Initialize and load all CVs
  Future<void> loadCvs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cvList = await _storageService.fetchUserCvs(_currentUserId);
      _updateActiveCv();
    } catch (e) {
      _errorMessage = 'Failed to load CVs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pick PDF from device, validate format and size, and upload to Firebase Storage & Firestore
  Future<CvModel?> pickAndUploadCv() async {
    _errorMessage = null;

    try {
      // 1. Pick PDF file from device (withData: true ensures bytes are loaded on Web & Mobile)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedExtensions,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        // User cancelled selection
        return null;
      }

      final platformFile = result.files.first;

      // 2. Validate Extension (.pdf) - safely works on both Web and Mobile
      final extension = (platformFile.extension ??
              p.extension(platformFile.name).replaceAll('.', ''))
          .toLowerCase();
      if (extension != AppConstants.allowedExtension) {
        _errorMessage = 'Invalid file format. Only PDF files are allowed.';
        notifyListeners();
        return null;
      }

      // 3. Validate File Size (<= 10MB) - platformFile.size is available everywhere
      final fileSizeBytes = platformFile.size;
      if (fileSizeBytes > AppConstants.maxFileSizeBytes) {
        final formattedLimit = FileSizeFormatter.formatBytes(AppConstants.maxFileSizeBytes);
        final currentSize = FileSizeFormatter.formatBytes(fileSizeBytes);
        _errorMessage = 'File too large ($currentSize). Maximum allowed size is $formattedLimit.';
        notifyListeners();
        return null;
      }

      // 4. Safely obtain bytes and File without triggering web path exception
      Uint8List? fileBytes = platformFile.bytes;
      File? file;
      if (!kIsWeb) {
        final filePath = platformFile.path;
        if (filePath != null) {
          file = File(filePath);
          if (fileBytes == null && file.existsSync()) {
            fileBytes = await file.readAsBytes();
          }
        }
      }

      // 5. Determine if this should be the Active CV (yes if it's the first CV or none is active)
      final shouldBeActive = _cvList.isEmpty || _activeCv == null;

      // 6. Start Processing, Local/Web Save, SQLite Save & Cloud Upload
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Starting upload...';
      notifyListeners();

      final newCv = await _storageService.processAndUploadCv(
        sourceFile: file,
        fileBytes: fileBytes,
        userId: _currentUserId,
        originalFileName: platformFile.name,
        fileSizeBytes: fileSizeBytes,
        shouldBeActive: shouldBeActive,
        onProgress: (progress, status) {
          _uploadProgress = progress;
          _uploadStatus = status;
          notifyListeners();
        },
      );

      // 6. Update in-memory state
      if (shouldBeActive) {
        _cvList = _cvList.map((cv) => cv.copyWith(isActive: false)).toList();
      }
      _cvList.insert(0, newCv);
      _updateActiveCv();

      _uploadStatus = 'Complete!';
      notifyListeners();

      return newCv;
    } catch (e) {
      _errorMessage = 'Upload error: $e';
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Sets a specific CV as Active
  Future<void> setActiveCv(CvModel cv) async {
    try {
      await _storageService.setActiveCv(cvId: cv.id, userId: _currentUserId);

      _cvList = _cvList.map((item) {
        return item.copyWith(isActive: item.id == cv.id);
      }).toList();

      _updateActiveCv();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to set active CV: $e';
      notifyListeners();
    }
  }

  /// Deletes a CV from Firebase Storage and Firestore
  Future<bool> deleteCv(CvModel cv) async {
    try {
      await _storageService.deleteCv(cv);

      _cvList.removeWhere((item) => item.id == cv.id);

      // If active CV was deleted, make the first remaining CV active
      if (cv.isActive && _cvList.isNotEmpty) {
        _cvList[0] = _cvList[0].copyWith(isActive: true);
        await _storageService.setActiveCv(cvId: _cvList[0].id, userId: _currentUserId);
      }

      _updateActiveCv();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete CV: $e';
      notifyListeners();
      return false;
    }
  }

  void _updateActiveCv() {
    try {
      _activeCv = _cvList.firstWhere((cv) => cv.isActive);
    } catch (_) {
      _activeCv = _cvList.isNotEmpty ? _cvList.first : null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
