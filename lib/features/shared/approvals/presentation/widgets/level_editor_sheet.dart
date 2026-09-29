// lib/features/shared/approvals/presentation/widgets/level_editor_sheet.dart
//
// Bottom sheet to add or edit an approval level: name, approver type
// (requester's team leader / specific users) and the member list.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/theme/app_colors.dart';

/// Opens the editor; [level] null = add a new level. Saves into the store.
Future<void> showLevelEditorSheet(BuildContext context, {ApprovalLevel? level}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _LevelEditorSheet(level: level),
  );
}

class _LevelEditorSheet extends StatefulWidget {
  final ApprovalLevel? level;

  const _LevelEditorSheet({this.level});

  @override
  State<_LevelEditorSheet> createState() => _LevelEditorSheetState();
}

class _LevelEditorSheetState extends State<_LevelEditorSheet> {
  late final _name = TextEditingController(text: widget.level?.name ?? '');
  final _member = TextEditingController();
  late String _type = widget.level?.approverType ?? ApproverType.users;
  late final List<String> _members = List.of(widget.level?.members ?? const []);
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _member.dispose();
    super.dispose();
  }

  void _addMember() {
    final m = _member.text.trim();
    if (m.isEmpty || _members.contains(m)) return;
    setState(() {
      _members.add(m);
      _member.clear();
    });
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Give the level a name');
      return;
    }
    if (_type == ApproverType.users && _members.isEmpty) {
      setState(() => _error = 'Add at least one member for a "Specific users" level');
      return;
    }
    final store = ApprovalStore.instance;
    final members = _type == ApproverType.users ? _members : <String>[];
    if (widget.level == null) {
      store.addLevel(name: name, approverType: _type, members: members);
    } else {
      widget.level!
        ..name = name
        ..approverType = _type
        ..members = members;
      store.touch();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.level == null ? 'Add approval level' : 'Edit level',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 14),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Level name *', prefixIcon: Icon(Icons.layers_outlined)),
            ),
            const SizedBox(height: 14),
            const Text('Who approves at this level', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _ApproverTypeChoice(
              value: _type,
              onChanged: (v) => setState(() => _type = v),
            ),
            if (_type == ApproverType.users) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _members
                    .map((m) => InputChip(label: Text(m), onDeleted: () => setState(() => _members.remove(m))))
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _member,
                      decoration: const InputDecoration(labelText: 'Add member (name)', prefixIcon: Icon(Icons.person_add_alt)),
                      onSubmitted: (_) => _addMember(),
                    ),
                  ),
                  IconButton(onPressed: _addMember, icon: const Icon(Icons.add_circle, color: AppColors.gold)),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Each request goes to the requester's own team leader. If they have none, this step is skipped automatically.",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.errorColor, fontSize: 12)),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save level'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two choice tiles for the approver type. Built from ListTiles with check
/// icons rather than Radio, whose groupValue API is deprecated.
class _ApproverTypeChoice extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _ApproverTypeChoice({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget option(String type, String subtitle) {
      final selected = value == type;
      return Card(
        margin: const EdgeInsets.only(bottom: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? AppColors.gold : AppColors.lightBorderColor, width: selected ? 2 : 1),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: AppColors.gold),
          title: Text(ApproverType.label(type)),
          subtitle: Text(subtitle),
          onTap: () => onChanged(type),
        ),
      );
    }

    return Column(
      children: [
        option(ApproverType.teamLeader, 'TEAM_LEADER - resolved per requester'),
        option(ApproverType.users, 'USERS - any listed member can act'),
      ],
    );
  }
}
