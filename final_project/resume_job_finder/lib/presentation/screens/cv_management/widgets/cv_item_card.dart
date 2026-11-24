import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/file_size_formatter.dart';
import '../../../../data/models/cv_model.dart';
import '../../analysis_bridge/cv_handoff_service.dart';
import '../../pdf_viewer/in_app_pdf_viewer_screen.dart';

class CvItemCard extends StatelessWidget {
  final CvModel cv;
  final VoidCallback onSetActive;
  final VoidCallback onDelete;

  const CvItemCard({
    super.key,
    required this.cv,
    required this.onSetActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cv.isActive ? AppColors.primary : AppColors.border,
          width: cv.isActive ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InAppPdfViewerScreen(cv: cv),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon, Name, Active Badge & Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PDF Icon container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.pdfRedLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: AppColors.pdfRed,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // File Name & Upload Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cv.fileName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (cv.isActive) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, size: 12, color: AppColors.success),
                                    SizedBox(width: 4),
                                    Text(
                                      'Active CV',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${FileSizeFormatter.formatBytes(cv.fileSize)} • ${DateFormatter.formatRelative(cv.uploadedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // More actions popup menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {
                      if (value == 'preview') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => InAppPdfViewerScreen(cv: cv),
                          ),
                        );
                      } else if (value == 'set_active') {
                        onSetActive();
                      } else if (value == 'analyze') {
                        CvHandoffService.navigateToAnalysisModule(context, cv);
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'preview',
                        child: Row(
                          children: [
                            Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                            SizedBox(width: 10),
                            Text('Preview PDF'),
                          ],
                        ),
                      ),
                      if (!cv.isActive)
                        const PopupMenuItem(
                          value: 'set_active',
                          child: Row(
                            children: [
                              Icon(Icons.star_outline, size: 18, color: AppColors.accent),
                              SizedBox(width: 10),
                              Text('Set as Active CV'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'analyze',
                        child: Row(
                          children: [
                            Icon(Icons.analytics_outlined, size: 18, color: AppColors.secondary),
                            SizedBox(width: 10),
                            Text('Send to Analysis'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Bottom Actions Row
              Row(
                children: [
                  // Preview Button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => InAppPdfViewerScreen(cv: cv),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Preview'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Quick "Make Active" Button if not active
                  if (!cv.isActive)
                    TextButton.icon(
                      onPressed: onSetActive,
                      icon: const Icon(Icons.star_border, size: 16, color: AppColors.accent),
                      label: const Text(
                        'Set Active',
                        style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        CvHandoffService.navigateToAnalysisModule(context, cv);
                      },
                      icon: const Icon(Icons.auto_awesome, size: 14),
                      label: const Text('Analyze'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
