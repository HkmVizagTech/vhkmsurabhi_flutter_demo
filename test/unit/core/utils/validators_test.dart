import 'package:flutter_test/flutter_test.dart';
import 'package:surabhi/core/utils/validators.dart';

void main() {
  group('AppValidators.emailValidator', () {
    test('returns true if email is valid', () {
      expect(AppValidators.isValidEmail('test@example.com'), true);
    });

    test('returns false if email is invalid', () {
      expect(AppValidators.isValidEmail('invalidemail'), false);
    });
  });

  group('AppValidators.passwordValidator', () {
    test('returns true if password is valid', () {
      expect(AppValidators.isValidPassword('Abcd123!'), true);
    });

    test('returns false if password is invalid', () {
      expect(AppValidators.isValidPassword('abc12'), false);
    });
  });
}
