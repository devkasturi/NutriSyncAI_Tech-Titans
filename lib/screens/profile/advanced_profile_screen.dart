// lib/screens/profile/advanced_profile_screen.dart
// Advanced personalization: budget, cooking, cuisine, meal times

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';

class AdvancedProfileScreen extends StatefulWidget {
  const AdvancedProfileScreen({super.key});

  @override
  State<AdvancedProfileScreen> createState() => _AdvancedProfileScreenState();
}

class _AdvancedProfileScreenState extends State<AdvancedProfileScreen> {
  double _budgetMin = 100;
  double _budgetMax = 500;
  bool _cookAtHome = true;
  final Set<String> _cuisines = {};
  final Map<String, bool> _meals = {
    'Breakfast': false,
    'Lunch': false,
    'Dinner': false,
  };
  final Map<String, TextEditingController> _mealTimeCtrl = {
    'Breakfast': TextEditingController(text: '08:00'),
    'Lunch': TextEditingController(text: '13:00'),
    'Dinner': TextEditingController(text: '20:00'),
  };

  final List<String> _allCuisines = [
    'Continental',
    'Italian',
    'Indian',
    'Chinese',
    'Mediterranean'
  ];

  void _finish() {
    final state = context.read<AppState>();
    final mealTimes = <String, String>{};
    _meals.forEach((meal, selected) {
      if (selected) {
        mealTimes[meal.toLowerCase()] = _mealTimeCtrl[meal]!.text;
      }
    });

    state.userProfile
      ..budgetMin = _budgetMin.round()
      ..budgetMax = _budgetMax.round()
      ..cookAtHome = _cookAtHome
      ..cuisinePrefs = _cuisines.toList()
      ..mealTimes = mealTimes;

    state.completeAdvancedSetup();
    Navigator.pushReplacementNamed(context, '/google-fit');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Personalization'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/google-fit'),
            child:
                const Text('Skip', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text('Optional • Predictive AI unlocked at 100%',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Budget slider
            _sectionTitle('💰 Daily Food Budget'),
            const SizedBox(height: 4),
            Text('₹${_budgetMin.round()} – ₹${_budgetMax.round()}',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            RangeSlider(
              values: RangeValues(_budgetMin, _budgetMax),
              min: 100,
              max: 5000,
              divisions: 49,
              activeColor: AppColors.primary,
              inactiveColor: Colors.grey.shade200,
              labels: RangeLabels(
                  '₹${_budgetMin.round()}', '₹${_budgetMax.round()}'),
              onChanged: (v) => setState(() {
                _budgetMin = v.start;
                _budgetMax = v.end;
              }),
            ),
            const SizedBox(height: 24),

            // Cooking access
            _sectionTitle('🍳 Cooking Access'),
            const SizedBox(height: 10),
            Row(
              children: [
                _ToggleOption(
                  label: 'Cook at Home',
                  icon: Icons.home_outlined,
                  selected: _cookAtHome,
                  onTap: () => setState(() => _cookAtHome = true),
                ),
                const SizedBox(width: 12),
                _ToggleOption(
                  label: 'Order Online',
                  icon: Icons.delivery_dining_outlined,
                  selected: !_cookAtHome,
                  onTap: () => setState(() => _cookAtHome = false),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Cuisine preference
            _sectionTitle('🌍 Cuisine Preference'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _allCuisines.map((c) {
                final sel = _cuisines.contains(c);
                return FilterChip(
                  label: Text(c),
                  selected: sel,
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                      color: sel ? Colors.white : AppColors.textPrimary),
                  onSelected: (_) => setState(
                      () => sel ? _cuisines.remove(c) : _cuisines.add(c)),
                  backgroundColor: Colors.grey.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Meal consumption
            _sectionTitle('🍽️ Daily Meal Preference'),
            const SizedBox(height: 10),
            ..._meals.keys
                .map((meal) => Column(
                      children: [
                        CheckboxListTile(
                          title: Text(meal,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          value: _meals[meal],
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) =>
                              setState(() => _meals[meal] = v ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        if (_meals[meal] == true)
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 40, bottom: 12),
                            child: TextField(
                              controller: _mealTimeCtrl[meal],
                              decoration: InputDecoration(
                                labelText:
                                    '$meal time (e.g., 8:00 AM, 2 PM, 14:30)',
                                prefixIcon:
                                    const Icon(Icons.access_time_outlined),
                                isDense: true,
                              ),
                            ),
                          ),
                      ],
                    ))
                .toList(),
            const SizedBox(height: 32),

            // Complete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _finish,
                child: const Text('Complete Setup (100%) →'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary));
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color:
                selected ? AppColors.primary.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color:
                      selected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
