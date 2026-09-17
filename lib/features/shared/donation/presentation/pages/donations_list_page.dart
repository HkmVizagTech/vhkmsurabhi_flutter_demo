// lib/features/shared/donation/presentation/pages/donations_list_page.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/donation_list_tile.dart';

/// Shared donations list. Used as Employee's "Donations Report" (all
/// donations, read-only), Approver's "Pending Approvals" (pending only,
/// with an Approve action) and "Approval History" (approved only).
class DonationsListPage extends StatefulWidget {
  final String title;
  final Color color;
  final DonationStatus? statusFilter;
  final bool showApproveAction;

  const DonationsListPage({
    super.key,
    required this.title,
    required this.color,
    this.statusFilter,
    this.showApproveAction = false,
  });

  @override
  State<DonationsListPage> createState() => _DonationsListPageState();
}

class _DonationsListPageState extends State<DonationsListPage> {
  late List<MockDonation> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.statusFilter == null
        ? List.of(MockData.donations)
        : MockData.donationsByStatus(widget.statusFilter!);
  }

  void _approve(int index) {
    final donation = _items[index];
    setState(() => _items.removeAt(index));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Approved ${donation.receiptNumber} — receipt sent to donor (demo)')));
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _items.fold<int>(0, (sum, d) => sum + d.amount);

    return AppScaffold(
      title: widget.title,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            color: widget.color.withValues(alpha: 0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_items.length} receipt(s)', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('₹$totalAmount', style: TextStyle(fontWeight: FontWeight.bold, color: widget.color)),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('No records found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      return DonationListTile(
                        donation: _items[i],
                        trailingAction: widget.showApproveAction
                            ? ElevatedButton(
                                onPressed: () => _approve(i),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.color,
                                  minimumSize: const Size(0, 32),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                child: const Text('Approve', style: TextStyle(color: Colors.white, fontSize: 12)),
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
