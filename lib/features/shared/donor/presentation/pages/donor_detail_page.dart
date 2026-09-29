// lib/features/shared/donor/presentation/pages/donor_detail_page.dart
//
// Donor 360 - mirrors DCC's Donor 360 page: identity, one-tap call,
// lifetime and financial-year giving, channel and festival
// breakdowns, and every receipt tagged with its festival and channel.
// DRM adds the donor's tier and tags, patronship, an Activity tab
// (interactions, follow-ups, receipts and approval requests on one
// timeline) and the approval-backed actions: request a detail change,
// request a receipt cancellation, enrol as patron.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_drm.dart';
import 'package:surabhi/core/mock/mock_festivals.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/contact_actions.dart';
import 'package:surabhi/core/widgets/amount_bars.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/donation_list_tile.dart';
import 'package:surabhi/features/preacher/stats/presentation/widgets/stat_tile.dart';
import 'package:surabhi/features/shared/approvals/presentation/pages/approval_request_detail_page.dart';
import 'package:surabhi/features/shared/approvals/presentation/widgets/approval_action_sheets.dart';
import 'package:surabhi/features/shared/donation/presentation/pages/record_donation_page.dart';
import 'package:surabhi/features/shared/drm/presentation/widgets/donor_activity_section.dart';
import 'package:surabhi/features/shared/drm/presentation/widgets/drm_chips.dart';
import 'package:surabhi/features/shared/drm/presentation/widgets/drm_sheets.dart';
import 'package:surabhi/features/shared/drm/presentation/widgets/patron_widgets.dart';

class DonorDetailPage extends StatefulWidget {
  final MockDonor donor;
  final Color color;

  const DonorDetailPage({super.key, required this.donor, required this.color});

  @override
  State<DonorDetailPage> createState() => _DonorDetailPageState();
}

class _DonorDetailPageState extends State<DonorDetailPage> {
  bool _showCancelled = false;
  int _tab = 0; // 0 = Overview, 1 = Activity

  // Always the latest copy: approved detail changes / patron enrolment
  // replace the donor in MockData while this page is open.
  MockDonor get donor => MockData.donorById(widget.donor.id) ?? widget.donor;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Donor 360',
      body: ListenableBuilder(
        listenable: Listenable.merge([ApprovalStore.instance, DrmStore.instance]),
        builder: (context, _) => _content(),
      ),
    );
  }

  Widget _content() {
    final insights = DonorInsights.of(donor);
    final openTasks = DrmStore.instance.tasksFor(donor.id).where((t) => t.isOpen).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _hero(insights),
        const SizedBox(height: 12),
        _actions(insights),
        const SizedBox(height: 10),
        _approvalActions(),
        const SizedBox(height: 14),
        SegmentedButton<int>(
          segments: [
            const ButtonSegment(value: 0, icon: Icon(Icons.insights, size: 18), label: Text('Overview')),
            ButtonSegment(
              value: 1,
              icon: const Icon(Icons.timeline, size: 18),
              label: Text(openTasks == 0 ? 'Activity' : 'Activity ($openTasks)'),
            ),
          ],
          selected: {_tab},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _tab = s.first),
        ),
        const SizedBox(height: 14),
        if (_tab == 0) ..._overview(insights) else DonorActivitySection(donor: donor, color: widget.color),
      ],
    );
  }

  List<Widget> _overview(DonorInsights insights) {
    final receipts = insights.receipts.where((r) => _showCancelled || r.status != DonationStatus.cancelled).toList();
    final cancelledCount = insights.receipts.length - insights.receipts.where((r) => r.status != DonationStatus.cancelled).length;
    final patron = DrmStore.instance.patronFor(donor.id);
    return [
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
      if (patron != null) _card('Patronship', PatronshipSummary(record: patron)),
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
      ...receipts.map((d) => DonationListTile(donation: d, trailingAction: _receiptAction(d))),
    ];
  }

  // Cancellation goes through approval; show where it stands once raised
  Widget? _receiptAction(MockDonation d) {
    if (d.status == DonationStatus.cancelled) return null;
    final pending = ApprovalStore.instance.pendingCancellationFor(d.receiptNumber);
    if (pending != null) {
      return InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ApprovalRequestDetailPage(requestId: pending.id, color: widget.color)),
        ),
        child: const StatusChip(label: 'Cancellation pending', color: AppColors.warningColor, icon: Icons.hourglass_top),
      );
    }
    return PopupMenuButton<String>(
      tooltip: 'Receipt actions',
      icon: const Icon(Icons.more_vert),
      onSelected: (_) => showCancelReceiptSheet(context, receipt: d, color: widget.color),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'cancel',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.block, color: AppColors.deepRed),
            title: Text('Request cancellation'),
          ),
        ),
      ],
    );
  }

  Widget _hero(DonorInsights insights) {
    final (statusLabel, statusColor) = switch (insights.status) {
      CareStatus.active => ('ACTIVE DONOR', AppColors.successColor),
      CareStatus.lapsed => ('LAPSED', AppColors.warningColor),
      CareStatus.never => ('NO GIFTS YET', AppColors.deepRed),
    };
    final bd = insights.daysToBirthday;
    final tags = DrmStore.instance.tagsFor(donor.id);
    final tier = tierOf(insights);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.creamGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    // Tier replaces the old PATRON chip (PATRON is the top
                    // tier). REGULAR/LAPSED/PROSPECT already say what the
                    // care status would, so it's only added for PATRON/MAJOR.
                    TierChip(tier: tier),
                    if (tier == DonorTier.patron || tier == DonorTier.major) StatusChip(label: statusLabel, color: statusColor),
                    if (bd != null && bd <= 30)
                      StatusChip(
                        label: bd == 0 ? 'Birthday today' : 'Birthday in $bd days',
                        color: AppColors.deepRed,
                        icon: Icons.cake,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...tags.map((t) => TagChip(tag: t)),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => showTagPickerSheet(context, donor: donor),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          tags.isEmpty ? '+ Tag' : '+ Tag / edit',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldenDark),
                        ),
                      ),
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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13)),
            onPressed: () => callDonor(context, donor.mobile),
            icon: const Icon(Icons.call, size: 18),
            label: const Text('Call', maxLines: 1),
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
            label: const Text('Receipt', maxLines: 1),
          ),
        ),
      ],
    );
  }

  // Actions that go through hierarchy approval (or apply at once when the
  // rule is off). Log interaction / Add follow-up live on the Activity tab.
  Widget _approvalActions() {
    final requests = ApprovalStore.instance.requestsForDonor(donor.id);
    final pendingPatron = requests.where((r) => r.isPending && r.actionType == ApprovalActionType.patronEnrol).firstOrNull;
    final pendingChange = requests.where((r) => r.isPending && r.actionType == ApprovalActionType.donorChange).firstOrNull;

    Widget pendingChip(ApprovalRequest r, String label) => ActionChip(
          avatar: const Icon(Icons.hourglass_top, size: 16, color: AppColors.warningColor),
          label: Text(label),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ApprovalRequestDetailPage(requestId: r.id, color: widget.color)),
          ),
        );

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (pendingChange != null)
          pendingChip(pendingChange, 'Change pending · ${pendingChange.id}')
        else
          ActionChip(
            avatar: const Icon(Icons.manage_accounts_outlined, size: 18, color: AppColors.vaikunthamBlue),
            label: const Text('Request change'),
            onPressed: () => showRequestChangeSheet(context, donor: donor, color: widget.color),
          ),
        if (!donor.isPatron)
          if (pendingPatron != null)
            pendingChip(pendingPatron, 'Patron enrolment pending')
          else
            ActionChip(
              avatar: const Icon(Icons.workspace_premium_outlined, size: 18, color: AppColors.goldenDark),
              label: const Text('Enrol as patron'),
              onPressed: () => showEnrolPatronSheet(context, donor: donor, color: widget.color),
            ),
      ],
    );
  }

  Widget _profile() {
    return Column(
      children: [
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
