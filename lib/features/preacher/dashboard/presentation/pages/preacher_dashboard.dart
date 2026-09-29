// lib/features/preacher/dashboard/presentation/pages/preacher_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_drm.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/features/shared/approvals/presentation/pages/my_requests_page.dart';
import 'package:surabhi/features/shared/drm/presentation/pages/my_follow_ups_page.dart';
import 'package:surabhi/features/shared/drm/presentation/pages/patron_lifecycle_page.dart';
import 'package:surabhi/features/shared/drm/presentation/pages/segments_page.dart';
import 'package:surabhi/features/preacher/donor_care/presentation/pages/donor_care_page.dart';
import 'package:surabhi/features/shared/festival/presentation/pages/festivals_page.dart';
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

List<AppBottomNavItem> _preacherBottomNav(BuildContext context, int current) {
  const color = PreacherDashboard.color;
  return [
    AppBottomNavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
    ),
    AppBottomNavItem(
      icon: Icons.receipt_long,
      label: 'Make Receipt',
      onTap: () => navigateToBottomNavTab(
        context,
        RecordDonationPage(
          title: 'Make Receipt',
          color: color,
          enrolledByFilter: kCurrentPreacherCode,
          bottomNavItems: _preacherBottomNav(context, 1),
          bottomNavIndex: 1,
        ),
      ),
    ),
    AppBottomNavItem(
      icon: Icons.person_search,
      label: 'Search Donor',
      onTap: () => navigateToBottomNavTab(
        context,
        DonorLookupPage(
          color: color,
          enrolledByFilter: kCurrentPreacherCode,
          bottomNavItems: _preacherBottomNav(context, 2),
          bottomNavIndex: 2,
        ),
      ),
    ),
    const AppBottomNavItem.more(),
  ];
}

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
      bottomNavItems: _preacherBottomNav(context, 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DashboardHeader(
            greeting: 'Hare Krishna, $firstName',
            subtitle: 'Record sevas for your donors, quick and easy.',
            icon: Icons.school,
            color: color,
          ),
          const SizedBox(height: 16),
          const _FollowUpsCard(),
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
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TrustWiseChart(data: stats.trustWise, accentColor: color),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Monthly Trend', color: color),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: MonthlyTrendChart(data: stats.monthlyTrend, color: color),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Quick Actions', color: color),
          const SizedBox(height: 10),
          GridView(
            gridDelegate: kActionCardGridDelegate,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
                onTap: () => navigateToBottomNavTab(
                  context,
                  DonorLookupPage(
                    color: color,
                    enrolledByFilter: kCurrentPreacherCode,
                    bottomNavItems: _preacherBottomNav(context, 2),
                    bottomNavIndex: 2,
                  ),
                ),
              ),
              DashboardActionCard(
                icon: Icons.receipt_long,
                title: 'Make Receipt',
                subtitle: 'Record a seva & generate receipt',
                color: color,
                onTap: () => navigateToBottomNavTab(
                  context,
                  RecordDonationPage(
                    title: 'Make Receipt',
                    color: color,
                    enrolledByFilter: kCurrentPreacherCode,
                    bottomNavItems: _preacherBottomNav(context, 1),
                    bottomNavIndex: 1,
                  ),
                ),
              ),
              DashboardActionCard(
                icon: Icons.favorite_outline,
                title: 'Donor Care',
                subtitle: 'Lapsed, birthdays & follow-ups',
                color: color,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DonorCarePage())),
              ),
              DashboardActionCard(
                icon: Icons.celebration_outlined,
                title: 'Festivals',
                subtitle: 'Collections by festival code',
                color: color,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FestivalsPage(preacherCode: kCurrentPreacherCode)),
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
          const SizedBox(height: 20),
          const _SectionTitle('Relationships & Approvals', color: color),
          const SizedBox(height: 10),
          // Counts follow the DRM / approval stores live
          ListenableBuilder(
            listenable: Listenable.merge([DrmStore.instance, ApprovalStore.instance]),
            builder: (context, _) {
              final openFollowUps = DrmStore.instance.openTaskCount(kCurrentPreacherCode);
              final pendingRequests = ApprovalStore.instance.requestsBy(kCurrentPreacherCode).where((r) => r.isPending).length;
              return GridView(
                gridDelegate: kActionCardGridDelegate,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DashboardActionCard(
                    icon: Icons.task_alt,
                    title: 'My Follow-ups',
                    subtitle: '$openFollowUps open · overdue, today, upcoming',
                    color: color,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyFollowUpsPage(preacherCode: kCurrentPreacherCode, color: color)),
                    ),
                  ),
                  DashboardActionCard(
                    icon: Icons.outbox_outlined,
                    title: 'My Requests',
                    subtitle: '$pendingRequests waiting for approval',
                    color: color,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyRequestsPage(color: color)),
                    ),
                  ),
                  DashboardActionCard(
                    icon: Icons.filter_alt_outlined,
                    title: 'Segments',
                    subtitle: 'Tiers, tags & bulk follow-ups',
                    color: color,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SegmentsPage(preacherCode: kCurrentPreacherCode, color: color)),
                    ),
                  ),
                  DashboardActionCard(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Patron Lifecycle',
                    subtitle: 'Instalments, pujas & publications',
                    color: color,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatronLifecyclePage(preacherCode: kCurrentPreacherCode, color: color)),
                    ),
                  ),
                ],
              );
            },
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

// "Who should I call today?" - counts from the same rules as Donor Care,
// each opening that tab's list.
class _FollowUpsCard extends StatelessWidget {
  const _FollowUpsCard();

  @override
  Widget build(BuildContext context) {
    final all = DonorInsights.forPreacher(kCurrentPreacherCode);
    final lapsed = all.where((i) => i.status == CareStatus.lapsed).length;
    final birthdays = all.where((i) => i.daysToBirthday != null && i.daysToBirthday! <= 7).length;
    final never = all.where((i) => i.status == CareStatus.never).length;

    Widget item(String count, String label, IconData icon, Color color, {VoidCallback? onTap}) {
      final body = Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.ink)),
        ],
      );
      return Expanded(
        child: onTap == null ? body : InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: body),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DonorCarePage())),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.favorite, color: AppColors.deepRed, size: 18),
                  SizedBox(width: 6),
                  Expanded(child: Text('Today’s follow-ups', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink))),
                  Text('Open Donor Care', style: TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w700)),
                  Icon(Icons.chevron_right, color: AppColors.gold, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  item('$birthdays', 'Birthdays\nthis week', Icons.cake, AppColors.deepRed),
                  item('$lapsed', 'Lapsed\ndonors', Icons.hourglass_bottom, AppColors.warningColor),
                  item('$never', 'Enrolled,\nnever gave', Icons.person_outline, AppColors.vaikunthamBlue),
                  // DRM tasks, not a Donor Care rule - opens My Follow-ups
                  ListenableBuilder(
                    listenable: DrmStore.instance,
                    builder: (context, _) => item(
                      '${DrmStore.instance.openTaskCount(kCurrentPreacherCode)}',
                      'Open\nfollow-ups',
                      Icons.task_alt,
                      AppColors.approverColor,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MyFollowUpsPage(preacherCode: kCurrentPreacherCode, color: AppColors.preacherColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
