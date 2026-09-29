// lib/features/shared/drm/presentation/widgets/drm_chips.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_drm.dart';
import 'package:surabhi/core/widgets/amount_bars.dart';

class TierChip extends StatelessWidget {
  final DonorTier tier;

  const TierChip({super.key, required this.tier});

  @override
  Widget build(BuildContext context) => StatusChip(label: tier.code, color: tier.color, icon: tier.icon);
}

class TagChip extends StatelessWidget {
  final DrmTag tag;

  const TagChip({super.key, required this.tag});

  @override
  Widget build(BuildContext context) => StatusChip(label: tag.name, color: tag.color, icon: Icons.sell_outlined);
}

class PriorityChip extends StatelessWidget {
  final TaskPriority priority;

  const PriorityChip({super.key, required this.priority});

  @override
  Widget build(BuildContext context) => StatusChip(label: priority.label, color: priority.color, icon: Icons.flag_outlined);
}
