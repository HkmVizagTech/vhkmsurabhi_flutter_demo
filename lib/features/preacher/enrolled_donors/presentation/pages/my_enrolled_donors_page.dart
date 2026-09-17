// lib/features/preacher/enrolled_donors/presentation/pages/my_enrolled_donors_page.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/donor_list_tile.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_detail_page.dart';

class MyEnrolledDonorsPage extends StatelessWidget {
  const MyEnrolledDonorsPage({super.key});

  static const _color = AppColors.preacherColor;

  @override
  Widget build(BuildContext context) {
    // Demo: DCC ties donors to their preacher via Donor.EnrolledBy. Since the
    // dev-bypass user has no real devotee code, this shows donors enrolled
    // by 'ABRD' as a stand-in for "donors this preacher brought in".
    final myDonors = MockData.donors.where((d) => d.enrolledByCode == 'ABRD').toList();

    return AppScaffold(
      title: 'My Enrolled Donors',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('${myDonors.length} donor(s) enrolled by you', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          ...myDonors.map(
            (d) => DonorListTile(
              donor: d,
              color: _color,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DonorDetailPage(donor: d, color: _color)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
