// lib/features/shared/approvals/presentation/widgets/step_chain.dart
//
// Compact approval chain: ✓ approved, ● pending, ○ waiting, – skipped,
// ✕ rejected. A Wrap so long chains flow onto a second line on 320px phones.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/theme/app_colors.dart';

IconData stepIcon(StepStatus status) => switch (status) {
      StepStatus.approved => Icons.check_circle,
      StepStatus.pending => Icons.radio_button_checked,
      StepStatus.waiting => Icons.radio_button_unchecked,
      StepStatus.skipped => Icons.remove_circle_outline,
      StepStatus.rejected => Icons.cancel,
    };

Color stepColor(StepStatus status) => switch (status) {
      StepStatus.approved => AppColors.successColor,
      StepStatus.pending => AppColors.warningColor,
      StepStatus.waiting => Colors.grey.shade500,
      StepStatus.skipped => Colors.grey.shade500,
      StepStatus.rejected => AppColors.errorColor,
    };

String stepLabel(StepStatus status) => switch (status) {
      StepStatus.approved => 'Approved',
      StepStatus.pending => 'Pending',
      StepStatus.waiting => 'Waiting',
      StepStatus.skipped => 'Skipped',
      StepStatus.rejected => 'Rejected',
    };

class StepChain extends StatelessWidget {
  final List<RequestStep> steps;

  const StepChain({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Text('No approval steps', style: TextStyle(fontSize: 12, color: Colors.grey.shade600));
    }
    final children = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      final s = steps[i];
      final color = stepColor(s.status);
      children.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stepIcon(s.status), size: 14, color: color),
          const SizedBox(width: 3),
          Text(
            s.levelName,
            style: TextStyle(
              fontSize: 12,
              color: s.status == StepStatus.waiting || s.status == StepStatus.skipped ? Colors.grey.shade600 : AppColors.ink,
              fontWeight: s.status == StepStatus.pending ? FontWeight.w700 : FontWeight.w500,
              decoration: s.status == StepStatus.skipped ? TextDecoration.lineThrough : null,
            ),
          ),
          if (i < steps.length - 1) ...[
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade500),
          ],
        ],
      ));
    }
    return Wrap(spacing: 4, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: children);
  }
}
