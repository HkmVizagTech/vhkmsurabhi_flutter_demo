// lib/features/shared/drm/presentation/widgets/patron_widgets.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_drm.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/amount_bars.dart';

/// Committed vs received progress, pending amount and last payment.
class PatronProgress extends StatelessWidget {
  final PatronRecord record;

  const PatronProgress({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final p = record;
    final muted = TextStyle(fontSize: 12, color: Colors.grey.shade700);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: p.progress,
            minHeight: 10,
            backgroundColor: AppColors.cream,
            valueColor: AlwaysStoppedAnimation(p.payStatus.color),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 2,
          children: [
            Text('Received ${inr(p.received)} of ${inr(p.committedAmount)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
            if (p.pending > 0)
              Text('Pending ${inr(p.pending)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.deepRed)),
          ],
        ),
        Text(
          p.lastPayment == null
              ? 'No instalment yet'
              : 'Last payment ${ddmmyyyy(p.lastPayment!)} · ${p.instalments.length} instalment${p.instalments.length == 1 ? '' : 's'}',
          style: muted,
        ),
      ],
    );
  }
}

/// Patron card for the Patron Lifecycle list.
class PatronCard extends StatelessWidget {
  final PatronRecord record;
  final VoidCallback onTap;

  const PatronCard({super.key, required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final donor = MockData.donorById(record.donorId);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(donor?.name ?? record.donorId, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                  StatusChip(label: record.payStatus.label, color: record.payStatus.color),
                ],
              ),
              const SizedBox(height: 2),
              Text('${record.schemeName} · ${record.trust} · ${record.donorId}${donor == null ? '' : ' · ${donor.enrolledByCode}'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              const SizedBox(height: 10),
              PatronProgress(record: record),
            ],
          ),
        ),
      ),
    );
  }
}

/// Donor 360 "Patronship" card body: progress, special pujas, publications.
class PatronshipSummary extends StatelessWidget {
  final PatronRecord record;

  const PatronshipSummary({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final today = MockData.today;
    final pujas = List.of(record.pujas)..sort((a, b) => a.nextOn(today).compareTo(b.nextOn(today)));
    final muted = TextStyle(fontSize: 12, color: Colors.grey.shade700);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${record.schemeName} · ${record.trust} · since ${ddmmyyyy(record.enrolledOn)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        PatronProgress(record: record),
        if (pujas.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Special pujas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 4),
          ...pujas.map((p) {
            final next = p.nextOn(today);
            final days = next.difference(today).inDays;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.local_florist_outlined, size: 16, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Expanded(child: Text(p.occasion, style: const TextStyle(fontSize: 13))),
                  Text(days == 0 ? 'Today' : '${ddmmyyyy(next)} · ${days}d', style: muted),
                ],
              ),
            );
          }),
        ],
        if (record.entitlements.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Publications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 4),
          ...record.entitlements.map((e) {
            final pending = e.isPendingOn(today);
            final last = e.lastDispatch;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(pending ? Icons.schedule : Icons.local_shipping, size: 16, color: pending ? AppColors.warningColor : AppColors.successColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${e.item} (${e.language})', style: const TextStyle(fontSize: 13)),
                        Text(
                          last == null
                              ? 'Not dispatched yet'
                              : '${pending ? 'Due again - last' : 'Dispatched'} ${ddmmyyyy(last.date)} · ${last.mode}${last.trackingNo == null ? '' : ' · ${last.trackingNo}'}',
                          style: muted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
