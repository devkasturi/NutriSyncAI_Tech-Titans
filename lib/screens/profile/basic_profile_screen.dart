// lib/screens/profile/basic_profile_screen.dart
// Step 1 profile setup: Identity, Goals, Diet, Allergies, Water, Activity, Location

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';

class BasicProfileScreen extends StatefulWidget {
  const BasicProfileScreen({super.key});

  @override
  State<BasicProfileScreen> createState() => _BasicProfileScreenState();
}

class _BasicProfileScreenState extends State<BasicProfileScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  // Identity
  final _nameCtrl = TextEditingController();
  int _age = 25;
  String _gender = 'Male';
  double _height = 170;
  double _weight = 70;

  // Goals (multi-select)
  final List<String> _allGoals = [
    'Weight loss',
    'Muscle gain',
    'Maintenance',
    'PCOS control',
    'Diabetes control',
    'BP control'
  ];
  final Set<String> _selectedGoals = {};

  // Diet type
  final List<String> _allDiets = [
    'Veg',
    'Non-Veg',
    'Jain',
    'Vegan',
    'Eggetarian'
  ];
  final Set<String> _selectedDiets = {};

  // Allergies
  final List<String> _allAllergies = [
    'None',
    'Dairy',
    'Nut',
    'Gluten',
    'Shellfish',
    'Others'
  ];
  final Set<String> _selectedAllergies = {};
  final _customAllergyCtrl = TextEditingController();

  // Water goal
  int _waterGoal = 2;

  // Activity
  String _activity = 'Moderate(31-60)';

  void _next() {
    if (_page < 5) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _page++);
    } else {
      _finish();
    }
  }

  void _finish() {
    final state = context.read<AppState>();
    state.userProfile
      ..name = _nameCtrl.text
      ..age = _age
      ..gender = _gender
      ..height = _height
      ..weight = _weight
      ..goals = _selectedGoals.toList()
      ..dietTypes = _selectedDiets.toList()
      ..allergies = _selectedAllergies.toList()
      ..customAllergy = _customAllergyCtrl.text
      ..dailyWaterGoal = _waterGoal
      ..activityLevel = _activity;
    state.completeProfileSetup();
    Navigator.pushReplacementNamed(context, '/profile-advanced');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _IdentityPage(
        nameCtrl: _nameCtrl,
        age: _age,
        gender: _gender,
        height: _height,
        weight: _weight,
        onChanged: (n, a, g, h, w) => setState(() {
          _nameCtrl.text = n;
          _age = a;
          _gender = g;
          _height = h;
          _weight = w;
        }),
      ),
      _ChipSelectionPage(
        title: 'Your Goals',
        subtitle: 'Select all that apply',
        icon: Icons.flag_outlined,
        options: _allGoals,
        selected: _selectedGoals,
        onToggle: (v) => setState(() => _selectedGoals.contains(v)
            ? _selectedGoals.remove(v)
            : _selectedGoals.add(v)),
      ),
      _ChipSelectionPage(
        title: 'Diet Type',
        subtitle: 'Select your dietary preference',
        icon: Icons.restaurant_outlined,
        options: _allDiets,
        selected: _selectedDiets,
        onToggle: (v) => setState(() => _selectedDiets.contains(v)
            ? _selectedDiets.remove(v)
            : _selectedDiets.add(v)),
      ),
      _AllergyPage(
        options: _allAllergies,
        selected: _selectedAllergies,
        customCtrl: _customAllergyCtrl,
        onToggle: (v) => setState(() {
          if (v == 'None') {
            _selectedAllergies.clear();
            _selectedAllergies.add('None');
          } else {
            _selectedAllergies.remove('None');
            if (_selectedAllergies.contains(v)) {
              _selectedAllergies.remove(v);
            } else {
              _selectedAllergies.add(v);
            }
          }
        }),
      ),
      _WaterGoalPage(
        selected: _waterGoal,
        onSelect: (v) => setState(() => _waterGoal = v),
      ),
      _ActivityPage(
        selected: _activity,
        onSelect: (v) => setState(() => _activity = v),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Profile Setup',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColors.textPrimary)),
                      Text('${_page + 1}/6',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_page + 1) / 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Profile completion: ${((_page + 1) / 6 * 40).round()}%',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_page > 0)
                    OutlinedButton(
                      onPressed: () {
                        _pageCtrl.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                        setState(() => _page--);
                      },
                      child: const Text('Back'),
                    ),
                  if (_page > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(_page == 5 ? 'Continue →' : 'Next →'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Sub-pages ---

class _IdentityPage extends StatelessWidget {
  final TextEditingController nameCtrl;
  final int age;
  final String gender;
  final double height, weight;
  final Function(String, int, String, double, double) onChanged;

  const _IdentityPage({
    required this.nameCtrl,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tell us about yourself',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('This helps us personalize your nutrition',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 28),

          const Text('Full Name',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (v) => onChanged(v, age, gender, height, weight),
          ),
          const SizedBox(height: 20),

          _SliderTile(
            label: 'Age',
            value: age.toDouble(),
            min: 10,
            max: 90,
            display: '$age years',
            onChanged: (v) =>
                onChanged(nameCtrl.text, v.round(), gender, height, weight),
          ),
          const SizedBox(height: 20),

          const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: ['Male', 'Female', 'Other']
                .map((g) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(g),
                        selected: gender == g,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                            color: gender == g
                                ? Colors.white
                                : AppColors.textPrimary),
                        onSelected: (_) =>
                            onChanged(nameCtrl.text, age, g, height, weight),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),

          _SliderTile(
            label: 'Height',
            value: height,
            min: 100,
            max: 220,
            display: '${height.round()} cm',
            onChanged: (v) => onChanged(nameCtrl.text, age, gender, v, weight),
          ),
          const SizedBox(height: 20),

          _SliderTile(
            label: 'Weight',
            value: weight,
            min: 30,
            max: 200,
            display: '${weight.round()} kg',
            onChanged: (v) => onChanged(nameCtrl.text, age, gender, height, v),
          ),
          const SizedBox(height: 12),

          // BMI card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.monitor_weight_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  'BMI: ${(weight / ((height / 100) * (height / 100))).toStringAsFixed(1)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  _bmiLabel(weight, height),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _bmiLabel(double w, double h) {
    final bmi = w / ((h / 100) * (h / 100));
    if (bmi < 18.5) return '(Underweight)';
    if (bmi < 25) return '(Normal)';
    if (bmi < 30) return '(Overweight)';
    return '(Obese)';
  }
}

class _SliderTile extends StatelessWidget {
  final String label;
  final double value, min, max;
  final String display;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(display,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.primary,
          inactiveColor: Colors.grey.shade200,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ChipSelectionPage extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _ChipSelectionPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((opt) {
              final isSelected = selected.contains(opt);
              return FilterChip(
                label: Text(opt),
                selected: isSelected,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500),
                onSelected: (_) => onToggle(opt),
                backgroundColor: Colors.grey.shade100,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AllergyPage extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final TextEditingController customCtrl;
  final ValueChanged<String> onToggle;

  const _AllergyPage({
    required this.options,
    required this.selected,
    required this.customCtrl,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_outlined,
              size: 32, color: AppColors.primary),
          const SizedBox(height: 10),
          const Text('Allergies & Intolerances',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('We\'ll exclude these from your meal plans',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((opt) {
              final isSelected = selected.contains(opt);
              return FilterChip(
                label: Text(opt),
                selected: isSelected,
                selectedColor: AppColors.error,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary),
                onSelected: (_) => onToggle(opt),
                backgroundColor: Colors.grey.shade100,
              );
            }).toList(),
          ),
          if (selected.contains('Others')) ...[
            const SizedBox(height: 16),
            TextField(
              controller: customCtrl,
              decoration: const InputDecoration(
                hintText: 'Enter your allergy...',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WaterGoalPage extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _WaterGoalPage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = [1, 2, 3, 4];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.water_drop_outlined,
              size: 32, color: AppColors.primary),
          const SizedBox(height: 10),
          const Text('Daily Water Goal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Set your hydration target',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 28),
          ...options
              .map((l) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => onSelect(l),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: selected == l
                              ? AppColors.primary.withOpacity(0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected == l
                                ? AppColors.primary
                                : Colors.grey.shade200,
                            width: selected == l ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.water_drop,
                                color: selected == l
                                    ? AppColors.primary
                                    : AppColors.textSecondary),
                            const SizedBox(width: 12),
                            Text(
                              l == 4 ? '4L+' : '${l}L per day',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected == l
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            if (selected == l)
                              const Icon(Icons.check_circle,
                                  color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

class _ActivityPage extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _ActivityPage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final levels = [
      {'label': 'Sedentary', 'range': '0–15 min/day', 'icon': '🪑'},
      {'label': 'Light', 'range': '16–30 min/day', 'icon': '🚶'},
      {'label': 'Moderate', 'range': '31–60 min/day', 'icon': '🏃'},
      {'label': 'Active', 'range': '>60 min/day', 'icon': '💪'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.directions_run, size: 32, color: AppColors.primary),
          const SizedBox(height: 10),
          const Text('Activity Level',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('How active are you daily?',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 28),
          ...levels.map((l) {
            final key =
                '${l['label']}(${l['range']!.replaceAll(' min/day', '')})';
            final isSel = selected.startsWith(l['label']!);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onSelect(key),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSel ? AppColors.primary : Colors.grey.shade200,
                      width: isSel ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(l['icon']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l['label']!,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSel
                                      ? AppColors.primary
                                      : AppColors.textPrimary)),
                          Text(l['range']!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      const Spacer(),
                      if (isSel)
                        const Icon(Icons.check_circle,
                            color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
