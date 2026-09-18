// lib/features/shared/donation/data/receipt_model.dart
//
// Mirrors DCC's Common/Receipt.cs, the POCO PDFService.GenerateDonationReceipt
// renders onto the actual PDF receipt.

class Receipt {
  final String receiptNumber;
  final DateTime receiptDate;
  final String trust;
  final String donorName;
  final String? address;
  final String? patronNumber;
  final String sevakName;
  final String mobile;
  final String? email;
  final String? pan;
  final int amount;
  final String modeOfPayment;
  final String? paymentRefNo;
  final DateTime? paymentDate;
  final String? bank;
  final String enrolledBy;
  final String? cdc;
  final String sevaName;
  final bool isReceiptAccounted;
  final bool isReceiptCancelled;
  final bool isTaxExemptionRequired;

  const Receipt({
    required this.receiptNumber,
    required this.receiptDate,
    required this.trust,
    required this.donorName,
    required this.sevakName,
    required this.mobile,
    required this.amount,
    required this.modeOfPayment,
    required this.enrolledBy,
    required this.sevaName,
    required this.isReceiptAccounted,
    required this.isReceiptCancelled,
    required this.isTaxExemptionRequired,
    this.address,
    this.patronNumber,
    this.email,
    this.pan,
    this.paymentRefNo,
    this.paymentDate,
    this.bank,
    this.cdc,
  });
}
