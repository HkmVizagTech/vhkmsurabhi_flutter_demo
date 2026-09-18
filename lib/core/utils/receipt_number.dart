// lib/core/utils/receipt_number.dart
//
// Mirrors DCC's sp_InsertDonation receipt-number format:
//   {AccountTypeName}|{FinancialYear}|{AutoFillData}|{SequenceNumber}
// e.g. "HKMV|2026|VSH|251", "HKMI|2026|D/VSP|48", "TSC|2026|D/TSC|9".
//
// DCC's per-trust, per-financial-year running sequence lives in
// dbo.ReceiptTracker, which only the real backend can maintain; this app
// has no such sequence, so the last segment here is a demo stand-in.

const Map<String, String> _autoFillDataByTrust = {'HKMV': 'VSH', 'HKMI': 'D/VSP', 'TSC': 'D/TSC'};

/// DCC's financial year runs April -> March, stored as the starting year
/// (e.g. a donation on 15 Feb 2026 falls in FY 2025).
int financialYearFor(DateTime date) => date.month >= 4 ? date.year : date.year - 1;

String buildReceiptNumber({required String trust, required DateTime date, required int sequence}) {
  final autoFillData = _autoFillDataByTrust[trust] ?? trust;
  return '$trust|${financialYearFor(date)}|$autoFillData|$sequence';
}
