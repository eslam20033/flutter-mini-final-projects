import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/cv_model.dart';
import '../../../providers/cv_provider.dart';
import 'member4_analysis_placeholder_screen.dart';

/// Contract & Bridge Service for transferring the Active CV to Member #4's Analysis Module
class CvHandoffService {
  /// Retrieve the current active CV anywhere in the app
  static CvModel? getActiveCv(BuildContext context) {
    return Provider.of<CvProvider>(context, listen: false).activeCv;
  }

  /// Check if an active CV is ready for analysis
  static bool hasActiveCv(BuildContext context) {
    return Provider.of<CvProvider>(context, listen: false).activeCv != null;
  }

  /// Navigate to Member #4's Analysis Module with the active CV
  static void navigateToAnalysisModule(BuildContext context, CvModel activeCv) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Member4AnalysisPlaceholderScreen(
          activeCv: activeCv,
        ),
      ),
    );
  }
}
