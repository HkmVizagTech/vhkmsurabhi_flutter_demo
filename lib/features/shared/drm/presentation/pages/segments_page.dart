// lib/features/shared/drm/presentation/pages/segments_page.dart
//
// DRM Segments: tier summary cards (count + lifetime giving) that double
// as filters, extra filters (tag, city, lifetime band, birthday month,
// festival), the matching donors, bulk "follow-up for all" and named saved
// segments. A preacher only ever segments their own donors.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_drm.dart';
import 'package:surabhi/core/mock/mock_festivals.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/amount_bars.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/donor_list_tile.dart';
import 'package:surabhi/features/shared/donor/presentation/pages/donor_detail_page.dart';
import 'package:surabhi/features/shared/drm/presentation/widgets/drm_sheets.dart';

const List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

class SegmentsPage extends StatefulWidget {
  // null = all donors (admin / employee)
  final String? preacherCode;
  final Color color;

  const SegmentsPage({super.key, this.preacherCode, required this.color});

  @override
  State<SegmentsPage> createState() => _SegmentsPageState();
}

class _SegmentsPageState extends State<SegmentsPage> {
  DonorTier? _tier;
  String? _tagId;
  String? _city;
  LifetimeBand _band = LifetimeBand.any;
  int? _birthdayMonth;
  String? _festival;

  SegmentFilter get _filter => SegmentFilter(
        tier: _tier,
        tagId: _tagId,
        city: _city,
        lifetimeBand: _band,
        birthdayMonth: _birthdayMonth,
        festivalCode: _festival,
      );

  void _apply(SegmentFilter f) {
    setState(() {
      _tier = f.tier;
      _tagId = f.tagId;
      _city = f.city;
      _band = f.lifetimeBand;
      _birthdayMonth = f.birthdayMonth;
      _festival = f.festivalCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = DrmStore.instance;
    return AppScaffold(
      title: 'Segments',
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final donors = widget.preacherCode == null ? MockData.donors : MockData.donorsFor(widget.preacherCode!);
          final insights = donors.map((d) => DonorInsights.of(d)).toList();
          final filter = _filter;
          final results = insights.where((i) => filter.matches(i, store.tagIdsFor(i.donor.id))).toList()
            ..sort((a, b) => b.lifetime.compareTo(a.lifetime));
          final cities = donors.map((d) => d.city).toSet().toList()..sort();
          final saved = store.segmentsFor(widget.preacherCode);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.preacherCode != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('Only donors enrolled by you (${widget.preacherCode})', style: TextStyle(fontSize: 12, color: widget.color)),
                ),
              if (saved.isNotEmpty) ...[
                const SectionTitle('Saved segments'),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: saved
                      .map((s) => InputChip(
                            avatar: const Icon(Icons.bookmark, size: 16, color: AppColors.gold),
                            label: Text(s.name),
                            onPressed: () => _apply(s.filter),
                            onDeleted: () => store.deleteSegment(s),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              const SectionTitle('Tiers'),
              _TierCards(insights: insights, selected: _tier, onSelected: (t) => setState(() => _tier = t)),
              const SizedBox(height: 12),
              _filters(cities),
              const SizedBox(height: 8),
              SectionTitle('${results.length} donor(s)'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: results.isEmpty ? null : () => _bulkFollowUp(results.map((i) => i.donor).toList()),
                    icon: const Icon(Icons.playlist_add_check, size: 18),
                    label: const Text('Follow-up for all'),
                  ),
                  OutlinedButton.icon(
                    onPressed: filter.isEmpty ? null : () => _saveSegment(filter),
                    icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                    label: const Text('Save segment'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (results.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No donors match these filters', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                ),
              ...results.map((i) => DonorListTile(
                    donor: i.donor,
                    color: widget.color,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DonorDetailPage(donor: i.donor, color: widget.color)),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _filters(List<String> cities) {
    final store = DrmStore.instance;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Filters', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink))),
                if (!_filter.isEmpty)
                  TextButton(onPressed: () => _apply(const SegmentFilter()), child: const Text('Clear all')),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Tag', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: store.tags
                  .map((t) => FilterChip(
                        label: Text(t.name, style: const TextStyle(fontSize: 12)),
                        selected: _tagId == t.id,
                        visualDensity: VisualDensity.compact,
                        selectedColor: t.color.withValues(alpha: 0.18),
                        checkmarkColor: t.color,
                        onSelected: (v) => setState(() => _tagId = v ? t.id : null),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            const Text('Lifetime giving', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: LifetimeBand.values
                  .map((b) => ChoiceChip(
                        label: Text(b.label, style: const TextStyle(fontSize: 12)),
                        selected: _band == b,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) => setState(() => _band = b),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey('city-$_city'),
              initialValue: _city,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city), isDense: true),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Any city')),
                ...cities.map((c) => DropdownMenuItem<String?>(value: c, child: Text(c))),
              ],
              onChanged: (v) => setState(() => _city = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              key: ValueKey('month-$_birthdayMonth'),
              initialValue: _birthdayMonth,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Birthday month', prefixIcon: Icon(Icons.cake_outlined), isDense: true),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Any month')),
                for (var m = 1; m <= 12; m++) DropdownMenuItem<int?>(value: m, child: Text(_months[m - 1])),
              ],
              onChanged: (v) => setState(() => _birthdayMonth = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey('festival-$_festival'),
              initialValue: _festival,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Festival participated', prefixIcon: Icon(Icons.celebration_outlined), isDense: true),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Any / none')),
                ...mockFestivals.map((f) => DropdownMenuItem<String?>(value: f.festivalCode, child: Text(f.name, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (v) => setState(() => _festival = v),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bulkFollowUp(List<MockDonor> donors) async {
    final n = await showBulkFollowUpSheet(context, donors: donors);
    if (n != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$n follow-up(s) created - see My Follow-ups')));
    }
  }

  Future<void> _saveSegment(SegmentFilter filter) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save segment'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Segment name', hintText: 'e.g. Lapsed festival regulars'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    DrmStore.instance.saveSegment(name, filter, preacherCode: widget.preacherCode);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved "$name"')));
  }
}

/// Two per row at any width; each shows the tier's donor count and their
/// combined lifetime giving, and toggles that tier as a filter.
class _TierCards extends StatelessWidget {
  final List<DonorInsights> insights;
  final DonorTier? selected;
  final ValueChanged<DonorTier?> onSelected;

  const _TierCards({required this.insights, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (constraints.maxWidth - 10) / 2;
        Widget card({required String label, required String rule, required int count, required int total, required Color color, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
          return SizedBox(
            width: w,
            child: Material(
              color: isSelected ? color.withValues(alpha: 0.12) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.25), width: isSelected ? 2 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 18, color: color),
                          const SizedBox(width: 6),
                          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color))),
                          Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(inr(total), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                      Text(rule, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final byTier = <DonorTier, List<DonorInsights>>{};
        for (final i in insights) {
          byTier.putIfAbsent(tierOf(i), () => []).add(i);
        }
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            card(
              label: 'All',
              rule: 'Every donor in scope',
              count: insights.length,
              total: insights.fold(0, (s, i) => s + i.lifetime),
              color: AppColors.ink,
              icon: Icons.groups,
              isSelected: selected == null,
              onTap: () => onSelected(null),
            ),
            ...DonorTier.values.map((t) {
              final list = byTier[t] ?? const [];
              return card(
                label: t.label,
                rule: t.rule,
                count: list.length,
                total: list.fold(0, (s, i) => s + i.lifetime),
                color: t.color,
                icon: t.icon,
                isSelected: selected == t,
                onTap: () => onSelected(selected == t ? null : t),
              );
            }),
          ],
        );
      },
    );
  }
}
