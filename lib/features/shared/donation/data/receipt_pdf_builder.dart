// lib/features/shared/donation/data/receipt_pdf_builder.dart
//
// Builds a PDF matching DCC's real receipt output (DCC/Common/PDFService.cs
// GenerateDonationReceipt renders the same content server-side with
// iTextSharp).
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/utils/number_to_words.dart';
import 'package:surabhi/features/shared/donation/data/receipt_model.dart';

Future<Uint8List> buildReceiptPdf(Receipt receipt) async {
  final profile = trustProfiles[receipt.trust];
  final logo = profile?.logoAsset != null ? await _loadImage(profile!.logoAsset!) : null;
  final stamp = profile != null ? await _loadImage(profile.stampAsset) : null;

  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Text(_statusText(receipt), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _statusColor(receipt)))),
            pw.SizedBox(height: 14),
            if (profile != null) _header(profile, receipt, logo),
            pw.Divider(),
            pw.Center(child: pw.Text('DONATION RECEIPT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline))),
            pw.SizedBox(height: 6),
            _kv('DR No.', receipt.receiptNumber, bold: true),
            _kv('Date', _formatDate(receipt.receiptDate), bold: true),
            pw.SizedBox(height: 10),
            _kv('Name of the Donor', receipt.donorName),
            if (receipt.address != null) _kv('Address', receipt.address!),
            if (receipt.patronNumber != null) _kv('Reference (Patronship No)', receipt.patronNumber!, bold: true),
            _kv('Sevak Name', receipt.sevakName),
            _kv('Mobile', receipt.mobile),
            _kv('Tax exemption Required', '${receipt.isTaxExemptionRequired ? 'YES' : 'NO'} (Under section 80G, of the Income Tax Act)', bold: true),
            if (receipt.email != null) _kv('E-mail', receipt.email!),
            if (receipt.pan != null) _kv('PAN', receipt.pan!),
            pw.SizedBox(height: 6),
            _kv('Rs.', '${formatIndianAmount(receipt.amount)} /-', bold: true),
            _kv('Rupees', '${amountToWords(receipt.amount)} ONLY', bold: true),
            pw.SizedBox(height: 6),
            _kv('by', receipt.modeOfPayment, bold: true),
            if (receipt.paymentRefNo != null) _kv('Reference No', receipt.paymentRefNo!),
            if (receipt.paymentDate != null) _kv('Date', _formatDate(receipt.paymentDate!)),
            if (receipt.bank != null) _kv('Bank', receipt.bank!),
            _kv('Enrolled by', receipt.enrolledBy, bold: true),
            if (receipt.cdc != null) _kv('CDC', receipt.cdc!, bold: true),
            _kv('Towards', receipt.sevaName, bold: true),
            pw.SizedBox(height: 10),
            pw.Text(
              '*Cheque Payment : Subject to realization. We do not accept anonymous donations.',
              style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
            ),
            pw.SizedBox(height: 10),
            if (_taxNoteText(receipt) != null) pw.Text(_taxNoteText(receipt)!, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            pw.Divider(),
            if (profile != null) _footer(profile, receipt, stamp),
            pw.SizedBox(height: 14),
            pw.Center(
              child: pw.Text(
                'Hare Krishna Hare Krishna Krishna Krishna Hare Hare\nHare Rama Hare Rama Rama Rama Hare Hare',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                '*This is an electronically generated receipt, hence does not require signature',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ),
          ],
        );
      },
    ),
  );
  return doc.save();
}

Future<pw.ImageProvider> _loadImage(String assetPath) async {
  final data = await rootBundle.load(assetPath);
  return pw.MemoryImage(data.buffer.asUint8List());
}

pw.Widget _header(TrustProfile profile, Receipt receipt, pw.ImageProvider? logo) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (logo != null) ...[pw.Image(logo, width: 48, height: 48, fit: pw.BoxFit.contain), pw.SizedBox(width: 10)],
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(profile.foundationName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            pw.Text(
              '(Serving the Mission of His Divine Grace A.C. Bhaktivendanta swami Prabhupada)',
              style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
            ),
            pw.SizedBox(height: 4),
            pw.Text(profile.addressLine1, style: const pw.TextStyle(fontSize: 8)),
            pw.Text(profile.addressLine2, style: const pw.TextStyle(fontSize: 8)),
            pw.Text('Phone : ${profile.phone}, E-mail : ${profile.email}', style: const pw.TextStyle(fontSize: 8)),
            if (profile.pan != null) pw.Text('${receipt.trust} PAN No : ${profile.pan}', style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _footer(TrustProfile profile, Receipt receipt, pw.ImageProvider? stamp) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (stamp != null) pw.Image(stamp, width: 56, height: 56, fit: pw.BoxFit.contain),
      pw.SizedBox(height: 4),
      pw.RichText(
        text: pw.TextSpan(
          children: [
            const pw.TextSpan(text: 'for ', style: pw.TextStyle(fontSize: 9)),
            pw.TextSpan(text: profile.foundationName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
      if (profile.registeredOffice != null) ...[
        pw.SizedBox(height: 4),
        pw.Text(profile.registeredOffice!, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
      ],
    ],
  );
}

pw.Widget _kv(String label, String value, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),
    child: pw.RichText(
      text: pw.TextSpan(
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
        children: [
          pw.TextSpan(text: '$label : '),
          pw.TextSpan(text: value, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    ),
  );
}

String _statusText(Receipt r) {
  if (r.isReceiptCancelled) return 'CANCELLED RECEIPT';
  if (r.isReceiptAccounted) return 'CONFIRMED RECEIPT';
  return 'DONATION Acknowledgement';
}

PdfColor _statusColor(Receipt r) {
  if (r.isReceiptCancelled) return PdfColor.fromInt(0xFFFF0505);
  if (r.isReceiptAccounted) return PdfColor.fromInt(0xFF1FA135);
  return PdfColor.fromInt(0xFF808080);
}

String? _taxNoteText(Receipt r) {
  if (r.isReceiptAccounted && r.isTaxExemptionRequired) {
    return 'NOTE: As per the new INCOME TAX law of the Government of India, you will receive a 10BE (Tax '
        'Exemption Certificate) form for your donation. This form will be sent to your registered email ID at '
        'the end of the current financial year and can be used for claiming tax exemption under Section 80G of '
        'the INCOME TAX Act.';
  }
  if (!r.isReceiptAccounted && !r.isReceiptCancelled) {
    return 'You will get a confirmed receipt once it is accounted';
  }
  return null;
}

String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
