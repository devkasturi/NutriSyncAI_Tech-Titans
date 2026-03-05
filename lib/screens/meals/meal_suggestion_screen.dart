// lib/screens/meals/meal_suggestion_screen.dart
// AI-powered meal suggestions with restaurant ordering and recipe view

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';
import '../../models/models.dart';

class MealSuggestionScreen extends StatefulWidget {
  final bool embedded;
  const MealSuggestionScreen({super.key, this.embedded = false});

  @override
  State<MealSuggestionScreen> createState() => _MealSuggestionScreenState();
}

class _MealSuggestionScreenState extends State<MealSuggestionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    Widget body = Column(
      children: [
        // AI banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF0D1117), Color(0xFF0A2818)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Meal Plan Ready',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    Text(
                      'Based on HRV ${state.biometrics.hrv.round()}ms • ${state.biometrics.steps} steps • ${state.userProfile.goals.isNotEmpty ? state.userProfile.goals.first : "your goals"}',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab bar
        TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: '🌅 Breakfast'),
            Tab(text: '☀️ Lunch'),
            Tab(text: '🌙 Dinner'),
          ],
        ),

        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _MealSlotView(
                meals: state.breakfastOptions,
                selected: state.selectedBreakfast,
                slot: 'breakfast',
                mealTime: state.userProfile.mealTimes['breakfast'] ?? '08:00',
              ),
              _MealSlotView(
                meals: state.lunchOptions,
                selected: state.selectedLunch,
                slot: 'lunch',
                mealTime: state.userProfile.mealTimes['lunch'] ?? '13:00',
              ),
              _MealSlotView(
                meals: state.dinnerOptions,
                selected: state.selectedDinner,
                slot: 'dinner',
                mealTime: state.userProfile.mealTimes['dinner'] ?? '20:00',
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Meal Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.feedback_outlined),
            onPressed: () => Navigator.pushNamed(context, '/meal-feedback'),
          ),
        ],
      ),
      body: body,
    );
  }
}

class _MealSlotView extends StatelessWidget {
  final List<Meal> meals;
  final Meal? selected;
  final String slot;
  final String mealTime;

  const _MealSlotView({
    required this.meals,
    required this.selected,
    required this.slot,
    required this.mealTime,
  });

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return const Center(child: Text('No meal suggestions yet'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Time chip
        Row(
          children: [
            const Icon(Icons.access_time,
                size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('Suggested time: $mealTime',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('Notification set ✓',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        ...meals
            .map((meal) => _MealCard(
                  meal: meal,
                  isSelected: selected?.id == meal.id,
                  onSelect: () =>
                      context.read<AppState>().selectMeal(slot, meal),
                ))
            .toList(),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;
  final bool isSelected;
  final VoidCallback onSelect;

  const _MealCard({
    required this.meal,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(meal.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                    _Badge(meal.dietType, AppColors.primary),
                    const SizedBox(width: 6),
                    _Badge(meal.cuisine, Colors.purple),
                  ],
                ),
                const SizedBox(height: 6),

                // AI reasoning
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 12, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(meal.reasoning,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Macros row
                Row(
                  children: [
                    _MacroChip('🔥', '${meal.calories}', 'kcal'),
                    const SizedBox(width: 8),
                    _MacroChip('💪', '${meal.protein}g', 'protein'),
                    const SizedBox(width: 8),
                    _MacroChip('🌾', '${meal.carbs}g', 'carbs'),
                    const SizedBox(width: 8),
                    _MacroChip('🥑', '${meal.fat}g', 'fat'),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${meal.prepTime} min prep',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isSelected
                        ? null
                        : () => _showCookOrOrderChoice(context, meal),
                    icon: Icon(
                        isSelected ? Icons.check_circle : Icons.restaurant_menu,
                        size: 16),
                    label: Text(isSelected ? 'Selected' : 'Choose This'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: isSelected ? AppColors.primary : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCookOrOrderChoice(BuildContext context, Meal meal) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How would you like to enjoy ${meal.name}?',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ChoiceButton(
                    icon: Icons.menu_book_outlined,
                    label: 'Cook at Home',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      onSelect();
                      _showRecipeSheet(context, meal);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ChoiceButton(
                    icon: Icons.delivery_dining_outlined,
                    label: 'Order Online',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      onSelect();
                      _showOrderSheet(context, meal);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _showOrderSheet(BuildContext context, Meal meal) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _LocationPermissionSheet(meal: meal),
    );
  }
  }

  void _showRecipeSheet(BuildContext context, Meal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Text('🍳 How to Cook: ${meal.name}',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Ingredients',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ...meal.ingredients
                .map((i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(children: [
                        const Text('• ',
                            style: TextStyle(color: AppColors.primary)),
                        Text(i),
                      ]),
                    ))
                .toList(),
            const SizedBox(height: 16),
            const Text('Steps',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ...meal.recipe
                .asMap()
                .entries
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(
                              child: Text('${e.key + 1}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(e.value)),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String emoji, value, label;
  const _MacroChip(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$emoji $value',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _LocationPermissionSheet extends StatefulWidget {
  final Meal meal;

  const _LocationPermissionSheet({required this.meal});

  @override
  State<_LocationPermissionSheet> createState() => _LocationPermissionSheetState();
}

class _LocationPermissionSheetState extends State<_LocationPermissionSheet> {
  bool _locationGranted = false;

  @override
  Widget build(BuildContext context) {
    if (!_locationGranted) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_outlined, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Location Access Required',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            const Text(
                'To find nearby restaurants for ${widget.meal.name}, we need access to your location.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Simulate location permission request
                      setState(() => _locationGranted = true);
                    },
                    child: const Text('Allow Access'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Show restaurants after location is granted
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Nearby Restaurants for ${widget.meal.name}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Based on your current location',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          ...widget.meal.restaurants.map((r) => ListTile(
            leading: const Icon(Icons.restaurant, color: AppColors.primary),
            title: Text(r.split('–')[0].trim()),
            subtitle: Text(r.contains('–') ? r.split('–')[1].trim() : ''),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
              child: const Text('Order', style: TextStyle(fontSize: 12)),
            ),
          )).toList(),
        ],
      ),
    );
  }
}
