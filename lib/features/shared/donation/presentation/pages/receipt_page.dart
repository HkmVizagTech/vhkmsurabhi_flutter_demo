// lib/features/shared/donation/presentation/pages/receipt_page.dart
//
// Renders a donation receipt matching DCC's actual PDF layout field for
// field (DCC/Common/PDFService.cs GenerateDonationReceipt/GetReceiptHeader/
// GetReceiptFooter), including which fields sit on the same row and which
// are always shown (blank rather than hidden) even when empty.
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/utils/number_to_words.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/shared/donation/data/receipt_model.dart';
import 'package:surabhi/features/shared/donation/data/receipt_pdf_builder.dart';

class ReceiptPage extends StatelessWidget {
  final Receipt receipt;
  final Color color;

  const ReceiptPage({super.key, required this.receipt, required this.color});

  @override
  Widget build(BuildContext context) {
    final profile = trustProfiles[receipt.trust];
    return AppScaffold(
      title: 'Receipt',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _statusBanner(),
                  const SizedBox(height: 16),
                  if (profile != null) _header(profile),
                  const Divider(height: 32),
                  Center(
                    child: Text(
                      'DONATION RECEIPT',
                      style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: color),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _kv('DR No.', receipt.receiptNumber, bold: true),
                  _kv('Date', _formatDate(receipt.receiptDate), bold: true),
                  const SizedBox(height: 16),
                  _kv('Name of the Donor', receipt.donorName),
                  _kv('Address', receipt.address ?? ''),
                  _row2('Reference(Patronship No)', receipt.patronNumber ?? '', bold1: true, 'Sevak Name', receipt.sevakName),
                  _row2('Phone', 'Res :        Off :', 'Mobile', receipt.mobile),
                  _kv('Tax exemption Required', receipt.isTaxExemptionRequired == true ? 'YES' : 'NO', bold: true, suffix: ' (Under section 80G, of the Income Tax Act)'),
                  _row2('E-mail', receipt.email ?? '', 'PAN', receipt.pan ?? ''),
                  _row2('Rs.', '${formatIndianAmount(receipt.amount)} /-', bold1: true, 'Rupees', '${amountToWords(receipt.amount)} ONLY', bold2: true),
                  _row3(
                    'by',
                    receipt.modeOfPayment,
                    bold1: true,
                    'Reference No',
                    receipt.paymentRefNo ?? '',
                    'Date',
                    receipt.paymentDate != null ? _formatDate(receipt.paymentDate!) : '',
                  ),
                  _row4(
                    'Bank',
                    receipt.bank ?? '',
                    'Enrolled by',
                    receipt.enrolledBy,
                    'CDC',
                    receipt.cdc ?? '',
                    'Towards',
                    receipt.sevaName,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '*Cheque Payment : Subject to realization. We do not accept anonymous donations.',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 12),
                  _taxNote(),
                  const Divider(height: 32),
                  if (profile != null) _footer(profile),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Hare Krishna Hare Krishna Krishna Krishna Hare Hare  Hare Rama Hare Rama Rama Rama Hare Hare',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      '*This is an electronically generated receipt, hence does not require signature',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final bytes = await buildReceiptPdf(receipt);
                await Printing.sharePdf(bytes: bytes, filename: '${receipt.receiptNumber}.pdf');
              },
              style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size.fromHeight(50)),
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text('Download / Share PDF', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Printing.layoutPdf(onLayout: (_) => buildReceiptPdf(receipt)),
              icon: const Icon(Icons.print_outlined),
              label: const Text('Print'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBanner() {
    late final String text;
    late final Color color;
    if (receipt.isReceiptCancelled) {
      text = 'CANCELLED RECEIPT';
      color = const Color(0xFFFF0505);
    } else if (receipt.isReceiptAccounted) {
      text = 'CONFIRMED RECEIPT';
      color = const Color(0xFF1FA135);
    } else {
      text = 'DONATION Acknowledgement';
      color = const Color(0xFF808080);
    }
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _header(TrustProfile profile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profile.logoAsset != null) ...[
          Image.asset(profile.logoAsset!, width: 56, height: 56, fit: BoxFit.contain),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.foundationName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Text(
                '(Serving the Mission of His Divine Grace A.C. Bhaktivendanta swami Prabhupada)',
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 4),
              Text(profile.addressLine1, style: const TextStyle(fontSize: 10)),
              Text(profile.addressLine2, style: const TextStyle(fontSize: 10)),
              Text('Phone : ${profile.phone}, E-mail : ${profile.email}', style: const TextStyle(fontSize: 10)),
              if (profile.pan != null) Text('${receipt.trust} PAN No : ${profile.pan}', style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _footer(TrustProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(profile.stampAsset, width: 64, height: 64, fit: BoxFit.contain),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'for '),
              TextSpan(text: profile.footerFoundationName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        if (profile.registeredOffice != null) ...[
          const SizedBox(height: 4),
          Text(profile.registeredOffice!, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ],
    );
  }

  Widget _taxNote() {
    final text = receipt.isReceiptAccounted && receipt.isTaxExemptionRequired == true
        ? 'NOTE: As per the new INCOME TAX law of the Government of India, you will receive a 10BE (Tax '
              'Exemption Certificate) form for your donation. This form will be sent to your registered email ID '
              'at the end of the current financial year and can be used for claiming tax exemption under Section '
              '80G of the INCOME TAX Act.'
        : (!receipt.isReceiptAccounted && !receipt.isReceiptCancelled ? 'You will get a confirmed receipt once it is accounted' : null);
    if (text == null) return const SizedBox.shrink();
    return Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey));
  }

  Widget _kv(String label, String value, {bool bold = false, String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          children: [
            TextSpan(text: '$label : '),
            TextSpan(text: value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
            TextSpan(text: suffix),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value, {bool bold = false}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        children: [
          TextSpan(text: '$label : '),
          TextSpan(text: value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _row2(String l1, String v1, String l2, String v2, {bool bold1 = false, bool bold2 = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _field(l1, v1, bold: bold1)),
          Expanded(flex: 2, child: _field(l2, v2, bold: bold2)),
        ],
      ),
    );
  }

  Widget _row3(String l1, String v1, String l2, String v2, String l3, String v3, {bool bold1 = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _field(l1, v1, bold: bold1)),
          Expanded(flex: 3, child: _field(l2, v2)),
          Expanded(flex: 2, child: _field(l3, v3)),
        ],
      ),
    );
  }

  Widget _row4(String l1, String v1, String l2, String v2, String l3, String v3, String l4, String v4) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          _field(l1, v1),
          _field(l2, v2, bold: true),
          _field(l3, v3, bold: true),
          _field(l4, v4, bold: true),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
