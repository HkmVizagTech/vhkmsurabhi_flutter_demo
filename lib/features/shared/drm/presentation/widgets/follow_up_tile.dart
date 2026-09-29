// lib/features/shared/drm/presentation/widgets/follow_up_tile.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_drm.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/features/shared/drm/presentation/widgets/drm_chips.dart';
import 'package:surabhi/features/shared/drm/presentation/widgets/drm_sheets.dart';

String dueText(DrmTask t, DateTime today) {
  if (!t.isOpen) return t.completedAt == null ? 'Done' : 'Done ${ddmmyyyy(t.completedAt!)}';
  final days = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day).difference(today).inDays;
  if (days < 0) return 'Overdue by ${-days} day${days == -1 ? '' : 's'} · ${ddmmyyyy(t.dueDate)}';
  if (days == 0) return 'Due today';
  if (days == 1) return 'Due tomorrow';
  return 'Due in $days days · ${ddmmyyyy(t.dueDate)}';
}

/// One follow-up with a Done checkbox. [onOpen] (e.g. go to Donor 360) makes
/// the whole tile tappable; [showDonor] adds the donor's name.
class FollowUpTile extends StatelessWidget {
  final DrmTask task;
  final bool showDonor;
  final VoidCallback? onOpen;

  const FollowUpTile({super.key, required this.task, this.showDonor = true, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final today = MockData.today;
    final bucket = task.bucketOn(today);
    final dueColor = switch (bucket) {
      FollowUpBucket.overdue => AppColors.errorColor,
      FollowUpBucket.today => AppColors.warningColor,
      FollowUpBucket.upcoming => Colors.grey.shade700,
      FollowUpBucket.done => AppColors.successColor,
    };
    final donor = MockData.donorById(task.donorId);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: !task.isOpen,
                activeColor: AppColors.successColor,
                onChanged: (v) {
                  if (task.isOpen) {
                    completeFollowUp(context, task);
                  } else {
                    DrmStore.instance.reopenTask(task);
                  }
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDonor && donor != null)
                        Text(donor.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: showDonor ? 13 : 14,
                              fontWeight: showDonor ? FontWeight.w500 : FontWeight.w700,
                              color: AppColors.ink,
                              decoration: task.isOpen ? null : TextDecoration.lineThrough,
                            ),
                          ),
                          PriorityChip(priority: task.priority),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(dueText(task, today), style: TextStyle(fontSize: 12, color: dueColor, fontWeight: FontWeight.w600)),
                      Text('Assigned to ${task.assignedTo}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      if (task.notes.isNotEmpty)
                        Text(task.notes, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
              if (onOpen != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
