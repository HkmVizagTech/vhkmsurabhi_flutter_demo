// lib/features/auth/presentation/pages/twofa_choice_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class TwoFAChoicePage extends StatefulWidget {
  const TwoFAChoicePage({super.key});

  @override
  State<TwoFAChoicePage> createState() => _TwoFAChoicePageState();
}

class _TwoFAChoicePageState extends State<TwoFAChoicePage> {
  String _method = 'email';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Two-Factor Authentication',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose verification method:'),
            RadioListTile<String>(
              title: const Text('Email'),
              value: 'email',
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v ?? 'email'),
            ),
            RadioListTile<String>(
              title: const Text('Phone'),
              value: 'phone',
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v ?? 'phone'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.go('/2fa/verify?method=$_method');
              },
              child: const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
