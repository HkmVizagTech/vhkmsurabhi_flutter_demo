// lib/features/volunteer/dashboard/presentation/pages/volunteer_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/dashboard_action_card.dart';
import 'package:surabhi/core/widgets/dashboard_header.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_lookup_page.dart';
import 'package:surabhi/features/volunteer/qr/presentation/pages/qr_scanner_page.dart';

class VolunteerDashboard extends StatelessWidget {
  const VolunteerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const color = AppColors.volunteerColor;
    final firstName = context.select<AuthBloc, String>(
      (bloc) => bloc.state is AuthAuthenticated ? (bloc.state as AuthAuthenticated).user.firstName ?? 'Volunteer' : 'Volunteer',
    );

    return AppScaffold(
      title: 'Volunteer Dashboard',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DashboardHeader(
            greeting: 'Hare Krishna, $firstName',
            subtitle: 'Look up donors and scan QR codes on the go.',
            icon: Icons.volunteer_activism,
            color: color,
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              DashboardActionCard(
                icon: Icons.person_search,
                title: 'Search Donor',
                subtitle: 'Search donor records',
                color: color,
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const DonorLookupPage(color: color))),
              ),
              DashboardActionCard(
                icon: Icons.qr_code_scanner,
                title: 'QR Code Scanner',
                subtitle: 'Quick donor check-in',
                color: color,
                onTap: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrScannerPage())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
