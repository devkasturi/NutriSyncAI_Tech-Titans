// lib/screens/health/emotional_ai_screen.dart
// Emotional AI screen showing mood score, HRV analysis, and comfort meal suggestions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';

class EmotionalAIScreen extends StatefulWidget {
  const EmotionalAIScreen({super.key});

  @override
  State<EmotionalAIScreen> createState() => _EmotionalAIScreenState();
}

class _EmotionalAIScreenState extends State<EmotionalAIScreen> {
  final _feelingCtrl = TextEditingController();
  String _selectedMood = '';
  final List<String> _moodOptions = [
    'Happy',
    'Sad',
    'Stressed',
    'Anxious',
    'Calm',
    'Energetic',
    'Tired',
    'Excited'
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final score = state.moodScore;

    Color moodColor;
    if (score >= 80) {
      moodColor = AppColors.primary;
    } else if (score >= 60) {
      moodColor = Colors.blue;
    } else if (score >= 40) {
      moodColor = Colors.orange;
    } else {
      moodColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Emotional AI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current feeling input
            const Text('How are you feeling right now?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: _feelingCtrl,
              decoration: const InputDecoration(
                hintText: 'Describe your current emotional state...',
                prefixIcon: Icon(Icons.sentiment_satisfied_outlined),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Mood selection
            const Text('Select your current mood',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moodOptions
                  .map((mood) => FilterChip(
                        label: Text(mood),
                        selected: _selectedMood == mood,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                        onSelected: (selected) => setState(
                            () => _selectedMood = selected ? mood : ''),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Submit button
            if (_feelingCtrl.text.isNotEmpty || _selectedMood.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Here you could send the data to an AI service
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Emotional data recorded!')),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ),

            const SizedBox(height: 30),

            // Mood score ring (existing code)
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(moodColor),
                        ),
                      ),
                      Column(
                        children: [
                          Text('${score.round()}',
                              style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  color: moodColor)),
                          const Text('/100',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Mood Score: ${state.moodLabel}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: moodColor)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Advice banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: moodColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: moodColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.psychology, color: moodColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(state.moodAdvice,
                        style: TextStyle(
                            color: moodColor, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contributing factors
            const Text('Contributing Factors',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            _FactorBar('HRV', state.biometrics.hrv, 100, Colors.red,
                icon: Icons.favorite),
            _FactorBar('Sleep', state.biometrics.sleepHours, 9, Colors.indigo,
                icon: Icons.bedtime),
            _FactorBar('Activity', state.biometrics.steps / 10000 * 60, 60,
                Colors.green,
                icon: Icons.directions_walk),
            const SizedBox(height: 24),

            // Comfort meal suggestion (if mood is low)
            if (score < 60) ...[
              const Text('Comfort Meal Suggestion',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade100, Colors.orange.shade50],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('🍫', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 10),
                        Text('Warm Dal Khichdi',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Comfort food rich in tryptophan and magnesium to boost serotonin. Perfect for low mood days.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text('340 kcal • 12g protein • Warm & soothing',
                        style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Supportive message
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: const Row(
                  children: [
                    Text('💜', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You\'re doing great. Your body is talking to you — rest, nourish, and breathe.',
                        style: TextStyle(
                            color: Colors.purple,
                            fontStyle: FontStyle.italic,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (score >= 60) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text('🌟', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Great vitals! Your HRV and sleep patterns suggest good recovery. Keep it up!',
                        style:
                            TextStyle(color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FactorBar extends StatelessWidget {
  final String label;
  final double value, max;
  final Color color;
  final IconData icon;

  const _FactorBar(this.label, this.value, this.max, this.color,
      {required this.icon});

  @override
  Widget build(BuildContext context) {
    final pct = (value / max).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13)),
              const Spacer(),
              Text('${value.toStringAsFixed(1)} / ${max.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 12, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
