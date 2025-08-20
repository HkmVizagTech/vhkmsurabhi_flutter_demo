// lib/features/auth/presentation/pages/twofa_verify_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class TwoFAVerifyPage extends StatefulWidget {
  const TwoFAVerifyPage({super.key});

  @override
  State<TwoFAVerifyPage> createState() => _TwoFAVerifyPageState();
}

class _TwoFAVerifyPageState extends State<TwoFAVerifyPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final method = GoRouterState.of(context).uri.queryParameters['method'] ?? 'email';
    return AppScaffold(
      title: 'Verify OTP',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter OTP sent via $method'),
            const SizedBox(height: 12),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'OTP'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Mock verify success: after OTP, go to home
                context.go('/home');
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
