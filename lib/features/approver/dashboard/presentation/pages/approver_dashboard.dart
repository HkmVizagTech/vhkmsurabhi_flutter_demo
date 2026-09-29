// lib/features/approver/dashboard/presentation/pages/approver_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/mock/demo_identity.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_bottom_nav_item.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/dashboard_action_card.dart';
import 'package:surabhi/core/widgets/dashboard_header.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/shared/approvals/presentation/pages/approval_inbox_page.dart';
import 'package:surabhi/features/shared/donation/presentation/pages/donations_list_page.dart';
import 'package:surabhi/features/shared/drm/presentation/pages/patron_lifecycle_page.dart';
import 'package:surabhi/features/shared/drm/presentation/pages/segments_page.dart';

// Bottom nav: the Approval Inbox is the approver's main tab; receipt
// accounting stays as "Pending", and History moved to the grid / drawer.
List<AppBottomNavItem> _approverBottomNav(BuildContext context, int current) {
  const color = AppColors.approverColor;
  return [
    AppBottomNavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
    ),
    AppBottomNavItem(
      icon: Icons.approval,
      label: 'Inbox',
      onTap: () => navigateToBottomNavTab(
        context,
        ApprovalInboxPage(color: color, bottomNavItems: _approverBottomNav(context, 1), bottomNavIndex: 1),
      ),
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
    final who = DemoIdentity.of(context);

    return AppScaffold(
      title: 'Approver Dashboard',
      bottomNavItems: _approverBottomNav(context, 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DashboardHeader(
            greeting: 'Welcome back, $firstName',
            subtitle: 'Requests and receipts waiting on your review.',
            icon: Icons.check_circle,
            color: color,
          ),
          const SizedBox(height: 16),
          ListenableBuilder(
            listenable: ApprovalStore.instance,
            builder: (context, _) => _InboxCard(
              pending: ApprovalStore.instance.pendingFor(who),
              onTap: () => navigateToBottomNavTab(
                context,
                ApprovalInboxPage(color: color, bottomNavItems: _approverBottomNav(context, 1), bottomNavIndex: 1),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView(
            gridDelegate: kActionCardGridDelegate,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
                    bottomNavItems: _approverBottomNav(context, 2),
                    bottomNavIndex: 2,
                  ),
                ),
              ),
              DashboardActionCard(
                icon: Icons.history,
                title: 'Approval History',
                subtitle: 'Previously accounted',
                color: color,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DonationsListPage(
                      title: 'Approval History',
                      color: color,
                      statusFilter: DonationStatus.approved,
                    ),
                  ),
                ),
              ),
              DashboardActionCard(
                icon: Icons.filter_alt_outlined,
                title: 'Segments',
                subtitle: 'Donor tiers & tags',
                color: color,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SegmentsPage(color: color)),
                ),
              ),
              DashboardActionCard(
                icon: Icons.workspace_premium_outlined,
                title: 'Patron Lifecycle',
                subtitle: 'Commitments & dispatches',
                color: color,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PatronLifecyclePage(color: color)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Primary action: full-width Approval Inbox card with the pending count
/// and the oldest few requests waiting on this approver.
class _InboxCard extends StatelessWidget {
  final List<ApprovalRequest> pending;
  final VoidCallback onTap;

  const _InboxCard({required this.pending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const color = AppColors.approverColor;
    final preview = pending.take(3).toList();
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.approval, color: color),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Approval Inbox', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        Text('Cancellations, donor changes, patrons, high-value', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pending.isEmpty ? Colors.grey.shade400 : AppColors.deepRed,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text('${pending.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (preview.isEmpty)
                Text('Nothing waiting on you', style: TextStyle(fontSize: 13, color: Colors.grey.shade600))
              else
                ...preview.map(
                  (r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(ApprovalActionType.icon(r.actionType), size: 16, color: ApprovalActionType.color(r.actionType)),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${r.title} · ${r.donorName}', style: const TextStyle(fontSize: 13))),
                        const SizedBox(width: 6),
                        Text(timeAgo(r.requestedAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('Open inbox ›', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
