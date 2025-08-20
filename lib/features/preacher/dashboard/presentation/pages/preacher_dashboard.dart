// lib/features/preacher/dashboard/presentation/pages/preacher_dashboard.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class PreacherDashboard extends StatelessWidget {
  const PreacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Preacher Dashboard',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 64, color: AppColors.preacherColor),
            const SizedBox(height: 16),
            const Text('Welcome to Preacher Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Preacher features coming soon...',
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
