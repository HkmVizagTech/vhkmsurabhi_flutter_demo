// lib/features/preacher/stats/data/preacher_stats_mock_data.dart
//
// Mock data standing in for a real "preacher donation stats" API endpoint,
// which doesn't exist yet (DCC has no REST API for the Flutter app to call).
// Shaped around DCC's real schema so wiring in live data later is a
// drop-in replacement: AccountType (HKMV/HKMI/TSC = "trusts"), Donation
// (ReceiptDate/Amount for day/month trends), Patron*Donor tables (patron
// counts per trust).

class TrustStats {
  final String trustName;
  final int donationCount;
  final int amount;

  const TrustStats({required this.trustName, required this.donationCount, required this.amount});
}

class MonthlyPoint {
  final String monthLabel;
  final int amount;

  const MonthlyPoint({required this.monthLabel, required this.amount});
}

class DailyPoint {
  final String dayLabel;
  final int amount;

  const DailyPoint({required this.dayLabel, required this.amount});
}

class PreacherStats {
  final int totalDonations;
  final int totalAmount;
  final int todayCount;
  final int todayAmount;
  final int monthCount;
  final int monthAmount;
  final int totalPatrons;
  final List<TrustStats> trustWise;
  final List<MonthlyPoint> monthlyTrend;
  final List<DailyPoint> dailyTrend;

  const PreacherStats({
    required this.totalDonations,
    required this.totalAmount,
    required this.todayCount,
    required this.todayAmount,
    required this.monthCount,
    required this.monthAmount,
    required this.totalPatrons,
    required this.trustWise,
    required this.monthlyTrend,
    required this.dailyTrend,
  });

  /// Standing in for a real GET /preachers/{id}/stats call.
  static PreacherStats mock() {
    return const PreacherStats(
      totalDonations: 214,
      totalAmount: 1842500,
      todayCount: 3,
      todayAmount: 12500,
      monthCount: 28,
      monthAmount: 236800,
      totalPatrons: 17,
      trustWise: [
        TrustStats(trustName: 'HKMV', donationCount: 142, amount: 1120000),
        TrustStats(trustName: 'HKMI', donationCount: 51, amount: 512500),
        TrustStats(trustName: 'TSC', donationCount: 21, amount: 210000),
      ],
      monthlyTrend: [
        MonthlyPoint(monthLabel: 'Apr', amount: 148000),
        MonthlyPoint(monthLabel: 'May', amount: 162500),
        MonthlyPoint(monthLabel: 'Jun', amount: 121000),
        MonthlyPoint(monthLabel: 'Jul', amount: 198400),
        MonthlyPoint(monthLabel: 'Aug', amount: 175600),
        MonthlyPoint(monthLabel: 'Sep', amount: 236800),
      ],
      dailyTrend: [
        DailyPoint(dayLabel: 'Mon', amount: 8200),
        DailyPoint(dayLabel: 'Tue', amount: 15400),
        DailyPoint(dayLabel: 'Wed', amount: 6100),
        DailyPoint(dayLabel: 'Thu', amount: 19800),
        DailyPoint(dayLabel: 'Fri', amount: 11200),
        DailyPoint(dayLabel: 'Sat', amount: 24600),
        DailyPoint(dayLabel: 'Sun', amount: 12500),
      ],
    );
  }
}
