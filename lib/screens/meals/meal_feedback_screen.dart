// lib/screens/meals/meal_feedback_screen.dart
// Emoji-based meal feedback screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';

class MealFeedbackScreen extends StatefulWidget {
  const MealFeedbackScreen({super.key});

  @override
  State<MealFeedbackScreen> createState() => _MealFeedbackScreenState();
}

class _MealFeedbackScreenState extends State<MealFeedbackScreen> {
  bool? _hadMeal;
  int? _rating;

  final List<Map<String, dynamic>> _emojis = [
    {'emoji': '😍', 'label': 'Loved It', 'value': 5},
    {'emoji': '😊', 'label': 'Liked It', 'value': 4},
    {'emoji': '😐', 'label': 'Neutral', 'value': 3},
    {'emoji': '🙁', 'label': "Didn't Like", 'value': 2},
    {'emoji': '😞', 'label': 'Hated It', 'value': 1},
  ];

  void _submit() {
    final state = context.read<AppState>();
    final meal = state.selectedBreakfast ?? state.selectedLunch ?? state.selectedDinner;
    if (meal != null) {
      state.submitFeedback(meal.id, _hadMeal ?? false, _rating);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks for your feedback! 🎉'),
          backgroundColor: AppColors.primary),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Q1
            const Text('Did you have the previously suggested meal?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _AnswerCard(
                    label: '✅ Yes, I did',
                    selected: _hadMeal == true,
                    onTap: () => setState(() => _hadMeal = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AnswerCard(
                    label: '❌ No, I skipped',
                    selected: _hadMeal == false,
                    onTap: () => setState(() => _hadMeal = false),
                  ),
                ),
              ],
            ),

            // Q2 – only if yes
            if (_hadMeal == true) ...[
              const SizedBox(height: 32),
              const Text('How was your meal?',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _emojis.map((e) => GestureDetector(
                  onTap: () => setState(() => _rating = e['value']),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _rating == e['value'] ? 70 : 58,
                        height: _rating == e['value'] ? 70 : 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _rating == e['value']
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.grey.shade100,
                          border: Border.all(
                            color: _rating == e['value']
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(e['emoji'],
                              style: TextStyle(
                                  fontSize: _rating == e['value'] ? 34 : 28)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(e['label'],
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                )).toList(),
              ),
            ],

            const Spacer(),

            if (_hadMeal != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit Feedback'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AnswerCard({
    required this.label, required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textPrimary)),
        ),
      ),
    );
  }
}
