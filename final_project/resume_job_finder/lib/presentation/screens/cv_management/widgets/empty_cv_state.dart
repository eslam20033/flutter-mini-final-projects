import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class EmptyCvState extends StatelessWidget {
  final VoidCallback onUploadPressed;

  const EmptyCvState({
    super.key,
    required this.onUploadPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.file_upload_outlined,
                color: AppColors.primary,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No CVs Uploaded Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload your resume in PDF format to start applying and matching with suitable jobs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onUploadPressed,
              icon: const Icon(Icons.add),
              label: const Text('Upload Resume (PDF)'),
            ),
          ],
        ),
      ),
    );
  }
}
