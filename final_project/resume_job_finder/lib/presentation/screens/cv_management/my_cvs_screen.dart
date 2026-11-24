import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/cv_model.dart';
import '../../../providers/cv_provider.dart';
import 'widgets/cv_item_card.dart';
import 'widgets/empty_cv_state.dart';
import 'widgets/upload_progress_dialog.dart';

class MyCvsScreen extends StatefulWidget {
  const MyCvsScreen({super.key});

  @override
  State<MyCvsScreen> createState() => _MyCvsScreenState();
}

class _MyCvsScreenState extends State<MyCvsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleUpload() async {
    final provider = Provider.of<CvProvider>(context, listen: false);

    // Show Progress Dialog listener
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer<CvProvider>(
          builder: (context, cvProv, _) {
            // Dismiss dialog automatically when upload finishes or errors
            if (!cvProv.isUploading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              });
            }
            return UploadProgressDialog(
              progress: cvProv.uploadProgress,
              status: cvProv.uploadStatus,
            );
          },
        );
      },
    );

    final uploadedCv = await provider.pickAndUploadCv();

    if (!mounted) return;

    if (uploadedCv != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully uploaded "${uploadedCv.fileName}"!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      provider.clearError();
    }
  }

  void _confirmDelete(CvModel cv) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete CV'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${cv.fileName}"?\nThis will remove it from both Cloud Firestore and Storage.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final provider = Provider.of<CvProvider>(context, listen: false);
              final success = await provider.deleteCv(cv);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'CV deleted successfully.'
                        : (provider.errorMessage ?? 'Failed to delete CV.'),
                  ),
                  backgroundColor: success ? AppColors.success : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cvProvider = Provider.of<CvProvider>(context);
    final allCvs = cvProvider.cvList;

    // Filter by search query if any
    final filteredCvs = _searchQuery.isEmpty
        ? allCvs
        : allCvs.where((c) => c.fileName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My CVs Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => cvProvider.loadCvs(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleUpload,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text('Upload CV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () => cvProvider.loadCvs(),
        child: cvProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : allCvs.isEmpty
                ? EmptyCvState(onUploadPressed: _handleUpload)
                : Column(
                    children: [
                      // Search Bar & Stats
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search resumes by name...',
                            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),

                      // Counter header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              'Total: ${filteredCvs.length} CV${filteredCvs.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Tap CV card to preview',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // CV List
                      Expanded(
                        child: filteredCvs.isEmpty
                            ? const Center(
                                child: Text(
                                  'No resumes match your search.',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                                itemCount: filteredCvs.length,
                                itemBuilder: (context, index) {
                                  final cv = filteredCvs[index];
                                  return CvItemCard(
                                    cv: cv,
                                    onSetActive: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      await cvProvider.setActiveCv(cv);
                                      if (!mounted) return;
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text('"${cv.fileName}" is now your Active CV!'),
                                          backgroundColor: AppColors.success,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    onDelete: () => _confirmDelete(cv),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
