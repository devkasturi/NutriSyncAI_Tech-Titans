// lib/main.dart
// NutriSync AI - Main entry point
// Sets up routing, theme, and global state

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'services/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/profile/basic_profile_screen.dart';
import 'screens/profile/advanced_profile_screen.dart';
import 'screens/health/google_fit_screen.dart';
import 'screens/health/ppg_screen.dart';
import 'screens/meals/meal_suggestion_screen.dart';
import 'screens/meals/meal_feedback_screen.dart';
import 'screens/health/health_tips_screen.dart';
import 'screens/health/hydration_screen.dart';
import 'screens/health/emotional_ai_screen.dart';
import 'screens/chat/chatbot_screen.dart';
import 'screens/reports/weekly_report_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..loadMeals(),
      child: const NutriSyncApp(),
    ),
  );
}

class NutriSyncApp extends StatelessWidget {
  const NutriSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriSync AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/profile-basic': (_) => const BasicProfileScreen(),
        '/profile-advanced': (_) => const AdvancedProfileScreen(),
        '/google-fit': (_) => const GoogleFitScreen(),
        '/ppg': (_) => const PPGScreen(),
        '/home': (_) => const HomeScreen(),
        '/meals': (_) => const MealSuggestionScreen(),
        '/meal-feedback': (_) => const MealFeedbackScreen(),
        '/health-tips': (_) => const HealthTipsScreen(),
        '/hydration': (_) => const HydrationScreen(),
        '/emotional-ai': (_) => const EmotionalAIScreen(),
        '/chatbot': (_) => const ChatbotScreen(),
        '/weekly-report': (_) => const WeeklyReportScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
