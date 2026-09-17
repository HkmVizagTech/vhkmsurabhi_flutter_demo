// lib/features/shared/donor/presentation/pages/donor_lookup_page.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/donor_list_tile.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_detail_page.dart';

class DonorLookupPage extends StatefulWidget {
  final Color color;

  const DonorLookupPage({super.key, required this.color});

  @override
  State<DonorLookupPage> createState() => _DonorLookupPageState();
}

class _DonorLookupPageState extends State<DonorLookupPage> {
  final _controller = TextEditingController();
  List<MockDonor> _results = MockData.donors;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    setState(() => _results = MockData.searchDonors(value));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Donor Lookup',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
