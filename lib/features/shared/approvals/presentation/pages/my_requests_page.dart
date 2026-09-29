// lib/features/shared/approvals/presentation/pages/my_requests_page.dart
//
// Requests raised by the signed-in preacher / employee, with their status
// and where each one is in its approval chain.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/demo_identity.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/shared/approvals/presentation/widgets/approval_request_card.dart';

class MyRequestsPage extends StatefulWidget {
  final Color color;

  const MyRequestsPage({super.key, required this.color});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  RequestStatus? _status; // null = all

  @override
  Widget build(BuildContext context) {
    final who = DemoIdentity.of(context);
    return AppScaffold(
      title: 'My Requests',
      body: ListenableBuilder(
        listenable: ApprovalStore.instance,
        builder: (context, _) {
          final mine = ApprovalStore.instance.requestsBy(who.name);
          final shown = _status == null ? mine : mine.where((r) => r.status == _status).toList();
          int count(RequestStatus s) => mine.where((r) => r.status == s).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(gradient: AppColors.creamGradient, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.outbox_outlined, color: AppColors.gold, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${mine.length} request(s) raised by ${who.name} · ${count(RequestStatus.pending)} pending',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _chip(null, 'All (${mine.length})'),
                  ...RequestStatus.values.map((s) => _chip(s, '${s.label} (${count(s)})')),
                ],
              ),
              const SizedBox(height: 12),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    mine.isEmpty
                        ? 'No requests yet. Cancellations, donor changes, patron enrolments and high-value receipts you raise will appear here.'
                        : 'No requests with this status',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ...shown.map((r) => ApprovalRequestCard(request: r, color: widget.color)),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(RequestStatus? status, String label) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _status == status,
      visualDensity: VisualDensity.compact,
      onSelected: (_) => setState(() => _status = status),
    );
  }
}
