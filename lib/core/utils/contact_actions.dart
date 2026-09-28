// lib/core/utils/contact_actions.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

String _lastTen(String mobile) {
  final digits = mobile.replaceAll(RegExp(r'\D'), '');
  return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
}

/// Opens the dialer for a donor; the number itself is never shown in the app.
Future<void> callDonor(BuildContext context, String mobile) async {
  final messenger = ScaffoldMessenger.of(context);
  final ok = await launchUrl(Uri(scheme: 'tel', path: '+91${_lastTen(mobile)}'), mode: LaunchMode.externalApplication);
  if (!ok) {
    messenger.showSnackBar(const SnackBar(content: Text('Could not open this on the device')));
  }
}
