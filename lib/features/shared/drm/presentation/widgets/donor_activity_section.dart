// lib/features/shared/drm/presentation/widgets/donor_activity_section.dart
//
// Donor 360 "Activity" tab: log an interaction / add a follow-up, the open
// follow-ups with a Done checkbox, and one merged timeline (interactions,
// follow-ups, receipts, approval requests), newest first.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_drm.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/amount_bars.dart';
import 'package:surabhi/features/shared/approvals/presentation/pages/approval_request_detail_page.dart';
import 'package:surabhi/features/shared/drm/presentation/widgets/drm_sheets.dart';
import 'package:surabhi/features/shared/drm/presentation/widgets/follow_up_tile.dart';

class _Entry {
  final DateTime date;
  final IconData icon;
  final Color color;
  final String title;
  final String? body;
  final String meta;
  final VoidCallback? onTap;

  const _Entry({required this.date, required this.icon, required this.color, required this.title, required this.meta, this.body, this.onTap});
}

class DonorActivitySection extends StatefulWidget {
  final MockDonor donor;
  final Color color;

  const DonorActivitySection({super.key, required this.donor, required this.color});

  @override
  State<DonorActivitySection> createState() => _DonorActivitySectionState();
}

class _DonorActivitySectionState extends State<DonorActivitySection> {
  static const _pageSize = 12;
  bool _showAll = false;

  List<_Entry> _entries(BuildContext context) {
    final donorId = widget.donor.id;
    final drm = DrmStore.instance;
    final out = <_Entry>[];

    for (final i in drm.interactionsFor(donorId)) {
      out.add(_Entry(
        date: i.date,
        icon: i.type.icon,
        color: AppColors.vaikunthamBlue,
        title: i.outcome == null ? i.type.label : '${i.type.label} · ${i.outcome}',
        body: i.notes,
        meta: '${ddmmyyyy(i.date)} · ${i.by}',
      ));
    }
    for (final t in drm.tasksFor(donorId)) {
      out.add(_Entry(
        date: t.createdAt,
        icon: Icons.add_task,
        color: AppColors.gold,
        title: 'Follow-up added: ${t.title}',
        meta: '${ddmmyyyy(t.createdAt)} · due ${ddmmyyyy(t.dueDate)} · ${t.assignedTo}',
      ));
      if (!t.isOpen && t.completedAt != null) {
        out.add(_Entry(
          date: t.completedAt!,
          icon: Icons.task_alt,
          color: AppColors.successColor,
          title: 'Follow-up done: ${t.title}',
          meta: ddmmyyyy(t.completedAt!),
        ));
      }
    }
    for (final r in MockData.donationsForDonor(donorId)) {
      final cancelled = r.status == DonationStatus.cancelled;
      out.add(_Entry(
        date: r.date,
        icon: cancelled ? Icons.receipt_long_outlined : Icons.receipt_long,
        color: cancelled ? AppColors.errorColor : AppColors.approverColor,
        title: '${cancelled ? 'Receipt (cancelled)' : 'Receipt'} ${inr(r.amount)}',
        body: '${r.trust} · ${r.sevaLabel}',
        meta: '${ddmmyyyy(r.date)} · ${r.receiptNumber}',
      ));
    }
    for (final a in ApprovalStore.instance.requestsForDonor(donorId)) {
      out.add(_Entry(
        date: a.requestedAt,
        icon: ApprovalActionType.icon(a.actionType),
        color: a.status.color,
        title: '${a.title} · ${a.status.label}',
        body: a.outcome,
        meta: '${ddmmyyyy(a.requestedAt)} · ${a.id} · by ${a.requestedBy}',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ApprovalRequestDetailPage(requestId: a.id, color: widget.color)),
        ),
      ));
    }
    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final donor = widget.donor;
    final open = DrmStore.instance.tasksFor(donor.id).where((t) => t.isOpen).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final entries = _entries(context);
    final shown = _showAll ? entries : entries.take(_pageSize).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12)),
                onPressed: () => showLogInteractionSheet(context, donor: donor),
                icon: const Icon(Icons.edit_note, size: 18),
                label: const Text('Log interaction', maxLines: 1, style: TextStyle(fontSize: 13)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12)),
                onPressed: () => showAddFollowUpSheet(context, donor: donor),
                icon: const Icon(Icons.add_task, size: 18),
                label: const Text('Add follow-up', maxLines: 1, style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SectionTitle('Open follow-ups (${open.length})'),
        if (open.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('No open follow-ups', style: TextStyle(color: Colors.grey.shade600)),
          ),
        ...open.map((t) => FollowUpTile(task: t, showDonor: false)),
        const SizedBox(height: 8),
        SectionTitle('Timeline (${entries.length})'),
        if (entries.isEmpty) Text('Nothing recorded yet', style: TextStyle(color: Colors.grey.shade600)),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < shown.length; i++) ...[
                _tile(shown[i]),
                if (i < shown.length - 1) const Divider(height: 1, indent: 56),
              ],
            ],
          ),
        ),
        if (entries.length > _pageSize)
          TextButton(
            onPressed: () => setState(() => _showAll = !_showAll),
            child: Text(_showAll ? 'Show less' : 'Show all ${entries.length}'),
          ),
      ],
    );
  }

  Widget _tile(_Entry e) {
    return InkWell(
      onTap: e.onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: e.color.withValues(alpha: 0.13),
              child: Icon(e.icon, size: 16, color: e.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
                  if (e.body != null && e.body!.isNotEmpty)
                    Text(e.body!, style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                  Text(e.meta, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (e.onTap != null) Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}
