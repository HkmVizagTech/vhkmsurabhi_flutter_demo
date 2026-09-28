// lib/core/utils/contact_actions.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Why a preacher is reaching out - picks the WhatsApp greeting.
enum ContactReason { general, birthday, lapsed, neverDonated, thankYou }

String _lastTen(String mobile) {
  final digits = mobile.replaceAll(RegExp(r'\D'), '');
  return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
}

String greetingFor(String name, ContactReason reason) {
  final first = name.trim().split(' ').first;
  switch (reason) {
    case ContactReason.birthday:
      return 'Hare Krishna $first! Wishing you a very happy birthday - may Sri Krishna bless you and your family always.';
    case ContactReason.lapsed:
      return 'Hare Krishna $first! We miss you at the temple - it would be wonderful to have you with us at the next festival.';
    case ContactReason.neverDonated:
      return 'Hare Krishna $first! Thank you for joining the temple family. Here are the sevas you can take part in this month.';
    case ContactReason.thankYou:
      return 'Hare Krishna $first! Thank you for your kind seva. May Sri Krishna bless you.';
    case ContactReason.general:
      return 'Hare Krishna $first!';
  }
}

Future<void> callDonor(BuildContext context, String mobile) {
  return _open(context, Uri(scheme: 'tel', path: '+91${_lastTen(mobile)}'));
}

Future<void> whatsappDonor(BuildContext context, String mobile, String name, ContactReason reason) {
  return _open(
    context,
    Uri.https('wa.me', '/91${_lastTen(mobile)}', {'text': greetingFor(name, reason)}),
  );
}

Future<void> _open(BuildContext context, Uri uri) async {
  final messenger = ScaffoldMessenger.of(context);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    messenger.showSnackBar(const SnackBar(content: Text('Could not open this on the device')));
  }
}
