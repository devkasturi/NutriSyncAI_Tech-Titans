// lib/screens/reports/weekly_report_screen.dart
// Weekly AI health report with charts

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../services/mock_data.dart';

class WeeklyReportScreen extends StatelessWidget {
  final bool embedded;
  const WeeklyReportScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final report = MockData.getWeeklyReport();
    final days = List<String>.from(report['days']);
    final hrvData = List<double>.from(report['hrv_data']);
    final proteinData = List<double>.from(report['protein_data']);
    final hydrationData = List<double>.from(report['hydration_data']);

    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recovery badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.yellow, size: 36),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recovery Badge',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('${report['recovery_badge']} Recovery',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20)),
                    const Text('Excellent week! Keep it up.',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _StatCard('📈', 'HRV Improvement',
                  '+${report['hrv_improvement']}%', Colors.green),
              const SizedBox(width: 10),
              _StatCard('💪', 'Protein',
                  '${report['protein_consistency']}%', Colors.blue),
              const SizedBox(width: 10),
              _StatCard('💧', 'Hydration',
                  '${report['hydration']}%', Colors.cyan),
            ],
          ),
          const SizedBox(height: 24),

          // HRV Chart
          _ChartCard(
            title: '❤️ HRV Trend (ms)',
            data: hrvData,
            days: days,
            color: Colors.red,
            minY: 30,
            maxY: 60,
          ),
          const SizedBox(height: 16),

          // Protein Chart
          _ChartCard(
            title: '💪 Protein Intake (g)',
            data: proteinData,
            days: days,
            color: Colors.blue,
            minY: 40,
            maxY: 100,
          ),
          const SizedBox(height: 16),

          // Hydration chart
          _ChartCard(
            title: '💧 Hydration (L)',
            data: hydrationData,
            days: days,
            color: Colors.cyan,
            minY: 0,
            maxY: 3,
          ),
        ],
      ),
    );

    if (embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly AI Report')),
      body: body,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, label, value;
  final Color color;

  const _StatCard(this.emoji, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final List<double> data;
  final List<String> days;
  final Color color;
  final double minY, maxY;

  const _ChartCard({
    required this.title, required this.data,
    required this.days, required this.color,
    required this.minY, required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= days.length) return const SizedBox();
                        return Text(days[i],
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary));
                      },
                      reservedSize: 24,
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                              radius: 4,
                              color: color,
                              strokeColor: Colors.white,
                              strokeWidth: 2),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
