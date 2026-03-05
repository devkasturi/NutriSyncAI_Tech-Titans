// lib/services/app_state.dart
// Global state management using Provider
// Stores user profile, biometric data, meals, hydration, and mood

import 'package:flutter/material.dart';
import '../models/models.dart';
import 'mock_data.dart';

class AppState extends ChangeNotifier {
  // ---- User ----
  UserProfile userProfile = UserProfile(
    name: 'Aryan Sharma',
    email: 'aryan@example.com',
    age: 26,
    gender: 'Male',
    height: 175,
    weight: 72,
    goals: ['Muscle gain', 'Weight loss'],
    dietTypes: ['Non-Veg'],
    allergies: ['Dairy'],
    dailyWaterGoal: 2,
    activityLevel: 'Moderate',
    cuisinePrefs: ['Indian', 'Continental'],
    cookAtHome: true,
    budgetMin: 100,
    budgetMax: 500,
    mealTimes: {'breakfast': '08:00', 'lunch': '13:00', 'dinner': '20:00'},
  );

  int profileCompletion = 40; // Increases after advanced setup

  // ---- Biometrics ----
  BiometricData biometrics = BiometricData(
    heartRate: 78,
    hrv: 42,
    steps: 6240,
    sleepHours: 7.2,
    caloriesBurned: 420,
    systolicBP: 118,
    diastolicBP: 76,
    signalQuality: 'Good',
  );

  bool googleFitConnected = false;

  // ---- Hydration ----
  double waterIntake = 1.25; // litres today
  
  double get waterGoal => userProfile.dailyWaterGoal.toDouble();
  double get waterPercent => (waterIntake / waterGoal).clamp(0.0, 1.0);
  
  String get hydrationMessage {
    if (waterPercent >= 1.0) return '🎉 You are perfectly hydrated today!';
    if (waterPercent >= 0.7) return '💧 Almost there! Keep drinking water.';
    if (waterPercent >= 0.4) return '⚠️ Moderate hydration. Drink more water.';
    return '🚨 Dehydration risk! Drink water now.';
  }

  void addWater(double litres) {
    waterIntake = (waterIntake + litres).clamp(0, 10);
    notifyListeners();
  }

  // ---- Meals ----
  List<Meal> breakfastOptions = [];
  List<Meal> lunchOptions = [];
  List<Meal> dinnerOptions = [];
  Meal? selectedBreakfast;
  Meal? selectedLunch;
  Meal? selectedDinner;
  Map<String, int?> mealFeedback = {}; // mealId -> rating 1-5
  Map<String, bool?> mealHad = {}; // mealId -> did user have it

  void loadMeals() {
    breakfastOptions = MockData.getMeals('breakfast');
    lunchOptions = MockData.getMeals('lunch');
    dinnerOptions = MockData.getMeals('dinner');
    notifyListeners();
  }

  void selectMeal(String slot, Meal meal) {
    if (slot == 'breakfast') selectedBreakfast = meal;
    if (slot == 'lunch') selectedLunch = meal;
    if (slot == 'dinner') selectedDinner = meal;
    notifyListeners();
  }

  void submitFeedback(String mealId, bool had, int? rating) {
    mealHad[mealId] = had;
    if (rating != null) mealFeedback[mealId] = rating;
    notifyListeners();
  }

  // ---- Emotional AI ----
  double get moodScore {
    double score = 100;
    if (biometrics.hrv < 30) score -= 25;
    if (biometrics.sleepHours < 6) score -= 20;
    if (biometrics.steps < 3000) score -= 15;
    return score.clamp(0, 100);
  }

  String get moodLabel {
    if (moodScore >= 80) return 'Great 😊';
    if (moodScore >= 60) return 'Good 🙂';
    if (moodScore >= 40) return 'Neutral 😐';
    return 'Low 😔';
  }

  String get moodAdvice {
    if (moodScore < 50) {
      return 'Your HRV and sleep suggest low energy today. Consider a comfort meal and light activity.';
    }
    return 'Your vitals look great! Keep up the good habits.';
  }

  // ---- Chatbot history ----
  List<Map<String, String>> chatHistory = [];

  void addChatMessage(String role, String content) {
    chatHistory.add({'role': role, 'content': content});
    notifyListeners();
  }

  // ---- Auth ----
  bool isLoggedIn = false;
  bool profileSetupDone = false;
  bool advancedSetupDone = false;

  void login(String name, String email) {
    userProfile.name = name;
    userProfile.email = email;
    isLoggedIn = true;
    notifyListeners();
  }

  void completeProfileSetup() {
    profileSetupDone = true;
    profileCompletion = 40;
    notifyListeners();
  }

  void completeAdvancedSetup() {
    advancedSetupDone = true;
    profileCompletion = 100;
    notifyListeners();
  }

  void connectGoogleFit() {
    googleFitConnected = true;
    biometrics = BiometricData(
      heartRate: 76,
      hrv: 44,
      steps: 7800,
      sleepHours: 7.5,
      caloriesBurned: 510,
      systolicBP: 116,
      diastolicBP: 74,
      signalQuality: 'Good',
    );
    notifyListeners();
  }

  void updateBiometrics(double hr, double hrv, String quality) {
    biometrics.heartRate = hr;
    biometrics.hrv = hrv;
    biometrics.signalQuality = quality;
    notifyListeners();
  }
}
