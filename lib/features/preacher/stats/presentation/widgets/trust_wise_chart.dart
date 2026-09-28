// lib/features/preacher/stats/presentation/widgets/trust_wise_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:surabhi/features/preacher/stats/data/preacher_stats_mock_data.dart';

/// Donations broken down by trust (DCC's AccountType: HKMV / HKMI / TSC).
class TrustWiseChart extends StatelessWidget {
  final List<TrustStats> data;
  final Color accentColor;

  const TrustWiseChart({super.key, required this.data, required this.accentColor});

  // Vaikuntham palette: gold, blue, deep red
  static const _trustColors = {'HKMV': Color(0xFFB8860B), 'HKMI': Color(0xFF1A398C), 'TSC': Color(0xFF7C0B0B)};

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (sum, t) => sum + t.amount);
    // Shrink the donut on narrow phones so the legend keeps room for its text
    final size = MediaQuery.sizeOf(context).width < 400 ? 116.0 : 140.0;

    return Row(
      children: [
        SizedBox(
          height: size,
          width: size,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: size * 0.23,
              sections: data.map((t) {
                final pct = total == 0 ? 0.0 : (t.amount / total) * 100;
                return PieChartSectionData(
                  value: t.amount.toDouble(),
                  color: _trustColors[t.trustName] ?? accentColor,
                  title: '${pct.toStringAsFixed(0)}%',
                  radius: size * 0.26,
                  titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((t) {
              // Name and count on separate lines so nothing is cut off on a phone
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _trustColors[t.trustName] ?? accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.trustName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text('${t.donationCount} donations', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                        ],
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
