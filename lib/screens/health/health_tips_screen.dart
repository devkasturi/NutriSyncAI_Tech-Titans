// lib/screens/health/health_tips_screen.dart
// FAQ-style health remedies screen with expandable accordion cards

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/mock_data.dart';
import '../../models/models.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  int? _expanded;
  final List<HealthTip> _tips = MockData.getHealthTips();
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _tips
        .where((t) =>
            t.symptom.toLowerCase().contains(_search.toLowerCase()) ||
            t.description.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Health Remedies')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Search symptom...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),

          // Info banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'These are general guidelines. Consult a doctor for serious conditions.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final tip = filtered[i];
                final isOpen = _expanded == i;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _expanded = isOpen ? null : i),
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Text(tip.icon,
                                  style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tip.symptom,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15)),
                                    Text(tip.description,
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              Icon(
                                isOpen
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),

                        // Expanded content
                        if (isOpen)
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),

                                // Remedies
                                const Text('💊 Remedies',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary)),
                                const SizedBox(height: 8),
                                ...tip.remedies.map((r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle,
                                          size: 14,
                                          color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(r,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: AppColors.textPrimary)),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                                const SizedBox(height: 12),

                                // Hydration tip
                                _TipBox(
                                  icon: '💧',
                                  label: 'Hydration Tip',
                                  text: tip.hydrationTip,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 8),

                                // Nutrition tip
                                _TipBox(
                                  icon: '🥗',
                                  label: 'Nutrition Tip',
                                  text: tip.nutritionTip,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TipBox extends StatelessWidget {
  final String icon, label, text;
  final Color color;

  const _TipBox({
    required this.icon, required this.label,
    required this.text, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: color)),
                const SizedBox(height: 2),
                Text(text,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
