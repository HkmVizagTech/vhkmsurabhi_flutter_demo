// lib/features/preacher/donor_care/presentation/pages/donor_care_page.dart
//
// Donor care follow-ups for a preacher - the mobile side of DCC's
// sp_GetPreacherDonorCare: who has lapsed, whose birthday is coming up,
// and who enrolled but never gave, each with a one-tap call.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/contact_actions.dart';
import 'package:surabhi/core/widgets/amount_bars.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_detail_page.dart';

enum _CareTab { lapsed, birthdays, never, all }

class DonorCarePage extends StatefulWidget {
  final String preacherCode;

  const DonorCarePage({super.key, this.preacherCode = kCurrentPreacherCode});

  @override
  State<DonorCarePage> createState() => _DonorCarePageState();
}

class _DonorCarePageState extends State<DonorCarePage> {
  int _lapsedMonths = 12;

  @override
  Widget build(BuildContext context) {
    final all = DonorInsights.forPreacher(widget.preacherCode, lapsedMonths: _lapsedMonths);
    final lapsed = all.where((i) => i.status == CareStatus.lapsed).toList()
      ..sort((a, b) => (b.daysSinceLastGift ?? 0).compareTo(a.daysSinceLastGift ?? 0));
    final birthdays = all.where((i) => i.daysToBirthday != null && i.daysToBirthday! <= 30).toList()
      ..sort((a, b) => a.daysToBirthday!.compareTo(b.daysToBirthday!));
    final never = all.where((i) => i.status == CareStatus.never).toList();

    return DefaultTabController(
      length: 4,
      child: AppScaffold(
        title: 'Donor Care',
        body: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: AppColors.creamGradient),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Follow-ups for your donors', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                      ),
                      const Text('Lapsed after ', style: TextStyle(fontSize: 12)),
                      DropdownButton<int>(
                        value: _lapsedMonths,
                        underline: const SizedBox.shrink(),
                        items: const [6, 12, 24]
                            .map((m) => DropdownMenuItem(value: m, child: Text('$m months', style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (v) => setState(() => _lapsedMonths = v ?? _lapsedMonths),
                      ),
                    ],
                  ),
                  TabBar(
                    isScrollable: true,
                    labelColor: AppColors.ink,
                    indicatorColor: AppColors.gold,
                    unselectedLabelColor: Colors.grey.shade600,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(text: 'Lapsed (${lapsed.length})'),
                      Tab(text: 'Birthdays (${birthdays.length})'),
                      Tab(text: 'Never gave (${never.length})'),
                      Tab(text: 'All (${all.length})'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _list(lapsed, _CareTab.lapsed, 'No lapsed donors - wonderful!'),
                  _list(birthdays, _CareTab.birthdays, 'No birthdays in the next 30 days'),
                  _list(never, _CareTab.never, 'Every donor you enrolled has given'),
                  _list(all, _CareTab.all, 'No donors enrolled yet'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(List<DonorInsights> items, _CareTab tab, String empty) {
    if (items.isEmpty) {
      return Center(child: Text(empty, style: TextStyle(color: Colors.grey.shade600)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, i) => _tile(items[i], tab),
    );
  }

  Widget _tile(DonorInsights ins, _CareTab tab) {
    final donor = ins.donor;

    final String subtitle;
    switch (tab) {
      case _CareTab.birthdays:
        subtitle = ins.daysToBirthday == 0 ? 'Birthday today!' : 'Birthday in ${ins.daysToBirthday} days';
      case _CareTab.never:
        subtitle = 'Enrolled - no receipt yet';
      default:
        subtitle = ins.lastGift == null
            ? 'No receipt yet'
            : 'Last gift ${inr(ins.lastGiftAmount!)} on ${ddmmyyyy(ins.lastGift!)} · ${ins.daysSinceLastGift} days ago';
    }

    final (label, color) = switch (ins.status) {
      CareStatus.active => ('ACTIVE', AppColors.successColor),
      CareStatus.lapsed => ('LAPSED ${(ins.daysSinceLastGift! / 30).floor()}m', AppColors.warningColor),
      CareStatus.never => ('NEVER', AppColors.deepRed),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DonorDetailPage(donor: donor, color: AppColors.preacherColor)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.cream,
                child: Text(donor.name[0], style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wrap rather than truncate: full names are long on a phone
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(donor.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        StatusChip(label: label, color: color),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    Text('Lifetime ${inr(ins.lifetime)} · ${ins.giftCount} receipts',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Call',
                icon: const Icon(Icons.call, color: AppColors.gold),
                onPressed: () => callDonor(context, donor.mobile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
