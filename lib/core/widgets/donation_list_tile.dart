// lib/core/widgets/donation_list_tile.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';

class DonationListTile extends StatelessWidget {
  final MockDonation donation;
  final Widget? trailingAction;

  const DonationListTile({super.key, required this.donation, this.trailingAction});

  Color _statusColor() {
    switch (donation.status) {
      case DonationStatus.approved:
        return Colors.green;
      case DonationStatus.pending:
        return Colors.orange;
      case DonationStatus.cancelled:
        return Colors.red;
    }
  }

  String _statusLabel() {
    switch (donation.status) {
      case DonationStatus.approved:
        return 'Approved';
      case DonationStatus.pending:
        return 'Pending';
      case DonationStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = '${donation.date.day.toString().padLeft(2, '0')}/${donation.date.month.toString().padLeft(2, '0')}/${donation.date.year}';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(donation.receiptNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_statusLabel(), style: TextStyle(color: _statusColor(), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(donation.donorName, style: const TextStyle(fontSize: 14)),
            Text(
              '${donation.trust} · ${donation.sevaCategory} · $dateStr',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('₹${donation.amount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                if (trailingAction != null) trailingAction!,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
