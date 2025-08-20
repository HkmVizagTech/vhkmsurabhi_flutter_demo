// lib/features/approver/dashboard/presentation/pages/approver_dashboard.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class ApproverDashboard extends StatelessWidget {
  const ApproverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Approver Dashboard',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: AppColors.approverColor),
            const SizedBox(height: 16),
            const Text('Welcome to Approver Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Approver features coming soon...',
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
