// lib/screens/profile/settings_screen.dart
// App settings with all profile and privacy options

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile section
          _SectionHeader('Profile'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: state.userProfile.name,
            onTap: () => Navigator.pushNamed(context, '/profile-basic'),
          ),
          _SettingsTile(
            icon: Icons.fitness_center,
            title: 'Health Goals',
            subtitle: state.userProfile.goals.isNotEmpty
                ? state.userProfile.goals.join(', ')
                : 'Not set',
            onTap: () {},
          ),

          // Connected apps
          _SectionHeader('Connected Apps'),
          _SettingsTile(
            icon: Icons.health_and_safety,
            title: 'Google Fit',
            subtitle: state.googleFitConnected ? '✅ Connected' : 'Not connected',
            trailing: Switch(
              value: state.googleFitConnected,
              activeColor: AppColors.primary,
              onChanged: (_) {
                if (!state.googleFitConnected) {
                  state.connectGoogleFit();
                }
              },
            ),
          ),

          // Notifications
          _SectionHeader('Notifications'),
          _SettingsTile(
            icon: Icons.restaurant_menu_outlined,
            title: 'Meal Reminders',
            trailing: Switch(
              value: true,
              activeColor: AppColors.primary,
              onChanged: (_) {},
            ),
          ),
          _SettingsTile(
            icon: Icons.water_drop_outlined,
            title: 'Hydration Reminders',
            trailing: Switch(
              value: true,
              activeColor: AppColors.primary,
              onChanged: (_) {},
            ),
          ),

          // Privacy
          _SectionHeader('Privacy & Security'),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Settings',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.data_usage_outlined,
            title: 'Data & Storage',
            onTap: () {},
          ),

          // App info
          _SectionHeader('About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Medical Disclaimer',
            onTap: () => _showDisclaimer(context),
          ),
          _SettingsTile(
            icon: Icons.star_outline,
            title: 'Rate the App',
            onTap: () {},
          ),

          // Danger zone
          _SectionHeader('Account'),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            textColor: Colors.orange,
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
          _SettingsTile(
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            textColor: Colors.red,
            onTap: () => _confirmDelete(context),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Medical Disclaimer'),
        content: const Text(
          'NutriSync AI is not a substitute for professional medical advice. '
          'Always consult a qualified healthcare provider before making dietary or health changes. '
          'This app uses AI-generated recommendations based on self-reported and device-measured data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
            'This will permanently delete all your data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textSecondary, size: 22),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: textColor ?? AppColors.textPrimary)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary))
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 18)
              : null),
      onTap: onTap,
    );
  }
}
