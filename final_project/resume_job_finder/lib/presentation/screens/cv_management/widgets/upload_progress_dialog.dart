import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class UploadProgressDialog extends StatelessWidget {
  final double progress;
  final String status;
  final String? fileName;

  const UploadProgressDialog({
    super.key,
    required this.progress,
    required this.status,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final int percentInt = (progress * 100).toInt().clamp(0, 100);

    return PopScope(
      canPop: false, // Prevent dismissing during active upload
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container with pulse effect
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Uploading CV',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              if (fileName != null) ...[
                const SizedBox(height: 6),
                Text(
                  fileName!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 24),

              // Linear Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  minHeight: 10,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),

              const SizedBox(height: 12),

              // Progress percentage & status message
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      status.isNotEmpty ? status : 'Uploading...',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$percentInt%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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
