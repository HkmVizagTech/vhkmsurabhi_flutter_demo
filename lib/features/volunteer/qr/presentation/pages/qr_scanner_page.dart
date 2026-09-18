// lib/features/volunteer/qr/presentation/pages/qr_scanner_page.dart
//
// DEMO: real camera-based QR scanning needs a device/browser camera and a
// scanning package (e.g. mobile_scanner), which can't be meaningfully
// exercised in this environment. This builds the real UI shell (viewfinder +
// manual fallback, which most scanner apps have anyway) with a "Simulate
// Scan" button standing in for an actual camera read.

import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_bottom_nav_item.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_detail_page.dart';

class QrScannerPage extends StatefulWidget {
  final List<AppBottomNavItem>? bottomNavItems;
  final int bottomNavIndex;

  const QrScannerPage({super.key, this.bottomNavItems, this.bottomNavIndex = 0});

  static const _color = AppColors.volunteerColor;

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final _manualController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void _lookup(String donorId) {
    final matches = MockData.donors.where((d) => d.id.toLowerCase() == donorId.trim().toLowerCase());
    if (matches.isEmpty) {
      setState(() => _error = 'No donor found for "$donorId"');
      return;
    }
    setState(() => _error = null);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DonorDetailPage(donor: matches.first, color: QrScannerPage._color)),
    );
  }

  void _simulateScan() {
    final donor = MockData.donors[DateTime.now().second % MockData.donors.length];
    _lookup(donor.id);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'QR Code Scanner',
      bottomNavItems: widget.bottomNavItems,
      bottomNavIndex: widget.bottomNavIndex,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('DEMO — tap "Simulate Scan" or enter a Donor ID manually.', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: QrScannerPage._color, width: 3),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_scanner, color: Colors.white54, size: 96),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _simulateScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: QrScannerPage._color,
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text('Simulate Scan (demo)', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 24),
            const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('OR')), Expanded(child: Divider())]),
            const SizedBox(height: 12),
            TextField(
              controller: _manualController,
              decoration: InputDecoration(
                labelText: 'Enter Donor ID manually',
                hintText: 'e.g. D1024',
                errorText: _error,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _lookup(_manualController.text),
                ),
              ),
              onSubmitted: _lookup,
            ),
          ],
        ),
      ),
    );
  }
}
