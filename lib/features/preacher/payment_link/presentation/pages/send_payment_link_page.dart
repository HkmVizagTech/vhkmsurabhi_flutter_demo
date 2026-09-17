// lib/features/preacher/payment_link/presentation/pages/send_payment_link_page.dart
//
// DEMO ONLY: no Razorpay account is wired up yet. This screen shows the
// intended flow (generate a payment link for a donor -> donor pays -> auto
// verify -> auto-send receipt) end to end using fake data, so the UX can be
// reviewed before real Razorpay keys + a webhook endpoint exist to back it.

import 'package:flutter/material.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

enum _LinkStatus { form, generated, verified }

class SendPaymentLinkPage extends StatefulWidget {
  const SendPaymentLinkPage({super.key});

  @override
  State<SendPaymentLinkPage> createState() => _SendPaymentLinkPageState();
}

class _SendPaymentLinkPageState extends State<SendPaymentLinkPage> {
  static const _color = AppColors.preacherColor;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _amountController = TextEditingController();

  _LinkStatus _status = _LinkStatus.form;
  String? _fakeLink;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _generateLink() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _fakeLink = 'https://pay.dcc.example/l/${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
      _status = _LinkStatus.generated;
    });
  }

  void _simulatePaymentReceived() {
    setState(() => _status = _LinkStatus.verified);
  }

  void _reset() {
    setState(() {
      _status = _LinkStatus.form;
      _fakeLink = null;
      _nameController.clear();
      _mobileController.clear();
      _amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Send Payment Link',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'DEMO MODE — no real payment gateway is connected yet. '
                      'This shows the intended flow only; no money moves.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_status == _LinkStatus.form) _buildForm(),
            if (_status == _LinkStatus.generated) _buildGeneratedState(),
            if (_status == _LinkStatus.verified) _buildVerifiedState(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Donor Name', prefixIcon: Icon(Icons.person)),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Donor name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone)),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Mobile number is required';
              if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) return 'Enter a valid 10-digit mobile number';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (₹)', prefixIcon: Icon(Icons.currency_rupee)),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Amount is required';
              final n = num.tryParse(v);
              if (n == null || n <= 0) return 'Enter a valid amount';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generateLink,
            style: ElevatedButton.styleFrom(backgroundColor: _color, minimumSize: const Size.fromHeight(50)),
            icon: const Icon(Icons.link, color: Colors.white),
            label: const Text('Generate Payment Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.hourglass_top, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Text('Waiting for payment', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Donor: ${_nameController.text}'),
                Text('Amount: ₹${_amountController.text}'),
                const SizedBox(height: 12),
                SelectableText(_fakeLink ?? '', style: TextStyle(color: _color, fontSize: 13)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share),
          label: const Text('Share via WhatsApp'),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _simulatePaymentReceived,
          style: ElevatedButton.styleFrom(backgroundColor: _color, minimumSize: const Size.fromHeight(50)),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          label: const Text('Simulate Payment Received (demo)', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildVerifiedState() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(Icons.check_circle, color: Colors.green.shade600, size: 72),
        const SizedBox(height: 16),
        const Text('Payment Verified', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('₹${_amountController.text} received from ${_nameController.text}', textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text(
          'Receipt auto-sent to donor (demo)',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: _reset, child: const Text('Send Another Link')),
      ],
    );
  }
}
