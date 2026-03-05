// lib/screens/health/google_fit_screen.dart
// Google Fit sync screen with data cards

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';

class GoogleFitScreen extends StatefulWidget {
  const GoogleFitScreen({super.key});

  @override
  State<GoogleFitScreen> createState() => _GoogleFitScreenState();
}

class _GoogleFitScreenState extends State<GoogleFitScreen> {
  bool _syncing = false;

  Future<void> _connect() async {
    setState(() => _syncing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.read<AppState>().connectGoogleFit();
    setState(() => _syncing = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Health Data Sync')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.fitness_center, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text('Connect Google Fit',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text(
                    'Sync your health data for AI-powered\npersonalized meal recommendations',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  if (!state.googleFitConnected)
                    ElevatedButton(
                      onPressed: _syncing ? null : _connect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      child: _syncing
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.primary))
                          : const Text('Sync Now',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Connected',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Data points
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Data being synced',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.4,
                children: [
                  _DataTile(
                    icon: Icons.directions_walk,
                    label: 'Steps',
                    value: state.googleFitConnected
                        ? '${state.biometrics.steps.toStringAsFixed(0)}'
                        : '--',
                    unit: 'today',
                    color: Colors.blue,
                  ),
                  _DataTile(
                    icon: Icons.bedtime_outlined,
                    label: 'Sleep',
                    value: state.googleFitConnected
                        ? state.biometrics.sleepHours.toStringAsFixed(1)
                        : '--',
                    unit: 'hours',
                    color: Colors.indigo,
                  ),
                  _DataTile(
                    icon: Icons.favorite_outline,
                    label: 'HRV',
                    value: state.googleFitConnected
                        ? '${state.biometrics.hrv.round()}'
                        : '--',
                    unit: 'ms',
                    color: Colors.red,
                  ),
                  _DataTile(
                    icon: Icons.local_fire_department_outlined,
                    label: 'Calories',
                    value: state.googleFitConnected
                        ? '${state.biometrics.caloriesBurned.round()}'
                        : '--',
                    unit: 'kcal',
                    color: Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/ppg'),
                child: const Text('Next: Heart Rate Scan →'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              child: const Text('Skip for now',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataTile extends StatelessWidget {
  final IconData icon;
  final String label, value, unit;
  final Color color;

  const _DataTile({
    required this.icon, required this.label,
    required this.value, required this.unit, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text('$label ($unit)',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
