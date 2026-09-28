// lib/core/mock/donor_insights.dart
//
// Donor 360 / donor-care / festival numbers, computed with the same rules
// as DCC's new insight pages (sp_GetPreacherDonorCare, sp_GetDonorGifts,
// sp_GetFestivalCollections): cancelled receipts never count, "lapsed" =
// no gift in [lapsedMonths], financial year runs April-March.

import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_festivals.dart';
import 'package:surabhi/core/utils/number_to_words.dart';

enum CareStatus { active, lapsed, never }

int financialYearOf(DateTime d) => d.month <= 3 ? d.year - 1 : d.year;

String financialYearLabel(int fy) => '$fy-${((fy + 1) % 100).toString().padLeft(2, '0')}';

int? daysUntilBirthday(DateTime? dob, DateTime today) {
  if (dob == null) return null;
  var next = DateTime(today.year, dob.month, dob.day);
  if (next.isBefore(today)) next = DateTime(today.year + 1, dob.month, dob.day);
  return next.difference(today).inDays;
}

class DonorInsights {
  final MockDonor donor;
  final List<MockDonation> receipts; // newest first, including cancelled
  final int lifetime;
  final int giftCount;
  final int largestGift;
  final DateTime? firstGift;
  final DateTime? lastGift;
  final int? lastGiftAmount;
  final int thisFyAmount;
  final int lastFyAmount;
  final CareStatus status;
  final int? daysSinceLastGift;
  final int? daysToBirthday;
  final Map<int, int> byFinancialYear;
  final Map<String, int> byChannel;
  final Map<String, int> byFestival; // FestivalCode -> amount

  DonorInsights._({
    required this.donor,
    required this.receipts,
    required this.lifetime,
    required this.giftCount,
    required this.largestGift,
    required this.firstGift,
    required this.lastGift,
    required this.lastGiftAmount,
    required this.thisFyAmount,
    required this.lastFyAmount,
    required this.status,
    required this.daysSinceLastGift,
    required this.daysToBirthday,
    required this.byFinancialYear,
    required this.byChannel,
    required this.byFestival,
  });

  int get averageGift => giftCount == 0 ? 0 : lifetime ~/ giftCount;

  factory DonorInsights.of(MockDonor donor, {int lapsedMonths = 12}) {
    final today = MockData.today;
    final receipts = MockData.donationsForDonor(donor.id)..sort((a, b) => b.date.compareTo(a.date));
    final valid = receipts.where((r) => r.status != DonationStatus.cancelled).toList();

    final byFy = <int, int>{};
    final byChannel = <String, int>{};
    final byFestival = <String, int>{};
    for (final r in valid) {
      byFy.update(financialYearOf(r.date), (v) => v + r.amount, ifAbsent: () => r.amount);
      byChannel.update(r.channel, (v) => v + r.amount, ifAbsent: () => r.amount);
      if (r.festivalCode != null) {
        byFestival.update(r.festivalCode!, (v) => v + r.amount, ifAbsent: () => r.amount);
      }
    }

    final last = valid.isEmpty ? null : valid.first;
    final lapsedBefore = DateTime(today.year, today.month - lapsedMonths, today.day);
    final status = last == null
        ? CareStatus.never
        : (last.date.isBefore(lapsedBefore) ? CareStatus.lapsed : CareStatus.active);
    final fy = financialYearOf(today);

    return DonorInsights._(
      donor: donor,
      receipts: receipts,
      lifetime: valid.fold(0, (s, r) => s + r.amount),
      giftCount: valid.length,
      largestGift: valid.fold(0, (m, r) => r.amount > m ? r.amount : m),
      firstGift: valid.isEmpty ? null : valid.last.date,
      lastGift: last?.date,
      lastGiftAmount: last?.amount,
      thisFyAmount: byFy[fy] ?? 0,
      lastFyAmount: byFy[fy - 1] ?? 0,
      status: status,
      daysSinceLastGift: last == null ? null : today.difference(last.date).inDays,
      daysToBirthday: daysUntilBirthday(donor.dob, today),
      byFinancialYear: Map.fromEntries(byFy.entries.toList()..sort((a, b) => a.key.compareTo(b.key))),
      byChannel: byChannel,
      byFestival: byFestival,
    );
  }

  /// Every donor a preacher enrolled, with insights - backs Donor Care.
  static List<DonorInsights> forPreacher(String preacherCode, {int lapsedMonths = 12}) {
    return MockData.donorsFor(preacherCode).map((d) => DonorInsights.of(d, lapsedMonths: lapsedMonths)).toList();
  }
}

class FestivalSummary {
  final MockFestival festival;
  final List<MockDonation> receipts; // non-cancelled, newest first
  final int total;
  final Map<String, int> bySeva;
  final Map<String, int> byChannel;
  final int donorCount;

  FestivalSummary._(this.festival, this.receipts, this.total, this.bySeva, this.byChannel, this.donorCount);

  int get onlineAmount => byChannel.entries.where((e) => e.key != DonationChannel.dcc).fold(0, (s, e) => s + e.value);

  /// [preacherCode] scopes to that preacher's donors, like DCC does for a
  /// preacher login.
  factory FestivalSummary.of(MockFestival festival, {String? preacherCode}) {
    final donorIds = preacherCode == null ? null : MockData.donorsFor(preacherCode).map((d) => d.id).toSet();
    final receipts = MockData.donations
        .where((d) => d.festivalCode == festival.festivalCode && d.status != DonationStatus.cancelled)
        .where((d) => donorIds == null || donorIds.contains(d.donorId))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final bySeva = <String, int>{};
    final byChannel = <String, int>{};
    for (final r in receipts) {
      bySeva.update(r.sevaName ?? r.sevaCategory, (v) => v + r.amount, ifAbsent: () => r.amount);
      byChannel.update(r.channel, (v) => v + r.amount, ifAbsent: () => r.amount);
    }
    return FestivalSummary._(
      festival,
      receipts,
      receipts.fold(0, (s, r) => s + r.amount),
      bySeva,
      byChannel,
      receipts.map((r) => r.donorId).toSet().length,
    );
  }
}

/// Indian-grouped rupees, e.g. 125116 -> ₹1,25,116
String inr(int amount) => '₹${formatIndianAmount(amount)}';

String ddmmyyyy(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
