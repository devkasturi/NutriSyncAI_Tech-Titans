// lib/models/user_profile.dart
// Data model for user profile and health data

class UserProfile {
  String name;
  String email;
  int age;
  String gender;
  double height; // cm
  double weight; // kg
  List<String> goals;
  List<String> dietTypes;
  List<String> allergies;
  String customAllergy;
  int dailyWaterGoal; // in litres
  String activityLevel;
  List<String> cuisinePrefs;
  bool cookAtHome;
  int budgetMin;
  int budgetMax;
  Map<String, String> mealTimes; // e.g. {"breakfast": "08:00"}

  UserProfile({
    this.name = '',
    this.email = '',
    this.age = 25,
    this.gender = 'Male',
    this.height = 170,
    this.weight = 70,
    this.goals = const [],
    this.dietTypes = const [],
    this.allergies = const [],
    this.customAllergy = '',
    this.dailyWaterGoal = 2,
    this.activityLevel = 'Moderate',
    this.cuisinePrefs = const [],
    this.cookAtHome = true,
    this.budgetMin = 100,
    this.budgetMax = 500,
    this.mealTimes = const {},
  });
}

// lib/models/meal.dart - Meal data model
class Meal {
  final String id;
  final String name;
  final String dietType;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String cuisine;
  final int prepTime; // minutes
  final String mealSlot; // breakfast/lunch/dinner
  final String reasoning;
  final List<String> restaurants;
  final List<String> ingredients;
  final List<String> recipe;
  final String imageUrl;

  const Meal({
    required this.id,
    required this.name,
    required this.dietType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.cuisine,
    required this.prepTime,
    required this.mealSlot,
    required this.reasoning,
    this.restaurants = const [],
    this.ingredients = const [],
    this.recipe = const [],
    this.imageUrl = '',
  });
}

// lib/models/biometric.dart - Biometric data model
class BiometricData {
  double heartRate;
  double hrv;
  int steps;
  double sleepHours;
  double caloriesBurned;
  int systolicBP;
  int diastolicBP;
  String signalQuality;
  DateTime timestamp;

  BiometricData({
    this.heartRate = 0,
    this.hrv = 0,
    this.steps = 0,
    this.sleepHours = 0,
    this.caloriesBurned = 0,
    this.systolicBP = 120,
    this.diastolicBP = 80,
    this.signalQuality = 'Unknown',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

// lib/models/health_tip.dart - Health FAQ model
class HealthTip {
  final String symptom;
  final String description;
  final String icon;
  final List<String> remedies;
  final String hydrationTip;
  final String nutritionTip;

  const HealthTip({
    required this.symptom,
    required this.description,
    required this.icon,
    required this.remedies,
    required this.hydrationTip,
    required this.nutritionTip,
  });
}
