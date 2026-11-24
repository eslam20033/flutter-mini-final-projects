import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/cv_provider.dart';
import '../analysis_bridge/cv_handoff_service.dart';
import '../cv_management/my_cvs_screen.dart';
import '../cv_management/widgets/upload_progress_dialog.dart';
import 'widgets/active_cv_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/recent_activity_section.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CvProvider>(context, listen: false).loadCvs();
    });
  }

  void _handleQuickUpload() async {
    final provider = Provider.of<CvProvider>(context, listen: false);

    // Show upload progress modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer<CvProvider>(
          builder: (context, cvProv, _) {
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

  void _navigateToLibrary() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MyCvsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cvProvider = Provider.of<CvProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 20,
        centerTitle: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.primaryExtraLight,
              child: const Icon(Icons.person, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Job Seeker 👋',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Smart Resume & Career Dashboard',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_shared_outlined),
            tooltip: 'My CVs Library',
            onPressed: _navigateToLibrary,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => cvProvider.loadCvs(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Active CV Hero Card (Requirement 1)
              ActiveCvCard(
                activeCv: cvProvider.activeCv,
                onUploadQuick: _handleQuickUpload,
                onBrowseLibrary: _navigateToLibrary,
              ),

              const SizedBox(height: 24),

              // 2. Member #4 AI Analysis Bridge Card
              if (cvProvider.activeCv != null) ...[
                _buildAnalysisBridgeBanner(context, cvProvider),
                const SizedBox(height: 24),
              ],

              // 3. Quick Actions Row (Requirement 1 & 2)
              QuickActionsCard(
                onQuickUpload: _handleQuickUpload,
                onOpenLibrary: _navigateToLibrary,
                totalCvs: cvProvider.totalCvsCount,
              ),

              const SizedBox(height: 24),

              // 4. Recent Uploads Section (Requirement 5)
              RecentActivitySection(
                recentCvs: cvProvider.cvList,
                onViewAll: _navigateToLibrary,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisBridgeBanner(BuildContext context, CvProvider cvProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.psychology_outlined, color: AppColors.secondary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CV Ready for AI Matching',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Analyze "${cvProvider.activeCv!.fileName}" with AI for job matching',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              CvHandoffService.navigateToAnalysisModule(context, cvProvider.activeCv!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            child: const Text('Analyze'),
          ),
        ],
      ),
    );
  }
}
