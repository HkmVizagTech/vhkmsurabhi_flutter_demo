// lib/features/shared/donor/presentation/pages/donor_detail_page.dart
//
// Donor 360 - mirrors DCC's Donor 360 page: identity, one-tap call /
// WhatsApp, lifetime and financial-year giving, channel and festival
// breakdowns, and every receipt tagged with its festival and channel.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_festivals.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/contact_actions.dart';
import 'package:surabhi/core/widgets/amount_bars.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/donation_list_tile.dart';
import 'package:surabhi/features/preacher/stats/presentation/widgets/stat_tile.dart';
import 'package:surabhi/features/shared/donation/presentation/pages/record_donation_page.dart';

class DonorDetailPage extends StatefulWidget {
  final MockDonor donor;
  final Color color;

  const DonorDetailPage({super.key, required this.donor, required this.color});

  @override
  State<DonorDetailPage> createState() => _DonorDetailPageState();
}

class _DonorDetailPageState extends State<DonorDetailPage> {
  bool _showCancelled = false;

  MockDonor get donor => widget.donor;

  @override
  Widget build(BuildContext context) {
    final insights = DonorInsights.of(donor);
    final receipts = insights.receipts.where((r) => _showCancelled || r.status != DonationStatus.cancelled).toList();
    final cancelledCount = insights.receipts.length - insights.receipts.where((r) => r.status != DonationStatus.cancelled).length;

    return AppScaffold(
      title: 'Donor 360',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _hero(insights),
          const SizedBox(height: 12),
          _actions(insights),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              StatTile(label: 'Lifetime · ${insights.giftCount} receipts', value: inr(insights.lifetime), icon: Icons.volunteer_activism, color: AppColors.gold),
              StatTile(label: 'This FY · last FY ${inr(insights.lastFyAmount)}', value: inr(insights.thisFyAmount), icon: Icons.calendar_month, color: AppColors.vaikunthamBlue),
              StatTile(label: 'Average · largest ${inr(insights.largestGift)}', value: inr(insights.averageGift), icon: Icons.trending_up, color: AppColors.approverColor),
              StatTile(
                label: insights.daysSinceLastGift == null ? 'Last gift' : 'Last gift · ${insights.daysSinceLastGift} days ago',
                value: insights.lastGift == null ? 'Never' : ddmmyyyy(insights.lastGift!),
                icon: Icons.history,
                color: insights.status == CareStatus.lapsed ? AppColors.warningColor : AppColors.deepRed,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _card(
            'Giving by financial year',
            AmountBars(
              values: {for (final e in insights.byFinancialYear.entries) 'FY ${financialYearLabel(e.key)}': e.value},
              emptyText: 'No gifts yet',
            ),
          ),
          _card(
            'By channel',
            AmountBars(
              values: {for (final e in insights.byChannel.entries) DonationChannel.label(e.key): e.value},
              emptyText: 'No gifts yet',
            ),
          ),
          if (insights.byFestival.isNotEmpty)
            _card(
              'Festival participation',
              AmountBars(values: {for (final e in insights.byFestival.entries) festivalByCode(e.key)?.name ?? e.key: e.value}),
            ),
          _card('Profile', _profile()),
          SectionTitle(
            'All receipts',
            trailing: cancelledCount == 0
                ? null
                : FilterChip(
                    label: Text('Cancelled ($cancelledCount)'),
                    selected: _showCancelled,
                    onSelected: (v) => setState(() => _showCancelled = v),
                  ),
          ),
          if (receipts.isEmpty) const Text('No receipts yet.'),
          ...receipts.map((d) => DonationListTile(donation: d)),
        ],
      ),
    );
  }

  Widget _hero(DonorInsights insights) {
    final (statusLabel, statusColor) = switch (insights.status) {
      CareStatus.active => ('ACTIVE DONOR', AppColors.successColor),
      CareStatus.lapsed => ('LAPSED', AppColors.warningColor),
      CareStatus.never => ('NO GIFTS YET', AppColors.deepRed),
    };
    final bd = insights.daysToBirthday;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.creamGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.gold,
            child: Text(donor.name[0], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donor.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink)),
                const SizedBox(height: 2),
                Text('Donor ID ${donor.id} · enrolled by ${donor.enrolledByCode}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    StatusChip(label: statusLabel, color: statusColor),
                    if (donor.isPatron) const StatusChip(label: 'PATRON', color: AppColors.goldenDark, icon: Icons.workspace_premium),
                    if (bd != null && bd <= 30)
                      StatusChip(
                        label: bd == 0 ? 'Birthday today' : 'Birthday in $bd days',
                        color: AppColors.deepRed,
                        icon: Icons.cake,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(DonorInsights insights) {
    final bd = insights.daysToBirthday;
    final reason = bd != null && bd <= 7
        ? ContactReason.birthday
        : switch (insights.status) {
            CareStatus.lapsed => ContactReason.lapsed,
            CareStatus.never => ContactReason.neverDonated,
            CareStatus.active => ContactReason.thankYou,
          };
    // Three buttons across a phone: the theme's 20px side padding would wrap labels
    final compact = OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13));
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: compact,
            onPressed: () => callDonor(context, donor.mobile),
            icon: const Icon(Icons.call, size: 18),
            label: const Text('Call', maxLines: 1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            style: compact,
            onPressed: () => whatsappDonor(context, donor.mobile, donor.name, reason),
            icon: const Icon(Icons.chat, size: 18, color: Color(0xFF25D366)),
            label: const FittedBox(child: Text('WhatsApp', maxLines: 1)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RecordDonationPage(
                  title: 'Make Receipt',
                  color: widget.color,
                  initialDonor: donor,
                  enrolledByFilter: donor.enrolledByCode == kCurrentPreacherCode ? kCurrentPreacherCode : null,
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14)),
            icon: const Icon(Icons.receipt_long, size: 18),
            label: const FittedBox(child: Text('Receipt', maxLines: 1)),
          ),
        ),
      ],
    );
  }

  Widget _profile() {
    return Column(
      children: [
        _infoRow(Icons.phone, donor.mobile),
        if (donor.email != null) _infoRow(Icons.email, donor.email!),
        if (donor.address != null) _infoRow(Icons.home_outlined, donor.address!),
        _infoRow(Icons.location_city, donor.city),
        if (donor.dob != null) _infoRow(Icons.cake_outlined, 'Born ${ddmmyyyy(donor.dob!)}'),
        _infoRow(Icons.badge_outlined, donor.pan == null ? 'PAN not on file' : 'PAN: ${donor.pan}'),
        _infoRow(Icons.person, 'Enrolled by ${donor.enrolledByCode}'),
      ],
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

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
