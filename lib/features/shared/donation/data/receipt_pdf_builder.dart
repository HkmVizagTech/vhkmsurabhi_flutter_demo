// lib/features/shared/donation/data/receipt_pdf_builder.dart
//
// Builds a PDF matching DCC's real receipt output field for field and
// column for column (DCC/Common/PDFService.cs GenerateDonationReceipt,
// GetReceiptHeader, GetReceiptFooter - iTextSharp renders the same HTML
// server-side). Column widths mirror the original's colspan-out-of-5
// table layout.
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
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                _statusText(receipt),
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _statusColor(receipt)),
              ),
            ),
            pw.SizedBox(height: 14),
            if (profile != null) _header(profile, receipt, logo),
            pw.SizedBox(height: 10),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text('DONATION RECEIPT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('DR No. ${receipt.receiptNumber}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Date: ${_formatDate(receipt.receiptDate)}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text('Name of the Donor : ${receipt.donorName}', style: const pw.TextStyle(fontSize: 9)),
            pw.Text('Address : ${receipt.address ?? ''}', style: const pw.TextStyle(fontSize: 9)),
            _row(flexes: const [3, 2], cells: [
              _field('Reference(Patronship No)', receipt.patronNumber ?? '', bold: true),
              _field('Sevak Name', receipt.sevakName),
            ]),
            _row(flexes: const [3, 2], cells: [
              _field('Phone', 'Res :          Off :          '),
              _field('Mobile', receipt.mobile),
            ]),
            pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
                children: [
                  const pw.TextSpan(text: 'Tax exemption Required '),
                  pw.TextSpan(
                    text: receipt.isTaxExemptionRequired == true ? 'YES ' : 'NO ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: '(Under section 80G, of the Income Tax Act) '),
                ],
              ),
            ),
            _row(flexes: const [3, 2], cells: [
              _field('E-mail', receipt.email ?? ''),
              _field('PAN', receipt.pan ?? ''),
            ]),
            _row(flexes: const [1, 4], cells: [
              _field('Rs.', '${formatIndianAmount(receipt.amount)} /-', bold: true),
              _field('Rupees', '${amountToWords(receipt.amount)} ONLY', bold: true),
            ]),
            _row(flexes: const [1, 2, 2], cells: [
              _field('by', receipt.modeOfPayment, bold: true),
              _field('Reference No', receipt.paymentRefNo ?? ''),
              _field('Date', receipt.paymentDate != null ? _formatDate(receipt.paymentDate!) : ''),
            ]),
            _row(flexes: const [1, 1, 1, 2], cells: [
              _field('Bank', receipt.bank ?? ''),
              _field('Enrolled by', receipt.enrolledBy, bold: true, align: pw.TextAlign.center),
              _field('CDC', receipt.cdc ?? '', bold: true, align: pw.TextAlign.center),
              _field('Towards', receipt.sevaName, bold: true),
            ]),
            pw.SizedBox(height: 8),
            pw.Text(
              '*Cheque Payment : Subject to realization. We do not accept anonymous donations.',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 14),
            if (_taxNoteText(receipt) != null)
              pw.Center(
                child: pw.Text(
                  _taxNoteText(receipt)!,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ),
            pw.SizedBox(height: 10),
            if (profile != null) _footer(profile, receipt, stamp),
            pw.SizedBox(height: 14),
            pw.Center(
              child: pw.Text(
                'Hare Krishna Hare Krishna Krishna Krishna Hare Hare  Hare Rama Hare Rama Rama Rama Hare Hare',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Text(
                '*This is an electronically generated receipt, hence does not require signature',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 10),
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
      if (logo != null) pw.Image(logo, height: 46, fit: pw.BoxFit.contain),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(profile.foundationName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13), textAlign: pw.TextAlign.right),
            pw.Text(
              '(Serving the Mission of His Divine Grace A.C. Bhaktivendanta swami Prabhupada)',
              style: const pw.TextStyle(fontSize: 8),
              textAlign: pw.TextAlign.right,
            ),
            pw.Text(profile.addressLine1, style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
            pw.Text(profile.addressLine2, style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
            pw.Text('Phone : ${profile.phone}, E-mail : ${profile.email}', style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
            if (profile.pan != null)
              pw.Text('${receipt.trust} PAN No : ${profile.pan}', style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _footer(TrustProfile profile, Receipt receipt, pw.ImageProvider? stamp) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      if (stamp != null) pw.Image(stamp, height: 40, fit: pw.BoxFit.contain),
      pw.SizedBox(height: 4),
      pw.RichText(
        text: pw.TextSpan(
          children: [
            const pw.TextSpan(text: 'for ', style: pw.TextStyle(fontSize: 9)),
            pw.TextSpan(text: profile.footerFoundationName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
      if (profile.registeredOffice != null) ...[
        pw.SizedBox(height: 4),
        pw.Center(child: pw.Text(profile.registeredOffice!, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700))),
      ],
    ],
  );
}

pw.Widget _row({required List<int> flexes, required List<pw.Widget> cells}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < cells.length; i++) pw.Expanded(flex: flexes[i], child: cells[i]),
      ],
    ),
  );
}

pw.Widget _field(String label, String value, {bool bold = false, pw.TextAlign align = pw.TextAlign.left}) {
  return pw.RichText(
    textAlign: align,
    text: pw.TextSpan(
      style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
      children: [
        pw.TextSpan(text: '$label : '),
        pw.TextSpan(text: value, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
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
  if (r.isReceiptAccounted && r.isTaxExemptionRequired == true) {
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
