// lib/features/shared/donor/presentation/pages/donor_detail_page.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/donation_list_tile.dart';

class DonorDetailPage extends StatelessWidget {
  final MockDonor donor;
  final Color color;

  const DonorDetailPage({super.key, required this.donor, required this.color});

  @override
  Widget build(BuildContext context) {
    final donations = MockData.donationsForDonor(donor.id);
    final total = donations.fold<int>(0, (sum, d) => sum + (d.status == DonationStatus.cancelled ? 0 : d.amount));

    return AppScaffold(
      title: donor.name,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Text(donor.name[0], style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(child: Text(donor.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                if (donor.isPatron) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(6)),
                                    child: const Text('PATRON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ],
                              ],
                            ),
                            Text(donor.id, style: TextStyle(color: color)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  _infoRow(Icons.phone, donor.mobile),
                  if (donor.email != null) _infoRow(Icons.email, donor.email!),
                  if (donor.address != null) _infoRow(Icons.home_outlined, donor.address!),
                  _infoRow(Icons.location_city, donor.city),
                  if (donor.pan != null) _infoRow(Icons.badge_outlined, 'PAN: ${donor.pan}'),
                  _infoRow(Icons.person_pin, 'Enrolled by ${donor.enrolledByCode}'),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total donated (₹$total)', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${donations.length} receipts'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Donation History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (donations.isEmpty) const Text('No donations recorded yet.'),
          ...donations.map((d) => DonationListTile(donation: d)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
