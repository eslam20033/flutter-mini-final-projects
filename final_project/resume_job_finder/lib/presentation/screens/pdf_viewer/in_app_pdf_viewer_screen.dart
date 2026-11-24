import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/file_size_formatter.dart';
import '../../../data/models/cv_model.dart';
import '../../../providers/cv_provider.dart';
import '../analysis_bridge/cv_handoff_service.dart';

class InAppPdfViewerScreen extends StatefulWidget {
  final CvModel cv;

  const InAppPdfViewerScreen({
    super.key,
    required this.cv,
  });

  @override
  State<InAppPdfViewerScreen> createState() => _InAppPdfViewerScreenState();
}

class _InAppPdfViewerScreenState extends State<InAppPdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  int _pageCount = 0;
  int _currentPage = 1;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  bool get _hasLocalFile {
    if (kIsWeb) return false;
    if (widget.cv.localPath.isNotEmpty) {
      return File(widget.cv.localPath).existsSync();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cvProvider = Provider.of<CvProvider>(context);
    final isCurrentActive = cvProvider.activeCv?.id == widget.cv.id;

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.cv.fileName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_pageCount > 0)
              Text(
                'Page $_currentPage of $_pageCount',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
          ],
        ),
        actions: [
          // Set as active button if not active
          if (!isCurrentActive)
            IconButton(
              icon: const Icon(Icons.star_border, color: AppColors.primary),
              tooltip: 'Set as Active CV',
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await cvProvider.setActiveCv(widget.cv);
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('CV marked as Active!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          // Send to analysis module button
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: AppColors.primary),
            tooltip: 'Analyze with AI',
            onPressed: () {
              CvHandoffService.navigateToAnalysisModule(context, widget.cv);
            },
          ),
          // Info sheet
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'File Details',
            onPressed: () => _showDetailsSheet(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // PDF Viewer (Loads memory bytes on Web/Mobile, local file on Desktop/Android, or network URL)
          if (widget.cv.fileBytes != null && widget.cv.fileBytes!.isNotEmpty)
            SfPdfViewer.memory(
              widget.cv.fileBytes!,
              controller: _pdfViewerController,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                setState(() {
                  _pageCount = details.document.pages.count;
                  _isLoading = false;
                });
              },
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = details.description;
                });
              },
              onPageChanged: (PdfPageChangedDetails details) {
                setState(() {
                  _currentPage = details.newPageNumber;
                });
              },
            )
          else if (_hasLocalFile)
            SfPdfViewer.file(
              File(widget.cv.localPath),
              controller: _pdfViewerController,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                setState(() {
                  _pageCount = details.document.pages.count;
                  _isLoading = false;
                });
              },
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = details.description;
                });
              },
              onPageChanged: (PdfPageChangedDetails details) {
                setState(() {
                  _currentPage = details.newPageNumber;
                });
              },
            )
          else if (widget.cv.downloadUrl.isNotEmpty &&
              widget.cv.downloadUrl.startsWith('http'))
            SfPdfViewer.network(
              widget.cv.downloadUrl,
              controller: _pdfViewerController,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                setState(() {
                  _pageCount = details.document.pages.count;
                  _isLoading = false;
                });
              },
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = details.description;
                });
              },
              onPageChanged: (PdfPageChangedDetails details) {
                setState(() {
                  _currentPage = details.newPageNumber;
                });
              },
            )
          else
            _buildFallbackPreview(),

          // Loading Overlay
          if (_isLoading && _errorMessage == null)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Loading PDF Document...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Error Overlay
          if (_errorMessage != null)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 54, color: AppColors.error),
                    const SizedBox(height: 16),
                    const Text(
                      'Could not render PDF',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: Colors.white,
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_out),
                tooltip: 'Zoom Out',
                onPressed: () {
                  _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel - 0.25).clamp(1.0, 3.0);
                },
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in),
                tooltip: 'Zoom In',
                onPressed: () {
                  _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel + 0.25).clamp(1.0, 3.0);
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  CvHandoffService.navigateToAnalysisModule(context, widget.cv);
                },
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Proceed to Analysis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackPreview() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pdfRedLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.picture_as_pdf, color: AppColors.pdfRed, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              widget.cv.fileName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Size: ${FileSizeFormatter.formatBytes(widget.cv.fileSize)} • Uploaded: ${DateFormatter.formatShort(widget.cv.uploadedAt)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'PDF preview is ready. You can analyze this file with AI or match with jobs directly.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CV Document Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailItem('File Name', widget.cv.fileName),
              _buildDetailItem('File Size', FileSizeFormatter.formatBytes(widget.cv.fileSize)),
              _buildDetailItem('Uploaded At', DateFormatter.formatFull(widget.cv.uploadedAt)),
              _buildDetailItem('Status', widget.cv.isActive ? 'Active CV' : 'Inactive'),
              _buildDetailItem('Storage Reference', widget.cv.storagePath),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
