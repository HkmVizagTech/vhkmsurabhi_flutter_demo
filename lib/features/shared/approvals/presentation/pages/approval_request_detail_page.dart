// lib/features/shared/approvals/presentation/pages/approval_request_detail_page.dart
//
// One approval request: header, details, before -> after for donor
// changes, the vertical step timeline (who / when / comment), and
// Approve / Reject for whoever can act on the current step. The requester
// can withdraw while it is still pending.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/demo_identity.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/amount_bars.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/shared/approvals/presentation/widgets/step_chain.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_detail_page.dart';

String _when(DateTime d) => '${ddmmyyyy(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

class ApprovalRequestDetailPage extends StatelessWidget {
  final String requestId;
  final Color color;

  const ApprovalRequestDetailPage({super.key, required this.requestId, required this.color});

  @override
  Widget build(BuildContext context) {
    final store = ApprovalStore.instance;
    final who = DemoIdentity.of(context);
    return AppScaffold(
      title: 'Request $requestId',
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final r = store.byId(requestId);
          if (r == null) return const Center(child: Text('Request not found'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Header(request: r, color: color),
              const SizedBox(height: 12),
              if (r.details.isNotEmpty) _card('Details', Column(children: r.details.map((d) => _kv(d.$1, d.$2)).toList())),
              if (r.changes.isNotEmpty) _card('Requested changes', Column(children: r.changes.map(_change).toList())),
              _card('Approval steps', _Timeline(request: r)),
              const SizedBox(height: 4),
              _Actions(request: r, who: who, color: color),
            ],
          );
        },
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

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  // Before -> after, stacked so long addresses wrap instead of squeezing
  Widget _change(FieldChange c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold)),
          const SizedBox(height: 2),
          Text(
            c.before,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, decoration: TextDecoration.lineThrough),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2, right: 4),
                child: Icon(Icons.arrow_forward, size: 14, color: AppColors.successColor),
              ),
              Expanded(
                child: Text(c.after, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ApprovalRequest request;
  final Color color;

  const _Header({required this.request, required this.color});

  @override
  Widget build(BuildContext context) {
    final r = request;
    final donor = r.donorId == null ? null : MockData.donorById(r.donorId!);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.creamGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              StatusChip(
                label: ApprovalActionType.shortLabel(r.actionType),
                color: ApprovalActionType.color(r.actionType),
                icon: ApprovalActionType.icon(r.actionType),
              ),
              StatusChip(label: r.status.label, color: r.status.color),
            ],
          ),
          const SizedBox(height: 8),
          Text(r.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink)),
          if (r.amount != null) ...[
            const SizedBox(height: 2),
            Text(inr(r.amount!), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
          ],
          const SizedBox(height: 6),
          InkWell(
            onTap: donor == null
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DonorDetailPage(donor: donor, color: color))),
            child: Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.gold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    donor == null ? r.donorName : '${r.donorName} (${donor.id})',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: donor == null ? AppColors.ink : AppColors.goldenDark,
                      decoration: donor == null ? null : TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text('Requested by ${r.requestedBy} · ${_when(r.requestedAt)} (${timeAgo(r.requestedAt)})',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          if (r.reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Reason', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
            Text(r.reason, style: const TextStyle(fontSize: 13, color: AppColors.ink)),
          ],
          if (r.outcome != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.successColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(r.outcome!, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.successColor))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final ApprovalRequest request;

  const _Timeline({required this.request});

  @override
  Widget build(BuildContext context) {
    final r = request;
    final rows = <Widget>[
      _row(
        icon: Icons.send,
        color: AppColors.vaikunthamBlue,
        title: 'Requested',
        lines: ['${r.requestedBy} · ${_when(r.requestedAt)}'],
        isLast: r.steps.isEmpty && r.status != RequestStatus.withdrawn,
      ),
    ];
    for (var i = 0; i < r.steps.length; i++) {
      final s = r.steps[i];
      rows.add(_row(
        icon: stepIcon(s.status),
        color: stepColor(s.status),
        title: '${s.order}. ${s.levelName}',
        status: stepLabel(s.status),
        lines: [
          if (s.assignee.isNotEmpty && s.assignee != '-') 'Approver: ${s.assignee}',
          if (s.actedBy != null) '${stepLabel(s.status)} by ${s.actedBy}${s.actedAt == null ? '' : ' · ${_when(s.actedAt!)}'}',
        ],
        comment: s.comment,
        isLast: i == r.steps.length - 1 && r.status != RequestStatus.withdrawn,
      ));
    }
    if (r.status == RequestStatus.withdrawn) {
      rows.add(_row(
        icon: Icons.undo,
        color: Colors.blueGrey,
        title: 'Withdrawn',
        lines: ['${r.requestedBy}${r.closedAt == null ? '' : ' · ${_when(r.closedAt!)}'}'],
        isLast: true,
      ));
    }
    return Column(children: rows);
  }

  Widget _row({
    required IconData icon,
    required Color color,
    required String title,
    required List<String> lines,
    required bool isLast,
    String? status,
    String? comment,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Icon(icon, size: 20, color: color),
                if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                      if (status != null) StatusChip(label: status, color: color),
                    ],
                  ),
                  ...lines.map((l) => Text(l, style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
                  if (comment != null && comment.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(10)),
                      child: Text('“$comment”', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.ink)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final ApprovalRequest request;
  final DemoIdentity who;
  final Color color;

  const _Actions({required this.request, required this.who, required this.color});

  @override
  Widget build(BuildContext context) {
    final store = ApprovalStore.instance;
    final r = request;
    final canAct = store.canAct(r, who);
    final override = store.isOverride(r, who);
    final isRequester = r.requestedBy == who.name;

    if (!r.isPending) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canAct) ...[
          if (override)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StatusChip(
                label: 'Admin override - acting for ${r.currentStep?.levelName}',
                color: AppColors.deepRed,
                icon: Icons.admin_panel_settings,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorColor,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
                  ),
                  onPressed: () => _decide(context, approve: false),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject', maxLines: 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                  ),
                  onPressed: () => _decide(context, approve: true),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve', maxLines: 1),
                ),
              ),
            ],
          ),
        ] else if (!isRequester)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(12)),
            child: Text(
              'Waiting on ${r.currentStep?.levelName ?? '-'}${(r.currentStep?.assignee ?? '').isEmpty ? '' : ' (${r.currentStep!.assignee})'}',
              style: const TextStyle(fontSize: 13, color: AppColors.ink),
            ),
          ),
        if (isRequester) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _withdraw(context),
            icon: const Icon(Icons.undo, size: 18),
            label: const Text('Withdraw request'),
          ),
        ],
      ],
    );
  }

  Future<void> _withdraw(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw request?'),
        content: Text('${request.id} will be closed and no one will need to act on it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Withdraw')),
        ],
      ),
    );
    if (ok == true) {
      ApprovalStore.instance.withdraw(request);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${request.id} withdrawn')));
      }
    }
  }

  Future<void> _decide(BuildContext context, {required bool approve}) async {
    final comment = await showDialog<String>(
      context: context,
      builder: (ctx) => _CommentDialog(approve: approve),
    );
    if (comment == null) return;
    final store = ApprovalStore.instance;
    if (approve) {
      store.approve(request, who, comment: comment);
    } else {
      store.reject(request, who, comment: comment);
    }
    if (!context.mounted) return;
    final msg = !approve
        ? '${request.id} rejected'
        : request.status == RequestStatus.approved
            ? '${request.id} fully approved${request.outcome == null ? '' : ' - ${request.outcome}'}'
            : '${request.id} approved - now with ${request.currentStep?.levelName}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// Comment prompt - optional to approve, required to reject.
class _CommentDialog extends StatefulWidget {
  final bool approve;

  const _CommentDialog({required this.approve});

  @override
  State<_CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<_CommentDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.approve ? 'Approve request' : 'Reject request'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: widget.approve ? 'Comment (optional)' : 'Reason for rejecting *',
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.approve ? AppColors.successColor : AppColors.errorColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            final text = _controller.text.trim();
            if (!widget.approve && text.isEmpty) {
              setState(() => _error = 'A comment is required to reject');
              return;
            }
            Navigator.pop(context, text);
          },
          child: Text(widget.approve ? 'Approve' : 'Reject'),
        ),
      ],
    );
  }
}
