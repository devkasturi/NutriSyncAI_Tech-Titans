// lib/services/mock_data.dart
// Mock data for hackathon demo - replace with real API calls in production

import '../models/models.dart';

class MockData {
  // ---- MEALS ----
  static List<Meal> getMeals(String slot) {
    final all = [
      Meal(
        id: 'b1',
        name: 'Oats & Banana Bowl',
        dietType: 'Veg',
        calories: 340,
        protein: 12,
        carbs: 58,
        fat: 6,
        cuisine: 'Continental',
        prepTime: 10,
        mealSlot: 'breakfast',
        reasoning: 'High fibre & low GI for stable morning energy',
        ingredients: ['Rolled oats', 'Banana', 'Almond milk', 'Chia seeds', 'Honey'],
        recipe: ['Cook oats with almond milk for 5 min', 'Top with sliced banana & chia seeds', 'Drizzle honey'],
      ),
      Meal(
        id: 'b2',
        name: 'Moong Dal Chilla',
        dietType: 'Veg',
        calories: 280,
        protein: 18,
        carbs: 32,
        fat: 5,
        cuisine: 'Indian',
        prepTime: 15,
        mealSlot: 'breakfast',
        reasoning: 'High protein for muscle recovery and sustained energy',
        restaurants: ['Green Kitchen – ₹80', 'Healthy Bites – ₹95'],
        ingredients: ['Moong dal', 'Green chilli', 'Ginger', 'Coriander', 'Oil'],
        recipe: ['Soak moong dal for 4 hrs', 'Grind to batter', 'Make thin pancakes on tawa'],
      ),
      Meal(
        id: 'l1',
        name: 'Grilled Chicken Bowl',
        dietType: 'Non-Veg',
        calories: 480,
        protein: 42,
        carbs: 35,
        fat: 14,
        cuisine: 'Continental',
        prepTime: 25,
        mealSlot: 'lunch',
        reasoning: 'High protein for muscle gain and recovery post-workout',
        restaurants: ['FitMeals Express – ₹220', 'The Protein Co. – ₹250'],
        ingredients: ['Chicken breast', 'Brown rice', 'Broccoli', 'Olive oil', 'Lemon'],
        recipe: ['Marinate chicken with herbs', 'Grill 8 min each side', 'Serve with steamed rice and broccoli'],
      ),
      Meal(
        id: 'l2',
        name: 'Rajma Chawal',
        dietType: 'Veg',
        calories: 420,
        protein: 16,
        carbs: 68,
        fat: 8,
        cuisine: 'Indian',
        prepTime: 30,
        mealSlot: 'lunch',
        reasoning: 'Iron-rich and filling – great for low energy days',
        restaurants: ['Desi Dhaba – ₹120', 'HomeStyle Kitchen – ₹100'],
        ingredients: ['Rajma', 'Rice', 'Tomato', 'Onion', 'Spices'],
        recipe: ['Pressure cook rajma', 'Make tadka with onion-tomato', 'Mix and serve with rice'],
      ),
      Meal(
        id: 'd1',
        name: 'Palak Paneer + Roti',
        dietType: 'Veg',
        calories: 390,
        protein: 22,
        carbs: 42,
        fat: 16,
        cuisine: 'Indian',
        prepTime: 20,
        mealSlot: 'dinner',
        reasoning: 'Iron-rich spinach supports HRV recovery and restful sleep',
        restaurants: ['Shree Bhojnalaya – ₹110', 'Swadisht – ₹130'],
        ingredients: ['Palak', 'Paneer', 'Cream', 'Whole wheat flour', 'Spices'],
        recipe: ['Blanch and puree palak', 'Sauté paneer cubes', 'Combine with spiced gravy'],
      ),
      Meal(
        id: 'd2',
        name: 'Mediterranean Quinoa Salad',
        dietType: 'Vegan',
        calories: 310,
        protein: 14,
        carbs: 44,
        fat: 9,
        cuisine: 'Mediterranean',
        prepTime: 15,
        mealSlot: 'dinner',
        reasoning: 'Light, anti-inflammatory – ideal for high-stress evenings',
        restaurants: ['The Salad Story – ₹180', 'Cafe Green – ₹200'],
        ingredients: ['Quinoa', 'Cucumber', 'Tomato', 'Olives', 'Lemon dressing'],
        recipe: ['Cook quinoa and cool', 'Chop veggies', 'Toss with dressing'],
      ),
    ];
    return all.where((m) => m.mealSlot == slot).toList();
  }

  // ---- HEALTH TIPS ----
  static List<HealthTip> getHealthTips() {
    return const [
      HealthTip(
        symptom: 'Nausea / Vomiting Feeling',
        description: 'Uncomfortable sensation with urge to vomit, often after eating',
        icon: '🤢',
        remedies: [
          'Drink small sips of water or electrolyte drinks',
          'Eat light foods like bananas, toast, or rice',
          'Avoid oily or spicy meals',
          'Ginger tea may help reduce nausea',
          'Rest and avoid sudden movements',
        ],
        hydrationTip: 'Sip 50–100ml water every 15 minutes',
        nutritionTip: 'Follow BRAT diet: Banana, Rice, Applesauce, Toast',
      ),
      HealthTip(
        symptom: 'Acidity / Heartburn',
        description: 'Burning sensation in chest or throat after meals',
        icon: '🔥',
        remedies: [
          'Avoid spicy and fried foods',
          'Drink warm water slowly',
          'Eat smaller, more frequent meals',
          'Include yogurt or buttermilk',
          'Don\'t lie down immediately after eating',
        ],
        hydrationTip: 'Drink 200ml warm water 30 min before meals',
        nutritionTip: 'Yogurt and alkaline foods like cucumber can neutralize acid',
      ),
      HealthTip(
        symptom: 'Low Energy / Fatigue',
        description: 'Feeling tired, sluggish, or unable to concentrate',
        icon: '😴',
        remedies: [
          'Eat balanced meals with protein and complex carbs',
          'Stay well hydrated throughout the day',
          'Get 7–8 hours of quality sleep',
          'Include fruits or nuts for quick energy',
          'Take short 10-minute walks to boost circulation',
        ],
        hydrationTip: 'Dehydration is a top cause of fatigue – aim for 2.5L/day',
        nutritionTip: 'Iron-rich foods like spinach and dates help with energy',
      ),
      HealthTip(
        symptom: 'Dehydration',
        description: 'Dark urine, dry mouth, headache or dizziness',
        icon: '💧',
        remedies: [
          'Drink water slowly throughout the day',
          'Consume coconut water or electrolyte drinks',
          'Eat water-rich foods like cucumber or watermelon',
          'Avoid caffeine and alcohol',
          'Set reminders to drink water every hour',
        ],
        hydrationTip: 'Your urine should be pale yellow – that\'s the target',
        nutritionTip: 'Watermelon, cucumber, and oranges are 90%+ water',
      ),
      HealthTip(
        symptom: 'Headache',
        description: 'Pain or pressure in the head, often due to dehydration or stress',
        icon: '🤕',
        remedies: [
          'Drink a full glass of water immediately',
          'Rest in a quiet, dark room',
          'Avoid prolonged screen exposure',
          'Eat a light, nutritious meal if you\'ve skipped one',
          'Apply cold compress to forehead',
        ],
        hydrationTip: '75% of headaches are caused by mild dehydration',
        nutritionTip: 'Magnesium-rich foods like nuts and seeds can prevent migraines',
      ),
      HealthTip(
        symptom: 'Bloating',
        description: 'Feeling of fullness, gas, or tightness in the stomach',
        icon: '😣',
        remedies: [
          'Avoid carbonated drinks',
          'Eat slowly and chew food thoroughly',
          'Reduce intake of beans, lentils and cabbage temporarily',
          'Try peppermint or fennel tea',
          'Light walk after meals helps digestion',
        ],
        hydrationTip: 'Warm water aids digestion better than cold water',
        nutritionTip: 'Probiotic-rich foods like curd reduce bloating over time',
      ),
      HealthTip(
        symptom: 'Muscle Cramps',
        description: 'Sudden, involuntary muscle contractions or spasms',
        icon: '⚡',
        remedies: [
          'Stretch the affected muscle gently',
          'Hydrate with electrolyte drink',
          'Eat potassium-rich foods like banana',
          'Apply warm compress to the cramp',
          'Ensure adequate magnesium intake',
        ],
        hydrationTip: 'Electrolyte imbalance is a key cause – replenish sodium & potassium',
        nutritionTip: 'Bananas, avocados, and sweet potatoes are excellent for cramps',
      ),
    ];
  }

  // ---- WEEKLY REPORT ----
  static Map<String, dynamic> getWeeklyReport() {
    return {
      'hrv_improvement': 12.5,
      'protein_consistency': 78.0,
      'hydration': 85.0,
      'recovery_badge': 'Gold',
      'hrv_data': [38.0, 40.0, 42.0, 39.0, 44.0, 45.0, 47.0],
      'protein_data': [65.0, 72.0, 80.0, 70.0, 85.0, 78.0, 82.0],
      'hydration_data': [1.5, 2.0, 2.2, 1.8, 2.5, 2.3, 2.1],
      'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    };
  }
}
