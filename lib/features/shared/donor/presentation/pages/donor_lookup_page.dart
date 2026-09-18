// lib/features/shared/donor/presentation/pages/donor_lookup_page.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/widgets/app_bottom_nav_item.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/donor_list_tile.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_detail_page.dart';

class DonorLookupPage extends StatefulWidget {
  final Color color;
  // When set, only donors this devotee code enrolled are shown/searched -
  // used to keep a preacher scoped to their own donors, matching DCC's
  // Donor.EnrolledBy ownership (other preachers' donors/donations stay
  // hidden).
  final String? enrolledByFilter;
  final List<AppBottomNavItem>? bottomNavItems;
  final int bottomNavIndex;

  const DonorLookupPage({
    super.key,
    required this.color,
    this.enrolledByFilter,
    this.bottomNavItems,
    this.bottomNavIndex = 0,
  });

  @override
  State<DonorLookupPage> createState() => _DonorLookupPageState();
}

class _DonorLookupPageState extends State<DonorLookupPage> {
  final _controller = TextEditingController();
  late List<MockDonor> _results = _scoped(MockData.donors);

  List<MockDonor> _scoped(List<MockDonor> donors) {
    if (widget.enrolledByFilter == null) return donors;
    return donors.where((d) => d.enrolledByCode == widget.enrolledByFilter).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    setState(() => _results = _scoped(MockData.searchDonors(value)));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Search Donor',
      bottomNavItems: widget.bottomNavItems,
      bottomNavIndex: widget.bottomNavIndex,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.enrolledByFilter != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: widget.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Showing only donors enrolled by you',
                        style: TextStyle(fontSize: 12, color: widget.color),
                      ),
                    ),
                  ],
                ),
              ),
            TextField(
              controller: _controller,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search by name, mobile or Donor ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text('${_results.length} donor(s) found', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('No matching donors'))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, i) {
                        final donor = _results[i];
                        return DonorListTile(
                          donor: donor,
                          color: widget.color,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => DonorDetailPage(donor: donor, color: widget.color)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
