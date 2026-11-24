import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/file_size_formatter.dart';
import '../../../data/models/cv_model.dart';
import '../pdf_viewer/in_app_pdf_viewer_screen.dart';

class Member4AnalysisPlaceholderScreen extends StatefulWidget {
  final CvModel activeCv;

  const Member4AnalysisPlaceholderScreen({
    super.key,
    required this.activeCv,
  });

  @override
  State<Member4AnalysisPlaceholderScreen> createState() =>
      _Member4AnalysisPlaceholderScreenState();
}

class _Member4AnalysisPlaceholderScreenState
    extends State<Member4AnalysisPlaceholderScreen> {
  bool _isAnalyzing = false;
  bool _analysisComplete = false;

  final List<String> _sampleSkills = [
    'Flutter & Dart',
    'SQLite & Local Storage',
    'Firebase Suite',
    'RESTful APIs',
    'State Management (Provider)',
    'Clean Architecture',
    'Git & Version Control',
    'UI/UX Material 3',
  ];

  void _runAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
      _analysisComplete = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI analysis and skills extraction complete!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Resume Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Preview CV',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => InAppPdfViewerScreen(
                    cv: widget.activeCv,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Analysis Pipeline Ready',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Resume "${widget.activeCv.fileName}" is prepared for automated skills extraction and job matching.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFCCFBF1),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Active CV Document Parameters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description_outlined, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Active Resume Details',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildParamRow('File Name', widget.activeCv.fileName),
                    _buildParamRow('File Size', FileSizeFormatter.formatBytes(widget.activeCv.fileSize)),
                    _buildParamRow('Upload Date', DateFormatter.formatFull(widget.activeCv.uploadedAt)),
                    _buildParamRow('Storage Architecture', 'Local SQLite + App Storage'),
                    if (widget.activeCv.downloadUrl.isNotEmpty &&
                        widget.activeCv.downloadUrl.startsWith('http'))
                      _buildParamRow('Cloud Backup URL', widget.activeCv.downloadUrl, isUrl: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // AI Skills Extracted Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology_outlined, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        const Text(
                          'Extracted Skills & Competencies',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (_analysisComplete)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '8 Skills Found',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sampleSkills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: _analysisComplete
                                ? AppColors.primaryExtraLight
                                : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _analysisComplete
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _analysisComplete
                                    ? Icons.check_circle_outline
                                    : Icons.tag,
                                size: 14,
                                color: _analysisComplete
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                skill,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _analysisComplete
                                      ? AppColors.primaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : _runAnalysis,
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.analytics_outlined),
                        label: Text(_isAnalyzing
                            ? 'Analyzing Resume with AI...'
                            : (_analysisComplete ? 'Re-scan Skills' : 'Run AI Skills Extraction')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParamRow(String label, String value, {bool isUrl = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isUrl ? AppColors.primary : AppColors.textPrimary,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: isUrl ? 2 : 1,
          ),
        ],
      ),
    );
  }
}
