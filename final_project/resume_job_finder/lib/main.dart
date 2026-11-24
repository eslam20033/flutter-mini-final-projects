// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home/home_dashboard_screen.dart';
import 'providers/cv_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safely initialize Firebase if configuration files are present
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint(
      'Firebase initialization notice: $e (Running in hybrid/resilient mode)',
    );
  }

  runApp(const ResumeJobFinderApp());
}

class ResumeJobFinderApp extends StatelessWidget {
  const ResumeJobFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CvProvider())],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeDashboardScreen(),
      ),
    );
  }
}
