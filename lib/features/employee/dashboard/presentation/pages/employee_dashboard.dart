// lib/features/employee/dashboard/presentation/pages/employee_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/dashboard_action_card.dart';
import 'package:surabhi/core/widgets/dashboard_header.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/employee/donor/presentation/pages/add_donor_page.dart';
import 'package:surabhi/features/shared/donation/presentation/pages/donations_list_page.dart';
import 'package:surabhi/features/shared/donation/presentation/pages/record_donation_page.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_lookup_page.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const color = AppColors.employeeColor;
    final firstName = context.select<AuthBloc, String>(
      (bloc) => bloc.state is AuthAuthenticated ? (bloc.state as AuthAuthenticated).user.firstName ?? 'Employee' : 'Employee',
    );

    return AppScaffold(
      title: 'Employee Dashboard',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DashboardHeader(
            greeting: 'Welcome back, $firstName',
            subtitle: 'Here\'s what needs your attention today.',
            icon: Icons.work,
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
                icon: Icons.person_add,
                title: 'Add Donor',
                subtitle: 'Enroll a new donor',
                color: color,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddDonorPage())),
              ),
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
                icon: Icons.receipt_long,
                title: 'Record Donation',
                subtitle: 'Enter a new donation',
                color: color,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RecordDonationPage(title: 'Record Donation', color: color)),
                ),
              ),
              DashboardActionCard(
                icon: Icons.bar_chart,
                title: 'Donations Report',
                subtitle: 'View donation records',
                color: color,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DonationsListPage(title: 'Donations Report', color: color)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
