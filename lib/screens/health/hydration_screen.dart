// lib/screens/health/hydration_screen.dart
// Dynamic hydration tracker with water ring and smart alerts

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';

class HydrationScreen extends StatelessWidget {
  final bool embedded;
  const HydrationScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Water ring
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: state.waterPercent,
                    strokeWidth: 16,
                    backgroundColor: Colors.blue.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      state.waterPercent >= 1 ? AppColors.primary : Colors.blue,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const Text('💧', style: TextStyle(fontSize: 36)),
                    Text(
                      '${state.waterIntake.toStringAsFixed(1)}L',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.blue),
                    ),
                    Text(
                      'of ${state.waterGoal.toStringAsFixed(0)}L goal',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    Text(
                      '${(state.waterPercent * 100).round()}%',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Status message
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: state.waterPercent >= 0.8
                  ? AppColors.primary.withOpacity(0.08)
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: state.waterPercent >= 0.8
                    ? AppColors.primary.withOpacity(0.3)
                    : Colors.orange.shade200,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.blue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state.hydrationMessage,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: state.waterPercent >= 0.8
                          ? AppColors.primary
                          : Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Add water buttons
          Row(
            children: [
              Expanded(
                child: _WaterButton(
                  label: '+250ml',
                  icon: Icons.local_drink_outlined,
                  onTap: () => context.read<AppState>().addWater(0.25),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WaterButton(
                  label: '+500ml',
                  icon: Icons.water_drop,
                  onTap: () => context.read<AppState>().addWater(0.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WaterButton(
                  label: '+1L',
                  icon: Icons.water,
                  onTap: () => context.read<AppState>().addWater(1.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weather-based suggestion
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade700],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny_outlined,
                    color: Colors.yellow, size: 28),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weather-Based Tip',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 11)),
                      Text(
                        'Hot & humid today (34°C). Add 500ml extra to prevent dehydration.',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Hourly log
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Today\'s Log',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 12),
          ..._buildLog(state.waterIntake),
        ],
      ),
    );

    if (embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Hydration Tracker')),
      body: body,
    );
  }

  List<Widget> _buildLog(double total) {
    final logs = [
      {'time': '8:00 AM', 'amount': '250ml', 'done': total >= 0.25},
      {'time': '10:00 AM', 'amount': '500ml', 'done': total >= 0.75},
      {'time': '1:00 PM', 'amount': '250ml', 'done': total >= 1.0},
      {'time': '4:00 PM', 'amount': '250ml', 'done': total >= 1.25},
      {'time': '7:00 PM', 'amount': '500ml', 'done': total >= 1.75},
      {'time': '10:00 PM', 'amount': '250ml', 'done': false},
    ];

    return logs.map((log) {
      final done = log['done'] as bool;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? AppColors.primary : Colors.grey.shade300,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(log['time'] as String,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const Spacer(),
            Text(log['amount'] as String,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: done ? AppColors.primary : AppColors.textSecondary)),
          ],
        ),
      );
    }).toList();
  }
}

class _WaterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _WaterButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
