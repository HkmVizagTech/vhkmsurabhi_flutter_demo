// lib/features/volunteer/dashboard/presentation/pages/volunteer_dashboard.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class VolunteerDashboard extends StatelessWidget {
  const VolunteerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Volunteer Dashboard',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.volunteer_activism, size: 64, color: AppColors.volunteerColor),
            const SizedBox(height: 16),
            const Text('Welcome to Volunteer Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Volunteer features coming soon...',
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
