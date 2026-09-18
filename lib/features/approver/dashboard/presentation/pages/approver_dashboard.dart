// lib/features/approver/dashboard/presentation/pages/approver_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_bottom_nav_item.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/dashboard_action_card.dart';
import 'package:surabhi/core/widgets/dashboard_header.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/shared/donation/presentation/pages/donations_list_page.dart';

List<AppBottomNavItem> _approverBottomNav(BuildContext context, int current) {
  const color = AppColors.approverColor;
  return [
    AppBottomNavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
    ),
    AppBottomNavItem(
      icon: Icons.pending_actions,
      label: 'Pending',
      onTap: () => navigateToBottomNavTab(
        context,
        DonationsListPage(
          title: 'Pending Approvals',
          color: color,
          statusFilter: DonationStatus.pending,
          showApproveAction: true,
          bottomNavItems: _approverBottomNav(context, 1),
          bottomNavIndex: 1,
        ),
      ),
    ),
    AppBottomNavItem(
      icon: Icons.history,
      label: 'History',
      onTap: () => navigateToBottomNavTab(
        context,
        DonationsListPage(
          title: 'Approval History',
          color: color,
          statusFilter: DonationStatus.approved,
          bottomNavItems: _approverBottomNav(context, 2),
          bottomNavIndex: 2,
        ),
      ),
    ),
    const AppBottomNavItem.more(),
  ];
}

class ApproverDashboard extends StatelessWidget {
  const ApproverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const color = AppColors.approverColor;
    final firstName = context.select<AuthBloc, String>(
      (bloc) => bloc.state is AuthAuthenticated ? (bloc.state as AuthAuthenticated).user.firstName ?? 'Approver' : 'Approver',
    );

    return AppScaffold(
      title: 'Approver Dashboard',
      bottomNavItems: _approverBottomNav(context, 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DashboardHeader(
            greeting: 'Welcome back, $firstName',
            subtitle: 'Donation receipts waiting on your review.',
            icon: Icons.check_circle,
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
                icon: Icons.pending_actions,
                title: 'Pending Approvals',
                subtitle: 'Receipts to account',
                color: color,
                onTap: () => navigateToBottomNavTab(
                  context,
                  DonationsListPage(
                    title: 'Pending Approvals',
                    color: color,
                    statusFilter: DonationStatus.pending,
                    showApproveAction: true,
                    bottomNavItems: _approverBottomNav(context, 1),
                    bottomNavIndex: 1,
                  ),
                ),
              ),
              DashboardActionCard(
                icon: Icons.history,
                title: 'Approval History',
                subtitle: 'Previously accounted',
                color: color,
                onTap: () => navigateToBottomNavTab(
                  context,
                  DonationsListPage(
                    title: 'Approval History',
                    color: color,
                    statusFilter: DonationStatus.approved,
                    bottomNavItems: _approverBottomNav(context, 2),
                    bottomNavIndex: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
