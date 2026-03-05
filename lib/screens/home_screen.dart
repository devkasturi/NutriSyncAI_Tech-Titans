// lib/screens/home_screen.dart
// Main home screen with bottom navigation and slide-out drawer

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import 'meals/meal_suggestion_screen.dart';
import 'health/hydration_screen.dart';
import 'health/emotional_ai_screen.dart';
import 'reports/weekly_report_screen.dart';
import '_dashboard_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final List<Widget> _tabs = const [
    DashboardHome(),
    MealSuggestionScreen(embedded: true),
    HydrationScreen(embedded: true),
    WeeklyReportScreen(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      drawer: _AppDrawer(),
      appBar: _tab == 0
          ? AppBar(
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi, ${state.userProfile.name.split(' ').first} 👋',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const Text('Good Morning',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => Navigator.pushNamed(context, '/chatbot'),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ],
            )
          : null,
      body: _tabs[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined),
              activeIcon: Icon(Icons.restaurant),
              label: 'Meals'),
          BottomNavigationBarItem(
              icon: Icon(Icons.water_drop_outlined),
              activeIcon: Icon(Icons.water_drop),
              label: 'Hydration'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Reports'),
        ],
      ),
    );
  }
}

// Slide-out drawer (dark medical style)
class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Drawer(
      backgroundColor: AppColors.darkBg,
      child: SafeArea(
        child: Column(
          children: [
            // Profile section
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      state.userProfile.name.isNotEmpty
                          ? state.userProfile.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.userProfile.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                        Text(state.userProfile.email,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white12),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                      icon: Icons.dashboard_outlined,
                      label: 'Dashboard',
                      onTap: () => _go(context, '/home')),
                  _DrawerItem(
                      icon: Icons.bar_chart,
                      label: 'Weekly Report',
                      onTap: () => _go(context, '/weekly-report')),
                  _DrawerItem(
                      icon: Icons.warning_amber_outlined,
                      label: 'Risk Alerts',
                      onTap: () => _go(context, '/emotional-ai')),
                  _DrawerItem(
                      icon: Icons.restaurant_menu_outlined,
                      label: 'Meal Assistant',
                      onTap: () => _go(context, '/meals')),
                  _DrawerItem(
                      icon: Icons.health_and_safety_outlined,
                      label: 'Health Remedies',
                      onTap: () => _go(context, '/health-tips')),
                  _DrawerItem(
                      icon: Icons.chat_bubble_outline,
                      label: 'AI Chatbot',
                      onTap: () => _go(context, '/chatbot')),
                  _DrawerItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () {}),
                  Divider(color: Colors.white12),
                  _DrawerItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () => _go(context, '/settings')),
                  _DrawerItem(
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                      onTap: () {}),
                  _DrawerItem(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy',
                      onTap: () {}),
                  _DrawerItem(
                      icon: Icons.logout,
                      label: 'Logout',
                      color: Colors.red,
                      onTap: () => _go(context, '/login')),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('NutriSync AI v1.0.0',
                  style: TextStyle(color: Colors.white24, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    if (route == '/home') return;
    Navigator.pushNamed(context, route);
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: TextStyle(color: color, fontSize: 14)),
      onTap: onTap,
      dense: true,
    );
  }
}
