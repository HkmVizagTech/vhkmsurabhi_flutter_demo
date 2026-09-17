// lib/features/preacher/stats/presentation/widgets/monthly_trend_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:surabhi/features/preacher/stats/data/preacher_stats_mock_data.dart';

class MonthlyTrendChart extends StatelessWidget {
  final List<MonthlyPoint> data;
  final Color color;

  const MonthlyTrendChart({super.key, required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    final maxAmount = data.fold<int>(0, (m, p) => p.amount > m ? p.amount : m);

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxAmount * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(data[i].monthLabel, style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].amount.toDouble(),
                  color: color,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
