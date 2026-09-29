// lib/features/shared/approvals/presentation/pages/approval_settings_page.dart
//
// Admin-only approval configuration, same shape as DCC's Approval Settings:
// "Levels" (ordered hierarchy, each a team leader or a list of users, with
// an active switch) and "Rules" (per action type: on/off, thresholds and
// steps). Everything writes to ApprovalStore, so new requests use it at once.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/amount_bars.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/shared/approvals/presentation/widgets/level_editor_sheet.dart';
import 'package:surabhi/features/shared/approvals/presentation/widgets/rule_settings_card.dart';

class ApprovalSettingsPage extends StatelessWidget {
  const ApprovalSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ApprovalStore.instance;
    return AppScaffold(
      title: 'Approval Settings',
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final levels = store.sortedLevels;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(gradient: AppColors.creamGradient, borderRadius: BorderRadius.circular(16)),
                child: const Text(
                  'Requests move up the levels in order. Changes here apply to new requests straight away; '
                  'requests already raised keep the steps they were created with.',
                  style: TextStyle(fontSize: 12, color: AppColors.ink),
                ),
              ),
              const SizedBox(height: 12),
              SectionTitle(
                'Levels',
                trailing: TextButton.icon(
                  onPressed: () => showLevelEditorSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add level'),
                ),
              ),
              ...levels.asMap().entries.map((e) => _LevelTile(level: e.value, isFirst: e.key == 0, isLast: e.key == levels.length - 1)),
              const SizedBox(height: 12),
              const SectionTitle('Rules'),
              ...ApprovalActionType.all.map((t) => RuleSettingsCard(rule: store.rule(t))),
            ],
          );
        },
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final ApprovalLevel level;
  final bool isFirst;
  final bool isLast;

  const _LevelTile({required this.level, required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final store = ApprovalStore.instance;
    final isTl = level.approverType == ApproverType.teamLeader;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 4),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: level.isActive ? AppColors.gold : Colors.grey.shade400,
                  child: Text('${level.order}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: level.isActive ? AppColors.ink : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StatusChip(
                        label: isTl ? 'TEAM_LEADER' : 'USERS',
                        color: isTl ? AppColors.vaikunthamBlue : AppColors.approverColor,
                        icon: isTl ? Icons.supervisor_account : Icons.group,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isTl ? "Requester's own team leader" : level.members.join(', '),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: level.isActive,
                  onChanged: (v) {
                    level.isActive = v;
                    store.touch();
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(level.isActive ? 'Active' : 'Inactive - skipped', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                const Spacer(),
                IconButton(
                  tooltip: 'Move up',
                  onPressed: isFirst ? null : () => store.moveLevel(level, -1),
                  icon: const Icon(Icons.arrow_upward),
                ),
                IconButton(
                  tooltip: 'Move down',
                  onPressed: isLast ? null : () => store.moveLevel(level, 1),
                  icon: const Icon(Icons.arrow_downward),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () => showLevelEditorSheet(context, level: level),
                  icon: const Icon(Icons.edit_outlined, color: AppColors.gold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
