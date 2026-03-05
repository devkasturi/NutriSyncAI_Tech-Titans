// lib/screens/_dashboard_home.dart
// Main dashboard showing biometric summary, quick actions, and AI insights

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bio = state.biometrics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's AI insight banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Insight',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 11)),
                      Text(state.moodAdvice,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Biometrics grid
            const Text('Today\'s Vitals',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _VitalCard('❤️', 'Heart Rate', '${bio.heartRate.round()} BPM', Colors.red),
                _VitalCard('🧠', 'HRV', '${bio.hrv.round()} ms', Colors.blue),
                _VitalCard('👣', 'Steps', '${bio.steps}', Colors.green),
                _VitalCard('😴', 'Sleep', '${bio.sleepHours}h', Colors.indigo),
              ],
            ),
            const SizedBox(height: 20),

            // Mood score
            const Text('Emotional AI',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/emotional-ai'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10)
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: state.moodScore / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              state.moodScore >= 70
                                  ? AppColors.primary
                                  : state.moodScore >= 40
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                            strokeWidth: 6,
                          ),
                        ),
                        Text('${state.moodScore.round()}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mood: ${state.moodLabel}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text('Tap for full emotional report',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick actions
            const Text('Quick Actions',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickAction(icon: Icons.restaurant_menu, label: 'Meal Plan',
                      onTap: () => Navigator.pushNamed(context, '/meals')),
                  _QuickAction(icon: Icons.monitor_heart_outlined, label: 'Heart Scan',
                      onTap: () => Navigator.pushNamed(context, '/ppg')),
                  _QuickAction(icon: Icons.water_drop, label: 'Hydration',
                      onTap: () => Navigator.pushNamed(context, '/hydration')),
                  _QuickAction(icon: Icons.health_and_safety_outlined, label: 'Remedies',
                      onTap: () => Navigator.pushNamed(context, '/health-tips')),
                  _QuickAction(icon: Icons.chat_bubble_outline, label: 'AI Chat',
                      onTap: () => Navigator.pushNamed(context, '/chatbot')),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile completion card
            if (state.profileCompletion < 100)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text('Complete Your Profile',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange)),
                        const Spacer(),
                        Text('${state.profileCompletion}%',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: state.profileCompletion / 100,
                        backgroundColor: Colors.orange.shade100,
                        valueColor:
                            const AlwaysStoppedAnimation(Colors.orange),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/profile-advanced'),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('Complete Advanced Setup →',
                          style: TextStyle(color: Colors.orange)),
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

class _VitalCard extends StatelessWidget {
  final String emoji, label, value;
  final Color color;

  const _VitalCard(this.emoji, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
