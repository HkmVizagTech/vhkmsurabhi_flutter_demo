// lib/core/utils/number_to_words.dart
//
// Indian-numbering (lakh/crore) number-to-words, matching DCC's
// MyExtensions.ConvertNumbertoWords used on donation receipts.

const List<String> _ones = [
  '', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE', 'TEN',
  'ELEVEN', 'TWELVE', 'THIRTEEN', 'FOURTEEN', 'FIFTEEN', 'SIXTEEN', 'SEVENTEEN', 'EIGHTEEN', 'NINETEEN',
];

const List<String> _tens = [
  '', '', 'TWENTY', 'THIRTY', 'FORTY', 'FIFTY', 'SIXTY', 'SEVENTY', 'EIGHTY', 'NINETY',
];

String _twoDigits(int n) {
  if (n < 20) return _ones[n];
  return '${_tens[n ~/ 10]}${n % 10 != 0 ? ' ${_ones[n % 10]}' : ''}';
}

String _threeDigits(int n) {
  final hundreds = n ~/ 100;
  final rest = n % 100;
  final parts = <String>[];
  if (hundreds != 0) parts.add('${_ones[hundreds]} HUNDRED');
  if (rest != 0) parts.add(_twoDigits(rest));
  return parts.join(' ');
}

/// Converts a whole-rupee amount to words using the Indian numbering
/// system (crore / lakh / thousand / hundred), e.g. 125000 -> "ONE LAKH
/// TWENTY FIVE THOUSAND".
String amountToWords(int amount) {
  if (amount == 0) return 'ZERO';
  var n = amount;
  final crore = n ~/ 10000000;
  n %= 10000000;
  final lakh = n ~/ 100000;
  n %= 100000;
  final thousand = n ~/ 1000;
  n %= 1000;
  final hundred = n;

  final parts = <String>[];
  if (crore != 0) parts.add('${_threeDigits(crore)} CRORE');
  if (lakh != 0) parts.add('${_threeDigits(lakh)} LAKH');
  if (thousand != 0) parts.add('${_threeDigits(thousand)} THOUSAND');
  if (hundred != 0) parts.add(_threeDigits(hundred));
  return parts.join(' ');
}

/// Formats a whole-rupee amount with Indian comma grouping (lakh/crore),
/// e.g. 1250000 -> "12,50,000".
String formatIndianAmount(int amount) {
  final digits = amount.abs().toString();
  final sign = amount < 0 ? '-' : '';
  if (digits.length <= 3) return '$sign$digits';
  final last3 = digits.substring(digits.length - 3);
  final rest = digits.substring(0, digits.length - 3);
  final buffer = StringBuffer();
  for (var i = 0; i < rest.length; i++) {
    final posFromEnd = rest.length - i;
    buffer.write(rest[i]);
    if (posFromEnd > 1 && posFromEnd % 2 == 1) buffer.write(',');
  }
  return '$sign$buffer,$last3';
}
