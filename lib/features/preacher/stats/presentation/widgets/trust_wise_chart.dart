// lib/features/preacher/stats/presentation/widgets/trust_wise_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:surabhi/features/preacher/stats/data/preacher_stats_mock_data.dart';

/// Donations broken down by trust (DCC's AccountType: HKMV / HKMI / TSC).
class TrustWiseChart extends StatelessWidget {
  final List<TrustStats> data;
  final Color accentColor;

  const TrustWiseChart({super.key, required this.data, required this.accentColor});

  static const _trustColors = {'HKMV': Color(0xFFFF9800), 'HKMI': Color(0xFF1976D2), 'TSC': Color(0xFF388E3C)};

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (sum, t) => sum + t.amount);

    return Row(
      children: [
        SizedBox(
          height: 140,
          width: 140,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 32,
              sections: data.map((t) {
                final pct = total == 0 ? 0.0 : (t.amount / total) * 100;
                return PieChartSectionData(
                  value: t.amount.toDouble(),
                  color: _trustColors[t.trustName] ?? accentColor,
                  title: '${pct.toStringAsFixed(0)}%',
                  radius: 36,
                  titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((t) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _trustColors[t.trustName] ?? accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${t.trustName} · ${t.donationCount} donations',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
