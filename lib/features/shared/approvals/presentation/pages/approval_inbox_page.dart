// lib/features/shared/approvals/presentation/pages/approval_inbox_page.dart
//
// Approval Inbox - the mobile side of DCC's hierarchy approvals. "Pending
// for me" holds requests whose current step the user can act on (approver:
// levels they are a member of; admin: any level, as an override), "All
// requests" everything, and "History" the closed ones.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/demo_identity.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_bottom_nav_item.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/shared/approvals/presentation/widgets/approval_request_card.dart';

class ApprovalInboxPage extends StatefulWidget {
  final Color color;
  final List<AppBottomNavItem>? bottomNavItems;
  final int bottomNavIndex;

  const ApprovalInboxPage({super.key, required this.color, this.bottomNavItems, this.bottomNavIndex = 0});

  @override
  State<ApprovalInboxPage> createState() => _ApprovalInboxPageState();
}

class _ApprovalInboxPageState extends State<ApprovalInboxPage> {
  String? _type; // null = all action types

  @override
  Widget build(BuildContext context) {
    final who = DemoIdentity.of(context);
    final store = ApprovalStore.instance;

    return DefaultTabController(
      length: 3,
      child: AppScaffold(
        title: 'Approval Inbox',
        bottomNavItems: widget.bottomNavItems,
        bottomNavIndex: widget.bottomNavIndex,
        body: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            bool typeOk(ApprovalRequest r) => _type == null || r.actionType == _type;
            final mine = store.pendingFor(who).where(typeOk).toList();
            final all = store.newestFirst.where(typeOk).toList();
            final history = all.where((r) => !r.isPending).toList()..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(gradient: AppColors.creamGradient),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_roleNote(who), style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _typeChip(null, 'All types'),
                            ...ApprovalActionType.all.map((t) => _typeChip(t, ApprovalActionType.shortLabel(t))),
                          ],
                        ),
                      ),
                      TabBar(
                        isScrollable: true,
                        labelColor: AppColors.ink,
                        indicatorColor: AppColors.gold,
                        unselectedLabelColor: Colors.grey.shade600,
                        tabAlignment: TabAlignment.start,
                        tabs: [
                          Tab(text: 'Pending for me (${mine.length})'),
                          Tab(text: 'All requests (${all.length})'),
                          Tab(text: 'History (${history.length})'),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _list(mine, who.isAdmin || who.isApprover ? 'Nothing waiting on you - all caught up' : 'Only DCC approvers and admins approve requests'),
                      _list(all, 'No requests yet'),
                      _list(history, 'No closed requests yet'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _roleNote(DemoIdentity who) {
    if (who.isAdmin) return 'Signed in as ${who.name}. You can act at any level - outside your own level it is recorded as an Admin override.';
    if (who.isApprover) return 'Signed in as ${who.name}. You act on steps for levels you are a member of.';
    return 'You can view requests here. Approvals are done by DCC approvers and admins.';
  }

  Widget _typeChip(String? type, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: _type == type,
        visualDensity: VisualDensity.compact,
        onSelected: (_) => setState(() => _type = type),
      ),
    );
  }

  Widget _list(List<ApprovalRequest> items, String empty) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(empty, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, i) => ApprovalRequestCard(request: items[i], color: widget.color),
    );
  }
}
