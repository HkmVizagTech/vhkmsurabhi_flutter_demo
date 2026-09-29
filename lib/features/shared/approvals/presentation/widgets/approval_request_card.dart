// lib/features/shared/approvals/presentation/widgets/approval_request_card.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/demo_identity.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/amount_bars.dart';
import 'package:surabhi/features/shared/approvals/presentation/pages/approval_request_detail_page.dart';
import 'package:surabhi/features/shared/approvals/presentation/widgets/step_chain.dart';

/// Type badge + status, title, donor, amount, requester, age and the
/// compact step chain. Taps through to the request detail.
class ApprovalRequestCard extends StatelessWidget {
  final ApprovalRequest request;
  final Color color;

  const ApprovalRequestCard({super.key, required this.request, required this.color});

  @override
  Widget build(BuildContext context) {
    final r = request;
    final typeColor = ApprovalActionType.color(r.actionType);
    final muted = TextStyle(fontSize: 12, color: Colors.grey.shade700);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ApprovalRequestDetailPage(requestId: r.id, color: color)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusChip(
                    label: ApprovalActionType.shortLabel(r.actionType),
                    color: typeColor,
                    icon: ApprovalActionType.icon(r.actionType),
                  ),
                  StatusChip(label: r.status.label, color: r.status.color),
                  Text(r.id, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 8),
              Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
              const SizedBox(height: 2),
              Text(r.donorName, style: const TextStyle(fontSize: 13)),
              if (r.amount != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(inr(r.amount!), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              const SizedBox(height: 4),
              Text('By ${r.requestedBy} · ${timeAgo(r.requestedAt)}', style: muted),
              const SizedBox(height: 8),
              StepChain(steps: r.steps),
            ],
          ),
        ),
      ),
    );
  }
}
