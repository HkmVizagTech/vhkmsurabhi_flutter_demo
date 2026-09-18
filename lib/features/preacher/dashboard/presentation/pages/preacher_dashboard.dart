// lib/features/preacher/dashboard/presentation/pages/preacher_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_bottom_nav_item.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/dashboard_action_card.dart';
import 'package:surabhi/core/widgets/dashboard_header.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/employee/donor/presentation/pages/add_donor_page.dart';
import 'package:surabhi/features/preacher/enrolled_donors/presentation/pages/my_enrolled_donors_page.dart';
import 'package:surabhi/features/preacher/payment_link/presentation/pages/send_payment_link_page.dart';
import 'package:surabhi/features/shared/donation/presentation/pages/record_donation_page.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_lookup_page.dart';
import 'package:surabhi/features/preacher/stats/data/preacher_stats_mock_data.dart';
import 'package:surabhi/features/preacher/stats/presentation/widgets/monthly_trend_chart.dart';
import 'package:surabhi/features/preacher/stats/presentation/widgets/stat_tile.dart';
import 'package:surabhi/features/preacher/stats/presentation/widgets/trust_wise_chart.dart';

class PreacherDashboard extends StatelessWidget {
  const PreacherDashboard({super.key});

  static const color = AppColors.preacherColor;

  @override
  Widget build(BuildContext context) {
    final firstName = context.select<AuthBloc, String>(
      (bloc) => bloc.state is AuthAuthenticated ? (bloc.state as AuthAuthenticated).user.firstName ?? 'Preacher' : 'Preacher',
    );
    final stats = PreacherStats.mock();

    return AppScaffold(
      title: 'Preacher Dashboard',
      bottomNavItems: [
        const AppBottomNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        AppBottomNavItem(
          icon: Icons.receipt_long,
          label: 'Make Receipt',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RecordDonationPage(title: 'Make Receipt', color: color)),
          ),
        ),
        AppBottomNavItem(
          icon: Icons.person_search,
          label: 'Search Donor',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DonorLookupPage(color: color, enrolledByFilter: kCurrentPreacherCode)),
          ),
        ),
        const AppBottomNavItem.more(),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DashboardHeader(
            greeting: 'Hare Krishna, $firstName',
            subtitle: 'Record sevas for your donors, quick and easy.',
            icon: Icons.school,
            color: color,
          ),
          const SizedBox(height: 20),
          const _SectionTitle('My Impact', color: color),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              StatTile(label: 'Total Donations', value: '${stats.totalDonations}', icon: Icons.volunteer_activism, color: color),
              StatTile(label: 'Total Patrons', value: '${stats.totalPatrons}', icon: Icons.workspace_premium, color: color),
              StatTile(label: 'This Month', value: '₹${_short(stats.monthAmount)}', icon: Icons.calendar_month, color: color),
              StatTile(label: 'Today', value: '₹${_short(stats.todayAmount)}', icon: Icons.today, color: color),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Donations by Trust', color: color),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TrustWiseChart(data: stats.trustWise, accentColor: color),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Monthly Trend', color: color),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: MonthlyTrendChart(data: stats.monthlyTrend, color: color),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Quick Actions', color: color),
          const SizedBox(height: 10),
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
                subtitle: 'Enroll a new donor/patron',
                color: color,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddDonorPage(title: 'Add Donor', color: color)),
                ),
              ),
              DashboardActionCard(
                icon: Icons.person_search,
                title: 'Search Donor',
                subtitle: 'Your enrolled donors only',
                color: color,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DonorLookupPage(color: color, enrolledByFilter: kCurrentPreacherCode)),
                ),
              ),
              DashboardActionCard(
                icon: Icons.receipt_long,
                title: 'Make Receipt',
                subtitle: 'Record a seva & generate receipt',
                color: color,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RecordDonationPage(title: 'Make Receipt', color: color)),
                ),
              ),
              DashboardActionCard(
                icon: Icons.groups,
                title: 'My Enrolled Donors',
                subtitle: 'Donors you\'ve brought in',
                color: color,
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const MyEnrolledDonorsPage())),
              ),
              DashboardActionCard(
                icon: Icons.link,
                title: 'Send Payment Link',
                subtitle: 'Auto-verify & email receipt',
                color: color,
                onTap: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SendPaymentLinkPage())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _short(int amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return '$amount';
  }

}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle(this.title, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 18, color: color),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
