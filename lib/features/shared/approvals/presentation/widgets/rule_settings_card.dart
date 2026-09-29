// lib/features/shared/approvals/presentation/widgets/rule_settings_card.dart
//
// One action type's approval rule: enable switch, thresholds (high-value
// receipts only) and the ordered steps, each a level plus an optional
// minimum amount. Edits write straight into the ApprovalStore.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/theme/app_colors.dart';

class RuleSettingsCard extends StatelessWidget {
  final ApprovalRule rule;

  const RuleSettingsCard({super.key, required this.rule});

  ApprovalStore get _store => ApprovalStore.instance;

  @override
  Widget build(BuildContext context) {
    final levels = _store.sortedLevels;
    final isHighValue = rule.actionType == ApprovalActionType.highValueReceipt;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(ApprovalActionType.icon(rule.actionType), color: ApprovalActionType.color(rule.actionType), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rule.label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                      Text(rule.actionType, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Switch(
                  value: rule.isEnabled,
                  onChanged: (v) {
                    rule.isEnabled = v;
                    _store.touch();
                  },
                ),
              ],
            ),
            if (!rule.isEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 6),
                child: Text('Off - this action applies immediately without approval.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              )
            else ...[
              if (isHighValue) ...[
                const SizedBox(height: 8),
                _amountField(
                  key: ValueKey('${rule.actionType}-threshold'),
                  label: 'Threshold, any mode (₹)',
                  value: rule.thresholdAmount,
                  onChanged: (v) => rule.thresholdAmount = v,
                ),
                const SizedBox(height: 10),
                _amountField(
                  key: ValueKey('${rule.actionType}-cash'),
                  label: 'Cash threshold (₹)',
                  value: rule.cashThresholdAmount,
                  onChanged: (v) => rule.cashThresholdAmount = v,
                ),
              ],
              const SizedBox(height: 10),
              Text('Steps (run in level order)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
              const SizedBox(height: 6),
              if (rule.steps.isEmpty)
                Text('No steps - add one, or turn the rule off.', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ...rule.steps.asMap().entries.map((e) => _stepEditor(e.key, e.value, levels)),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: levels.isEmpty
                      ? null
                      : () {
                          rule.steps.add(RuleStep(levelId: levels.first.id));
                          _store.touch();
                        },
                  icon: const Icon(Icons.add),
                  label: const Text('Add step'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Stacked (header row, then full-width level and amount) so level names
  // and the field label aren't cut off on a 320px phone
  Widget _stepEditor(int index, RuleStep step, List<ApprovalLevel> levels) {
    return Container(
      key: ObjectKey(step),
      margin: const EdgeInsets.only(bottom: 8, right: 6),
      padding: const EdgeInsets.fromLTRB(10, 2, 4, 10),
      decoration: BoxDecoration(color: AppColors.creamLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightBorderColor)),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: AppColors.gold,
                child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('Step ${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              IconButton(
                tooltip: 'Remove step',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline, color: AppColors.errorColor),
                onPressed: () {
                  rule.steps.remove(step);
                  _store.touch();
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: levels.any((l) => l.id == step.levelId) ? step.levelId : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Level', isDense: true),
                  items: levels
                      .map((l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(l.isActive ? l.name : '${l.name} (inactive)', overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    step.levelId = v;
                    _store.touch();
                  },
                ),
                const SizedBox(height: 8),
                _amountField(
                  // Record keys compare by value, so this stays stable across rebuilds
                  key: ValueKey(('min', step)),
                  label: 'Min amount ₹ (optional)',
                  value: step.minAmount,
                  onChanged: (v) => step.minAmount = v,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountField({required Key key, required String label, required int? value, required ValueChanged<int?> onChanged}) {
    return TextFormField(
      key: key,
      initialValue: value?.toString() ?? '',
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        prefixIcon: const Icon(Icons.currency_rupee, size: 18),
        helperText: value == null ? null : inr(value),
      ),
      onChanged: (text) {
        onChanged(int.tryParse(text.replaceAll(',', '').trim()));
        // Rebuild so the ₹ helper text follows the typed amount
        _store.touch();
      },
    );
  }
}
