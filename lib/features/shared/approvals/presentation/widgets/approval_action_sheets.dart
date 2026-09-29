// lib/features/shared/approvals/presentation/widgets/approval_action_sheets.dart
//
// Donor 360 actions that go through hierarchy approval: request a donor
// detail change, request a receipt cancellation, enrol as patron. Each
// form previews who will approve; if the rule is switched off the change is
// applied immediately instead and a snackbar says so.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/demo_identity.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_drm.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/features/shared/approvals/presentation/pages/approval_request_detail_page.dart';
import 'package:surabhi/features/shared/approvals/presentation/widgets/step_chain.dart';

/// Snackbar after submitOrApply: sent for approval (with a View action),
/// auto-approved, or applied directly because no approval was needed.
void announceApprovalResult(BuildContext context, ApprovalRequest? req, {required String appliedText, required Color color}) {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  if (req == null) {
    messenger.showSnackBar(SnackBar(content: Text('$appliedText - no approval needed (rule is off)')));
    return;
  }
  final text = req.status == RequestStatus.approved
      ? '${req.id}: no approver needed, applied - ${req.outcome ?? ''}'
      : 'Sent for approval · ${req.id} - waiting on ${req.currentStep?.levelName ?? '-'}';
  messenger.showSnackBar(SnackBar(
    content: Text(text),
    action: SnackBarAction(
      label: 'View',
      onPressed: () => navigator.push(MaterialPageRoute(builder: (_) => ApprovalRequestDetailPage(requestId: req.id, color: color))),
    ),
  ));
}

Future<void> _sheet(BuildContext context, Widget child) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), child: child),
    ),
  );
}

class _ApprovalPreview extends StatelessWidget {
  final String actionType;
  final int? amount;
  final String requestedBy;

  const _ApprovalPreview({required this.actionType, required this.requestedBy, this.amount});

  @override
  Widget build(BuildContext context) {
    final store = ApprovalStore.instance;
    final needed = store.isApprovalRequired(actionType, amount: amount);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(12)),
      child: needed
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Needs approval from', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
                const SizedBox(height: 6),
                StepChain(steps: store.previewSteps(actionType, amount: amount, requestedBy: requestedBy)),
              ],
            )
          : const Text('Approval for this action is switched off - it will apply immediately.',
              style: TextStyle(fontSize: 12, color: AppColors.ink)),
    );
  }
}

Widget _title(String text) =>
    Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink));

// ---------------------------------------------------------------------------
// Donor detail change
// ---------------------------------------------------------------------------

Future<void> showRequestChangeSheet(BuildContext context, {required MockDonor donor, required Color color}) {
  return _sheet(context, _DonorChangeForm(donor: donor, color: color, parent: context));
}

class _DonorChangeForm extends StatefulWidget {
  final MockDonor donor;
  final Color color;
  final BuildContext parent;

  const _DonorChangeForm({required this.donor, required this.color, required this.parent});

  @override
  State<_DonorChangeForm> createState() => _DonorChangeFormState();
}

class _DonorChangeFormState extends State<_DonorChangeForm> {
  late final Map<String, TextEditingController> _fields = {
    'name': TextEditingController(text: widget.donor.name),
    'email': TextEditingController(text: widget.donor.email ?? ''),
    'address': TextEditingController(text: widget.donor.address ?? ''),
    'city': TextEditingController(text: widget.donor.city),
    'pan': TextEditingController(text: widget.donor.pan ?? ''),
  };
  final _reason = TextEditingController();
  String? _error;

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    _reason.dispose();
    super.dispose();
  }

  String _current(String field) => switch (field) {
        'name' => widget.donor.name,
        'email' => widget.donor.email ?? '',
        'address' => widget.donor.address ?? '',
        'city' => widget.donor.city,
        'pan' => widget.donor.pan ?? '',
        _ => '',
      };

  void _submit() {
    final changes = <FieldChange>[];
    for (final e in _fields.entries) {
      final before = _current(e.key);
      final after = e.key == 'pan' ? e.value.text.trim().toUpperCase() : e.value.text.trim();
      if (after != before) changes.add(FieldChange(e.key, before.isEmpty ? '-' : before, after.isEmpty ? '-' : after));
    }
    if (changes.isEmpty) {
      setState(() => _error = 'Nothing has changed yet');
      return;
    }
    if (changes.any((c) => c.field == 'name' && c.after == '-')) {
      setState(() => _error = 'Name cannot be empty');
      return;
    }
    final who = DemoIdentity.of(context);
    final req = ApprovalStore.instance.submitOrApply(
      actionType: ApprovalActionType.donorChange,
      title: changes.length == 1 ? 'Update ${changes.first.label.toLowerCase()}' : 'Update ${changes.length} donor details',
      donorId: widget.donor.id,
      donorName: widget.donor.name,
      reason: _reason.text.trim(),
      requestedBy: who.name,
      changes: changes,
    );
    Navigator.of(context).pop();
    announceApprovalResult(widget.parent, req, appliedText: 'Donor details updated', color: widget.color);
  }

  @override
  Widget build(BuildContext context) {
    final who = DemoIdentity.of(context);
    InputDecoration dec(String label, IconData icon) => InputDecoration(labelText: label, prefixIcon: Icon(icon));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _title('Request detail change'),
        Text('${widget.donor.name} · ${widget.donor.id}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        const SizedBox(height: 14),
        TextField(controller: _fields['name'], decoration: dec('Name', Icons.person)),
        const SizedBox(height: 12),
        TextField(controller: _fields['email'], keyboardType: TextInputType.emailAddress, decoration: dec('Email', Icons.email_outlined)),
        const SizedBox(height: 12),
        TextField(controller: _fields['address'], maxLines: 2, decoration: dec('Address', Icons.home_outlined)),
        const SizedBox(height: 12),
        TextField(controller: _fields['city'], decoration: dec('City', Icons.location_city)),
        const SizedBox(height: 12),
        TextField(controller: _fields['pan'], textCapitalization: TextCapitalization.characters, decoration: dec('PAN', Icons.badge_outlined)),
        const SizedBox(height: 12),
        TextField(controller: _reason, decoration: dec('Reason for the change', Icons.notes)),
        const SizedBox(height: 12),
        _ApprovalPreview(actionType: ApprovalActionType.donorChange, requestedBy: who.name),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppColors.errorColor, fontSize: 12)),
        ],
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          icon: const Icon(Icons.send),
          label: const Text('Submit change'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Receipt cancellation
// ---------------------------------------------------------------------------

Future<void> showCancelReceiptSheet(BuildContext context, {required MockDonation receipt, required Color color}) {
  return _sheet(context, _CancelReceiptForm(receipt: receipt, color: color, parent: context));
}

class _CancelReceiptForm extends StatefulWidget {
  final MockDonation receipt;
  final Color color;
  final BuildContext parent;

  const _CancelReceiptForm({required this.receipt, required this.color, required this.parent});

  @override
  State<_CancelReceiptForm> createState() => _CancelReceiptFormState();
}

class _CancelReceiptFormState extends State<_CancelReceiptForm> {
  final _reason = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    if (_reason.text.trim().isEmpty) {
      setState(() => _error = 'Please give a reason');
      return;
    }
    final r = widget.receipt;
    final who = DemoIdentity.of(context);
    final req = ApprovalStore.instance.submitOrApply(
      actionType: ApprovalActionType.cancelReceipt,
      title: 'Cancel receipt ${r.receiptNumber}',
      donorId: r.donorId,
      donorName: r.donorName,
      amount: r.amount,
      reason: _reason.text.trim(),
      requestedBy: who.name,
      receiptNumber: r.receiptNumber,
      details: [
        ('Receipt no.', r.receiptNumber),
        ('Receipt date', ddmmyyyy(r.date)),
        ('Trust', r.trust),
        ('Seva', r.sevaLabel),
        ('Mode', r.modeOfPayment),
      ],
    );
    Navigator.of(context).pop();
    announceApprovalResult(widget.parent, req, appliedText: 'Receipt ${r.receiptNumber} cancelled', color: widget.color);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.receipt;
    final who = DemoIdentity.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _title('Request cancellation'),
        const SizedBox(height: 6),
        Text(r.receiptNumber, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text('${inr(r.amount)} · ${r.sevaLabel} · ${ddmmyyyy(r.date)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        const SizedBox(height: 14),
        TextField(
          controller: _reason,
          autofocus: true,
          maxLines: 2,
          decoration: InputDecoration(labelText: 'Reason *', prefixIcon: const Icon(Icons.notes), errorText: _error),
        ),
        const SizedBox(height: 12),
        _ApprovalPreview(actionType: ApprovalActionType.cancelReceipt, amount: r.amount, requestedBy: who.name),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: AppColors.deepRed,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.block),
          label: const Text('Request cancellation'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Patron enrolment
// ---------------------------------------------------------------------------

Future<void> showEnrolPatronSheet(BuildContext context, {required MockDonor donor, required Color color}) {
  return _sheet(context, _EnrolPatronForm(donor: donor, color: color, parent: context));
}

class _EnrolPatronForm extends StatefulWidget {
  final MockDonor donor;
  final Color color;
  final BuildContext parent;

  const _EnrolPatronForm({required this.donor, required this.color, required this.parent});

  @override
  State<_EnrolPatronForm> createState() => _EnrolPatronFormState();
}

class _EnrolPatronFormState extends State<_EnrolPatronForm> {
  String _trust = MockData.trusts.first;
  PatronScheme _scheme = kPatronSchemes[2];
  late final _amount = TextEditingController(text: _scheme.amount.toString());
  final _notes = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  int? get _committed => int.tryParse(_amount.text.replaceAll(',', '').trim());

  void _submit() {
    final amount = _committed;
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter the committed amount');
      return;
    }
    final who = DemoIdentity.of(context);
    final req = ApprovalStore.instance.submitOrApply(
      actionType: ApprovalActionType.patronEnrol,
      title: 'Enrol as ${_scheme.name}',
      donorId: widget.donor.id,
      donorName: widget.donor.name,
      amount: amount,
      reason: _notes.text.trim(),
      requestedBy: who.name,
      patronScheme: _scheme.name,
      patronTrust: _trust,
      details: [('Scheme', _scheme.name), ('Trust', _trust), ('Committed', inr(amount))],
    );
    Navigator.of(context).pop();
    announceApprovalResult(widget.parent, req, appliedText: '${widget.donor.name} enrolled as ${_scheme.name}', color: widget.color);
  }

  @override
  Widget build(BuildContext context) {
    final who = DemoIdentity.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _title('Enrol as patron'),
        Text('${widget.donor.name} · ${widget.donor.id}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _trust,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Trust *', prefixIcon: Icon(Icons.account_balance)),
          items: MockData.trusts.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setState(() => _trust = v ?? _trust),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<PatronScheme>(
          initialValue: _scheme,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Scheme *', prefixIcon: Icon(Icons.workspace_premium_outlined)),
          items: kPatronSchemes
              .map((s) => DropdownMenuItem(value: s, child: Text('${s.name} (${inr(s.amount)})', overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (v) => setState(() {
            _scheme = v ?? _scheme;
            _amount.text = _scheme.amount.toString();
          }),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Committed amount (₹) *',
            prefixIcon: const Icon(Icons.currency_rupee),
            helperText: _committed == null ? null : inr(_committed!),
            errorText: _error,
          ),
        ),
        const SizedBox(height: 12),
        TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes', prefixIcon: Icon(Icons.notes))),
        const SizedBox(height: 12),
        _ApprovalPreview(actionType: ApprovalActionType.patronEnrol, amount: _committed, requestedBy: who.name),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          icon: const Icon(Icons.workspace_premium),
          label: const Text('Submit enrolment'),
        ),
      ],
    );
  }
}
