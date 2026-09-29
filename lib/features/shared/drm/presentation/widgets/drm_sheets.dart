// lib/features/shared/drm/presentation/widgets/drm_sheets.dart
//
// Bottom-sheet / dialog forms for DRM: log an interaction, add a follow-up,
// pick donor tags, complete a follow-up (optional outcome note), bulk
// follow-ups for a segment, and marking a patron publication dispatched.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/demo_identity.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_drm.dart';
import 'package:surabhi/core/theme/app_colors.dart';

Future<T?> _sheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), child: child),
    ),
  );
}

Widget _title(String text, [String? subtitle]) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink)),
        if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );

/// A tappable field that opens the date picker.
class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  const _DateField({required this.label, required this.value, required this.firstDate, required this.lastDate, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: value, firstDate: firstDate, lastDate: lastDate);
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.event)),
        child: Text(ddmmyyyy(value)),
      ),
    );
  }
}

void _snack(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

// ---------------------------------------------------------------------------
// Log interaction
// ---------------------------------------------------------------------------

Future<void> showLogInteractionSheet(BuildContext context, {required MockDonor donor}) =>
    _sheet(context, _LogInteractionForm(donor: donor, parent: context));

class _LogInteractionForm extends StatefulWidget {
  final MockDonor donor;
  final BuildContext parent;

  const _LogInteractionForm({required this.donor, required this.parent});

  @override
  State<_LogInteractionForm> createState() => _LogInteractionFormState();
}

class _LogInteractionFormState extends State<_LogInteractionForm> {
  InteractionType _type = InteractionType.call;
  DateTime _date = MockData.today;
  String? _outcome;
  final _notes = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (_notes.text.trim().isEmpty) {
      setState(() => _error = 'Add a short note');
      return;
    }
    final now = DateTime.now();
    DrmStore.instance.logInteraction(
      donorId: widget.donor.id,
      type: _type,
      // Keep the time of day so today's entries sort in the order logged
      date: DateTime(_date.year, _date.month, _date.day, now.hour, now.minute),
      notes: _notes.text.trim(),
      outcome: _outcome,
      by: DemoIdentity.of(context).name,
    );
    Navigator.of(context).pop();
    _snack(widget.parent, '${_type.label} logged for ${widget.donor.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _title('Log interaction', widget.donor.name),
        const SizedBox(height: 14),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: InteractionType.values
              .map((t) => ChoiceChip(
                    avatar: Icon(t.icon, size: 16),
                    label: Text(t.label),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        _DateField(
          label: 'Date',
          value: _date,
          firstDate: MockData.today.subtract(const Duration(days: 365)),
          lastDate: MockData.today,
          onChanged: (d) => setState(() => _date = d),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          maxLines: 3,
          decoration: InputDecoration(labelText: 'Notes *', prefixIcon: const Icon(Icons.notes), errorText: _error),
        ),
        const SizedBox(height: 12),
        const Text('Outcome', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: kInteractionOutcomes
              .map((o) => ChoiceChip(
                    label: Text(o),
                    selected: _outcome == o,
                    onSelected: (v) => setState(() => _outcome = v ? o : null),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _save,
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Add follow-up
// ---------------------------------------------------------------------------

Future<void> showAddFollowUpSheet(BuildContext context, {required MockDonor donor}) =>
    _sheet(context, _AddFollowUpForm(donor: donor, parent: context));

class _AddFollowUpForm extends StatefulWidget {
  final MockDonor donor;
  final BuildContext parent;

  const _AddFollowUpForm({required this.donor, required this.parent});

  @override
  State<_AddFollowUpForm> createState() => _AddFollowUpFormState();
}

class _AddFollowUpFormState extends State<_AddFollowUpForm> {
  final _titleCtl = TextEditingController();
  final _notes = TextEditingController();
  DateTime _due = MockData.today.add(const Duration(days: 1));
  TaskPriority _priority = TaskPriority.normal;
  late String _assignedTo;
  late List<String> _assignees;
  String? _error;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _ready = true;
    final who = DemoIdentity.of(context);
    _assignees = {widget.donor.enrolledByCode, who.name}.toList();
    _assignedTo = who.isPreacher ? who.name : widget.donor.enrolledByCode;
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleCtl.text.trim().isEmpty) {
      setState(() => _error = 'What needs to be done?');
      return;
    }
    DrmStore.instance.addTask(
      donorId: widget.donor.id,
      title: _titleCtl.text.trim(),
      notes: _notes.text.trim(),
      dueDate: _due,
      priority: _priority,
      assignedTo: _assignedTo,
    );
    Navigator.of(context).pop();
    _snack(widget.parent, 'Follow-up added for ${ddmmyyyy(_due)}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _title('Add follow-up', widget.donor.name),
        const SizedBox(height: 14),
        TextField(
          controller: _titleCtl,
          decoration: InputDecoration(labelText: 'Title *', prefixIcon: const Icon(Icons.task_alt), errorText: _error),
        ),
        const SizedBox(height: 12),
        TextField(controller: _notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes', prefixIcon: Icon(Icons.notes))),
        const SizedBox(height: 12),
        _DateField(
          label: 'Due date',
          value: _due,
          firstDate: MockData.today.subtract(const Duration(days: 30)),
          lastDate: MockData.today.add(const Duration(days: 365)),
          onChanged: (d) => setState(() => _due = d),
        ),
        const SizedBox(height: 12),
        const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: TaskPriority.values
              .map((p) => ChoiceChip(label: Text(p.label), selected: _priority == p, onSelected: (_) => setState(() => _priority = p)))
              .toList(),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _assignedTo,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Assigned to', prefixIcon: Icon(Icons.person_outline)),
          items: _assignees.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
          onChanged: (v) => setState(() => _assignedTo = v ?? _assignedTo),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _save,
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          icon: const Icon(Icons.add_task),
          label: const Text('Add follow-up'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tags
// ---------------------------------------------------------------------------

Future<void> showTagPickerSheet(BuildContext context, {required MockDonor donor}) =>
    _sheet(context, _TagPicker(donor: donor));

class _TagPicker extends StatefulWidget {
  final MockDonor donor;

  const _TagPicker({required this.donor});

  @override
  State<_TagPicker> createState() => _TagPickerState();
}

class _TagPickerState extends State<_TagPicker> {
  late final Set<String> _selected = {...DrmStore.instance.tagIdsFor(widget.donor.id)};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _title('Tags', widget.donor.name),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DrmStore.instance.tags
              .map((t) => FilterChip(
                    label: Text(t.name),
                    selected: _selected.contains(t.id),
                    selectedColor: t.color.withValues(alpha: 0.18),
                    checkmarkColor: t.color,
                    side: BorderSide(color: t.color.withValues(alpha: 0.5)),
                    onSelected: (v) => setState(() => v ? _selected.add(t.id) : _selected.remove(t.id)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            DrmStore.instance.setTags(widget.donor.id, _selected);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          icon: const Icon(Icons.check),
          label: const Text('Save tags'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Complete a follow-up
// ---------------------------------------------------------------------------

/// Marks [task] done; the optional outcome/note is logged as an interaction.
Future<void> completeFollowUp(BuildContext context, DrmTask task) async {
  final by = DemoIdentity.of(context).name;
  final result = await showDialog<(String?, String)>(context: context, builder: (_) => _CompleteDialog(task: task));
  if (result == null) return;
  DrmStore.instance.completeTask(task, by: by, outcome: result.$1, note: result.$2);
  if (context.mounted) _snack(context, 'Marked done: ${task.title}');
}

class _CompleteDialog extends StatefulWidget {
  final DrmTask task;

  const _CompleteDialog({required this.task});

  @override
  State<_CompleteDialog> createState() => _CompleteDialogState();
}

class _CompleteDialogState extends State<_CompleteDialog> {
  String? _outcome;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mark follow-up done'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            const Text('Outcome (optional)', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: kInteractionOutcomes
                  .map((o) => ChoiceChip(
                        label: Text(o, style: const TextStyle(fontSize: 12)),
                        selected: _outcome == o,
                        visualDensity: VisualDensity.compact,
                        onSelected: (v) => setState(() => _outcome = v ? o : null),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            TextField(controller: _note, maxLines: 2, decoration: const InputDecoration(labelText: 'Note (optional)')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(context, (_outcome, _note.text)), child: const Text('Done')),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bulk follow-ups (Segments)
// ---------------------------------------------------------------------------

/// Creates one follow-up per donor; returns how many were created.
Future<int?> showBulkFollowUpSheet(BuildContext context, {required List<MockDonor> donors}) =>
    _sheet<int>(context, _BulkFollowUpForm(donors: donors));

class _BulkFollowUpForm extends StatefulWidget {
  final List<MockDonor> donors;

  const _BulkFollowUpForm({required this.donors});

  @override
  State<_BulkFollowUpForm> createState() => _BulkFollowUpFormState();
}

class _BulkFollowUpFormState extends State<_BulkFollowUpForm> {
  final _titleCtl = TextEditingController();
  DateTime _due = MockData.today.add(const Duration(days: 2));
  TaskPriority _priority = TaskPriority.normal;
  String? _error;

  @override
  void dispose() {
    _titleCtl.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleCtl.text.trim().isEmpty) {
      setState(() => _error = 'Give the follow-up a title');
      return;
    }
    final who = DemoIdentity.of(context);
    var n = 0;
    // Each follow-up goes to the donor's own preacher (or to me, for a preacher)
    final byAssignee = <String, List<String>>{};
    for (final d in widget.donors) {
      byAssignee.putIfAbsent(who.isPreacher ? who.name : d.enrolledByCode, () => []).add(d.id);
    }
    for (final e in byAssignee.entries) {
      n += DrmStore.instance.addTasksForAll(
        donorIds: e.value,
        title: _titleCtl.text.trim(),
        dueDate: _due,
        assignedTo: e.key,
        priority: _priority,
      );
    }
    Navigator.of(context).pop(n);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _title('Follow-up for all', '${widget.donors.length} donor(s) in this segment'),
        const SizedBox(height: 14),
        TextField(
          controller: _titleCtl,
          decoration: InputDecoration(
            labelText: 'Title *',
            hintText: 'e.g. Invite for Deepotsava',
            prefixIcon: const Icon(Icons.task_alt),
            errorText: _error,
          ),
        ),
        const SizedBox(height: 12),
        _DateField(
          label: 'Due date',
          value: _due,
          firstDate: MockData.today,
          lastDate: MockData.today.add(const Duration(days: 365)),
          onChanged: (d) => setState(() => _due = d),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          children: TaskPriority.values
              .map((p) => ChoiceChip(label: Text(p.label), selected: _priority == p, onSelected: (_) => setState(() => _priority = p)))
              .toList(),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: widget.donors.isEmpty ? null : _save,
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          icon: const Icon(Icons.playlist_add_check),
          label: Text('Create ${widget.donors.length} follow-up(s)'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Mark publication dispatched (Patron Lifecycle)
// ---------------------------------------------------------------------------

Future<void> showMarkDispatchedSheet(BuildContext context, {required PublicationEntitlement entitlement, required String donorName}) =>
    _sheet(context, _DispatchForm(entitlement: entitlement, donorName: donorName, parent: context));

class _DispatchForm extends StatefulWidget {
  final PublicationEntitlement entitlement;
  final String donorName;
  final BuildContext parent;

  const _DispatchForm({required this.entitlement, required this.donorName, required this.parent});

  @override
  State<_DispatchForm> createState() => _DispatchFormState();
}

class _DispatchFormState extends State<_DispatchForm> {
  DateTime _date = MockData.today;
  String _mode = kDispatchModes.first;
  final _tracking = TextEditingController();

  @override
  void dispose() {
    _tracking.dispose();
    super.dispose();
  }

  void _save() {
    DrmStore.instance.markDispatched(
      widget.entitlement,
      PublicationDispatch(date: _date, mode: _mode, trackingNo: _tracking.text.trim().isEmpty ? null : _tracking.text.trim()),
    );
    Navigator.of(context).pop();
    _snack(widget.parent, '${widget.entitlement.item} marked dispatched to ${widget.donorName}');
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entitlement;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _title('Mark dispatched', '${e.item} (${e.language}) · ${widget.donorName}'),
        const SizedBox(height: 14),
        _DateField(
          label: 'Dispatch date',
          value: _date,
          firstDate: MockData.today.subtract(const Duration(days: 90)),
          lastDate: MockData.today,
          onChanged: (d) => setState(() => _date = d),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _mode,
          decoration: const InputDecoration(labelText: 'Mode', prefixIcon: Icon(Icons.local_shipping_outlined)),
          items: kDispatchModes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (v) => setState(() => _mode = v ?? _mode),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _tracking,
          decoration: InputDecoration(
            labelText: _mode == 'Hand' ? 'Tracking no. (not needed for hand delivery)' : 'Tracking no.',
            prefixIcon: const Icon(Icons.qr_code_2),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _save,
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          icon: const Icon(Icons.check),
          label: const Text('Save dispatch'),
        ),
      ],
    );
  }
}
