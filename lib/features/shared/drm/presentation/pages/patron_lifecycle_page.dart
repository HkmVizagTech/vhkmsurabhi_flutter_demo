// lib/features/shared/drm/presentation/pages/patron_lifecycle_page.dart
//
// Patron lifecycle, mirroring DCC's patron module: commitment vs received
// per patron, upcoming special pujas (anniversaries in the next 30 days)
// and publication entitlements still waiting to be dispatched. Scoped to a
// preacher's own patrons when [preacherCode] is set.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_drm.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/amount_bars.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/preacher/stats/presentation/widgets/stat_tile.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_detail_page.dart';
import 'package:surabhi/features/shared/drm/presentation/widgets/drm_sheets.dart';
import 'package:surabhi/features/shared/drm/presentation/widgets/patron_widgets.dart';

class PatronLifecyclePage extends StatefulWidget {
  // null = every patron (admin / employee / approver)
  final String? preacherCode;
  final Color color;

  const PatronLifecyclePage({super.key, this.preacherCode, required this.color});

  @override
  State<PatronLifecyclePage> createState() => _PatronLifecyclePageState();
}

class _PatronLifecyclePageState extends State<PatronLifecyclePage> {
  PatronPayStatus? _status;
  String? _trust;

  void _openDonor(String donorId) {
    final donor = MockData.donorById(donorId);
    if (donor == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DonorDetailPage(donor: donor, color: widget.color)));
  }

  @override
  Widget build(BuildContext context) {
    final store = DrmStore.instance;
    final today = MockData.today;
    return AppScaffold(
      title: 'Patron Lifecycle',
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final all = store.patronsScoped(widget.preacherCode)..sort((a, b) => b.pending.compareTo(a.pending));
          final shown = all.where((p) => (_status == null || p.payStatus == _status) && (_trust == null || p.trust == _trust)).toList();
          final committed = all.fold(0, (s, p) => s + p.committedAmount);
          final received = all.fold(0, (s, p) => s + p.received);
          final pending = all.fold(0, (s, p) => s + p.pending);

          final pujas = <(DateTime, SpecialPuja, PatronRecord)>[];
          for (final p in all) {
            for (final puja in p.pujas) {
              final next = puja.nextOn(today);
              if (next.difference(today).inDays <= 30) pujas.add((next, puja, p));
            }
          }
          pujas.sort((a, b) => a.$1.compareTo(b.$1));

          final toDispatch = <(PublicationEntitlement, PatronRecord)>[
            for (final p in all)
              for (final e in p.entitlements)
                if (e.isPendingOn(today)) (e, p),
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 112,
                ),
                children: [
                  StatTile(label: 'Patrons', value: '${all.length}', icon: Icons.workspace_premium, color: AppColors.goldenDark),
                  StatTile(label: 'Committed', value: inr(committed), icon: Icons.handshake_outlined, color: AppColors.vaikunthamBlue),
                  StatTile(label: 'Received', value: inr(received), icon: Icons.savings_outlined, color: AppColors.successColor),
                  StatTile(label: 'Pending', value: inr(pending), icon: Icons.pending_actions, color: AppColors.deepRed),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _chip('All', _status == null, () => setState(() => _status = null)),
                  ...PatronPayStatus.values.map((s) => _chip(
                        '${s.label} (${all.where((p) => p.payStatus == s).length})',
                        _status == s,
                        () => setState(() => _status = _status == s ? null : s),
                      )),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _chip('All trusts', _trust == null, () => setState(() => _trust = null)),
                  ...MockData.trusts.map((t) => _chip(t, _trust == t, () => setState(() => _trust = _trust == t ? null : t))),
                ],
              ),
              const SizedBox(height: 12),
              SectionTitle('Patrons (${shown.length})'),
              if (shown.isEmpty) Text('No patrons match', style: TextStyle(color: Colors.grey.shade600)),
              ...shown.map((p) => PatronCard(record: p, onTap: () => _openDonor(p.donorId))),
              const SizedBox(height: 8),
              SectionTitle('Upcoming special pujas (next 30 days)'),
              if (pujas.isEmpty) Text('None in the next 30 days', style: TextStyle(color: Colors.grey.shade600)),
              if (pujas.isNotEmpty)
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: pujas.map((x) {
                      final days = x.$1.difference(today).inDays;
                      final donor = MockData.donorById(x.$3.donorId);
                      return ListTile(
                        onTap: () => _openDonor(x.$3.donorId),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.cream,
                          child: Text('${x.$1.day}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(x.$2.occasion, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${donor?.name ?? x.$3.donorId}\n${ddmmyyyy(x.$1)} · ${days == 0 ? 'today' : 'in $days days'}'),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right_rounded),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16),
              SectionTitle('Publications pending dispatch (${toDispatch.length})'),
              if (toDispatch.isEmpty) Text('Everything has been dispatched', style: TextStyle(color: Colors.grey.shade600)),
              ...toDispatch.map((x) => _dispatchTile(x.$1, x.$2)),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      visualDensity: VisualDensity.compact,
      onSelected: (_) => onTap(),
    );
  }

  Widget _dispatchTile(PublicationEntitlement e, PatronRecord p) {
    final donor = MockData.donorById(p.donorId);
    final last = e.lastDispatch;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.menu_book_outlined, color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${e.item} (${e.language})', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                      Text(donor?.name ?? p.donorId, style: const TextStyle(fontSize: 13)),
                      Text(
                        e.isRecurring && last != null ? 'Monthly - last sent ${ddmmyyyy(last.date)}' : '${p.schemeName} · ${p.trust}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => showMarkDispatchedSheet(context, entitlement: e, donorName: donor?.name ?? p.donorId),
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
                label: const Text('Mark dispatched'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
