import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback onQuickUpload;
  final VoidCallback onOpenLibrary;
  final int totalCvs;

  const QuickActionsCard({
    super.key,
    required this.onQuickUpload,
    required this.onOpenLibrary,
    required this.totalCvs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Quick Upload CV action card
            Expanded(
              child: _buildActionCard(
                context: context,
                title: 'Upload CV',
                subtitle: 'PDF format (max 10MB)',
                icon: Icons.cloud_upload_outlined,
                iconBgColor: AppColors.primaryExtraLight,
                iconColor: AppColors.primary,
                onTap: onQuickUpload,
              ),
            ),
            const SizedBox(width: 12),
            // My CVs Library card
            Expanded(
              child: _buildActionCard(
                context: context,
                title: 'My Resumes',
                subtitle: '$totalCvs files uploaded',
                icon: Icons.folder_open_outlined,
                iconBgColor: AppColors.secondary.withValues(alpha: 0.12),
                iconColor: AppColors.secondary,
                onTap: onOpenLibrary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
