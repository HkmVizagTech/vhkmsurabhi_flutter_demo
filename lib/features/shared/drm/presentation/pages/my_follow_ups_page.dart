// lib/features/shared/drm/presentation/pages/my_follow_ups_page.dart
//
// DRM follow-up tasks split into Overdue / Today / Upcoming / Done. A
// preacher sees tasks on their own donors; admin/employee see everyone's.
// Ticking a task can log an outcome note on the donor's timeline.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_drm.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_detail_page.dart';
import 'package:surabhi/features/shared/drm/presentation/widgets/follow_up_tile.dart';

class MyFollowUpsPage extends StatelessWidget {
  // null = every donor's follow-ups (admin / employee)
  final String? preacherCode;
  final Color color;

  const MyFollowUpsPage({super.key, this.preacherCode, required this.color});

  @override
  Widget build(BuildContext context) {
    final store = DrmStore.instance;
    final today = MockData.today;
    return DefaultTabController(
      length: 4,
      child: AppScaffold(
        title: preacherCode == null ? 'Follow-ups' : 'My Follow-ups',
        body: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final tasks = store.tasksScoped(preacherCode);
            List<DrmTask> of(FollowUpBucket b) => tasks.where((t) => t.bucketOn(today) == b).toList();
            final overdue = of(FollowUpBucket.overdue)..sort((a, b) => a.dueDate.compareTo(b.dueDate));
            final todays = of(FollowUpBucket.today)..sort((a, b) => a.priority.index.compareTo(b.priority.index));
            final upcoming = of(FollowUpBucket.upcoming)..sort((a, b) => a.dueDate.compareTo(b.dueDate));
            final done = of(FollowUpBucket.done)
              ..sort((a, b) => (b.completedAt ?? b.dueDate).compareTo(a.completedAt ?? a.dueDate));

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(gradient: AppColors.creamGradient),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preacherCode == null ? 'Follow-ups across all donors' : 'Follow-ups on your donors',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      TabBar(
                        isScrollable: true,
                        labelColor: AppColors.ink,
                        indicatorColor: AppColors.gold,
                        unselectedLabelColor: Colors.grey.shade600,
                        tabAlignment: TabAlignment.start,
                        tabs: [
                          Tab(text: 'Overdue (${overdue.length})'),
                          Tab(text: 'Today (${todays.length})'),
                          Tab(text: 'Upcoming (${upcoming.length})'),
                          Tab(text: 'Done (${done.length})'),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _list(context, overdue, 'Nothing overdue - well done!'),
                      _list(context, todays, 'Nothing due today'),
                      _list(context, upcoming, 'No upcoming follow-ups. Add one from a donor\'s Donor 360 or from Segments.'),
                      _list(context, done, 'No completed follow-ups yet'),
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

  Widget _list(BuildContext context, List<DrmTask> items, String empty) {
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
      itemBuilder: (context, i) {
        final t = items[i];
        return FollowUpTile(
          task: t,
          onOpen: () {
            final donor = MockData.donorById(t.donorId);
            if (donor == null) return;
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => DonorDetailPage(donor: donor, color: color)));
          },
        );
      },
    );
  }
}
