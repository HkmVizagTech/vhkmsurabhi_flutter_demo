// lib/core/widgets/donor_list_tile.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';

class DonorListTile extends StatelessWidget {
  final MockDonor donor;
  final Color color;
  final VoidCallback onTap;

  const DonorListTile({super.key, required this.donor, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(donor.name[0], style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        title: Row(
          children: [
            Flexible(child: Text(donor.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            if (donor.isPatron) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(4)),
                child: const Text('PATRON', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ],
        ),
        subtitle: Text('${donor.id} · ${donor.mobile} · ${donor.city}'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
