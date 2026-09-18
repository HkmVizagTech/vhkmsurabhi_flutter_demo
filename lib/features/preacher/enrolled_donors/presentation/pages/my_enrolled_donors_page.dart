// lib/features/preacher/enrolled_donors/presentation/pages/my_enrolled_donors_page.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/donor_list_tile.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_detail_page.dart';

class MyEnrolledDonorsPage extends StatefulWidget {
  const MyEnrolledDonorsPage({super.key});

  @override
  State<MyEnrolledDonorsPage> createState() => _MyEnrolledDonorsPageState();
}

class _MyEnrolledDonorsPageState extends State<MyEnrolledDonorsPage> {
  static const _color = AppColors.preacherColor;
  bool _patronsOnly = false;

  @override
  Widget build(BuildContext context) {
    // DCC ties donors to their preacher via Donor.EnrolledBy - this page
    // (and every other preacher screen) only ever shows donors/donations
    // enrolled by the current preacher, never another preacher's.
    final allMine = MockData.donorsFor(kCurrentPreacherCode);
    final patronCount = allMine.where((d) => d.isPatron).length;
    final myDonors = _patronsOnly ? allMine.where((d) => d.isPatron).toList() : allMine;

    return AppScaffold(
      title: 'My Enrolled Donors',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${allMine.length} donor(s) enrolled by you · $patronCount patron(s)',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              FilterChip(
                label: const Text('Patrons only'),
                selected: _patronsOnly,
                onSelected: (v) => setState(() => _patronsOnly = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (myDonors.isEmpty) const Text('No donors match this filter.'),
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
