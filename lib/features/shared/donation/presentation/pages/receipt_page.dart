// lib/features/shared/donation/presentation/pages/receipt_page.dart
//
// Renders a donation receipt matching DCC's actual PDF layout
// (DCC/Common/PDFService.cs GenerateDonationReceipt), section for section,
// so what preachers/employees see here is what the real backend's
// downloaded PDF would look like.
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/utils/number_to_words.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/shared/donation/data/receipt_model.dart';
import 'package:surabhi/features/shared/donation/data/receipt_pdf_builder.dart';

class ReceiptPage extends StatelessWidget {
  final Receipt receipt;

  const ReceiptPage({super.key, required this.receipt});

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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _statusBanner(),
                  const SizedBox(height: 16),
                  if (profile != null) _header(profile),
                  const Divider(height: 32),
                  const Center(
                    child: Text('DONATION RECEIPT', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  ),
                  const SizedBox(height: 8),
                  _kv('DR No.', receipt.receiptNumber, bold: true),
                  _kv('Date', _formatDate(receipt.receiptDate), bold: true),
                  const SizedBox(height: 16),
                  _kv('Name of the Donor', receipt.donorName),
                  if (receipt.address != null) _kv('Address', receipt.address!),
                  if (receipt.patronNumber != null) _kv('Reference (Patronship No)', receipt.patronNumber!, bold: true),
                  _kv('Sevak Name', receipt.sevakName),
                  _kv('Mobile', receipt.mobile),
                  _kv('Tax exemption Required', receipt.isTaxExemptionRequired ? 'YES' : 'NO', bold: true, suffix: ' (Under section 80G, of the Income Tax Act)'),
                  if (receipt.email != null) _kv('E-mail', receipt.email!),
                  if (receipt.pan != null) _kv('PAN', receipt.pan!),
                  const SizedBox(height: 8),
                  _kv('Rs.', '${formatIndianAmount(receipt.amount)} /-', bold: true),
                  _kv('Rupees', '${amountToWords(receipt.amount)} ONLY', bold: true),
                  const SizedBox(height: 8),
                  _kv('by', receipt.modeOfPayment, bold: true),
                  if (receipt.paymentRefNo != null) _kv('Reference No', receipt.paymentRefNo!),
                  if (receipt.paymentDate != null) _kv('Date', _formatDate(receipt.paymentDate!)),
                  if (receipt.bank != null) _kv('Bank', receipt.bank!),
                  _kv('Enrolled by', receipt.enrolledBy, bold: true),
                  if (receipt.cdc != null) _kv('CDC', receipt.cdc!, bold: true),
                  _kv('Towards', receipt.sevaName, bold: true),
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
                      'Hare Krishna Hare Krishna Krishna Krishna Hare Hare\nHare Rama Hare Rama Rama Rama Hare Hare',
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
              icon: const Icon(Icons.download),
              label: const Text('Download / Share PDF'),
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
    return Center(child: Text(text, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)));
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
        Text.rich(TextSpan(children: [const TextSpan(text: 'for '), TextSpan(text: profile.foundationName, style: const TextStyle(fontWeight: FontWeight.bold))])),
        if (profile.registeredOffice != null) ...[
          const SizedBox(height: 4),
          Text(profile.registeredOffice!, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ],
    );
  }

  Widget _taxNote() {
    final text = receipt.isReceiptAccounted && receipt.isTaxExemptionRequired
        ? 'NOTE: As per the new INCOME TAX law of the Government of India, you will receive a 10BE (Tax '
              'Exemption Certificate) form for your donation. This form will be sent to your registered email ID '
              'at the end of the current financial year and can be used for claiming tax exemption under Section '
              '80G of the INCOME TAX Act.'
        : (!receipt.isReceiptAccounted && !receipt.isReceiptCancelled ? 'You will get a confirmed receipt once it is accounted' : null);
    if (text == null) return const SizedBox.shrink();
    return Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey));
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

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
