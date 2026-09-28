// lib/features/shared/festival/presentation/pages/festivals_page.dart
//
// Festival collections, grouped by the single FestivalCode shared by DCC,
// the website and the Vaikuntham app. A preacher sees only receipts from
// their own donors, like DCC's Festival Collections for a preacher login.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_festivals.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/amount_bars.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/donation_list_tile.dart';

class FestivalsPage extends StatelessWidget {
  // null = everyone's receipts (admin / employee)
  final String? preacherCode;

  const FestivalsPage({super.key, this.preacherCode});

  @override
  Widget build(BuildContext context) {
    final today = MockData.today;
    final summaries = mockFestivals.map((f) => FestivalSummary.of(f, preacherCode: preacherCode)).toList();
    final total = summaries.fold(0, (s, x) => s + x.total);

    return AppScaffold(
      title: 'Festivals',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: AppColors.creamGradient, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(Icons.celebration, color: AppColors.gold, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(preacherCode == null ? 'All festival collections' : 'Your festival collections',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                      Text(inr(total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      Text('One festival code is used by DCC, the website and the Vaikuntham app',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...summaries.map((s) => _FestivalCard(summary: s, today: today, preacherCode: preacherCode)),
        ],
      ),
    );
  }
}

class _FestivalCard extends StatelessWidget {
  final FestivalSummary summary;
  final DateTime today;
  final String? preacherCode;

  const _FestivalCard({required this.summary, required this.today, required this.preacherCode});

  @override
  Widget build(BuildContext context) {
    final f = summary.festival;
    final (label, color) = f.isCollectingOn(today)
        ? ('COLLECTING', AppColors.successColor)
        : f.isUpcomingOn(today)
            ? ('UPCOMING', AppColors.vaikunthamBlue)
            : ('CLOSED', Colors.blueGrey);
    final onlineShare = summary.total == 0 ? 0.0 : summary.onlineAmount / summary.total;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => FestivalDetailPage(festival: f, preacherCode: preacherCode)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(f.festivalCode,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.goldenDark, letterSpacing: .6)),
                  const Spacer(),
                  StatusChip(label: label, color: color),
                ],
              ),
              const SizedBox(height: 4),
              Text(f.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.ink)),
              Text('${ddmmyyyy(f.festivalDate)} · collecting ${ddmmyyyy(f.collectionStart)} – ${ddmmyyyy(f.collectionEnd)} · ${f.trust}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              const SizedBox(height: 10),
              Text(inr(summary.total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: summary.total == 0 ? 0 : onlineShare,
                  minHeight: 8,
                  backgroundColor: AppColors.ink.withValues(alpha: summary.total == 0 ? .08 : .85),
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${summary.receipts.length} receipts · ${summary.donorCount} donors · ${(onlineShare * 100).round()}% via website/app',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FestivalDetailPage extends StatelessWidget {
  final MockFestival festival;
  final String? preacherCode;

  const FestivalDetailPage({super.key, required this.festival, this.preacherCode});

  @override
  Widget build(BuildContext context) {
    final s = FestivalSummary.of(festival, preacherCode: preacherCode);
    return AppScaffold(
      title: festival.name,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              StatusChip(label: festival.festivalCode, color: AppColors.gold, icon: Icons.tag),
              StatusChip(label: 'DCC seva: Festival Donations › ${festival.dccSubCategory}', color: AppColors.vaikunthamBlue),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _kpi('Collected', inr(s.total)),
              _kpi('Receipts', '${s.receipts.length}'),
              _kpi('Donors', '${s.donorCount}'),
            ],
          ),
          const SizedBox(height: 14),
          _card('By seva', AmountBars(values: s.bySeva, emptyText: 'No receipts yet')),
          _card(
            'By channel',
            AmountBars(values: {for (final e in s.byChannel.entries) DonationChannel.label(e.key): e.value}, emptyText: 'No receipts yet'),
          ),
          _card(
            'Sevas you can offer',
            Column(
              children: festival.sevas
                  .map((sv) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.local_florist, color: AppColors.gold),
                        title: Text(sv.name),
                        subtitle: Text('Seva key ${sv.sevaKey}'),
                        trailing: sv.suggestedAmount == null ? null : Text(inr(sv.suggestedAmount!)),
                      ))
                  .toList(),
            ),
          ),
          const SectionTitle('Receipts'),
          if (s.receipts.isEmpty) const Text('No receipts yet for this festival.'),
          ...s.receipts.map((d) => DonationListTile(donation: d)),
        ],
      ),
    );
  }

  Widget _kpi(String label, String value) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              FittedBox(child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
