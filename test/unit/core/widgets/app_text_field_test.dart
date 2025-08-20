import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surabhi/core/widgets/app_text_field.dart';

void main() {
  group('AppTextField', () {
    testWidgets('should display label text', (WidgetTester tester) async {
      // Arrange
      const labelText = 'Email';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppTextField(labelText: labelText)),
        ),
      );

      // Assert
      expect(find.text(labelText), findsOneWidget);
    });

    testWidgets('should display hint text', (WidgetTester tester) async {
      // Arrange
      const hintText = 'Enter your email';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppTextField(hintText: hintText)),
        ),
      );

      // Assert
      expect(find.text(hintText), findsOneWidget);
    });

    testWidgets('should display prefix icon', (WidgetTester tester) async {
      // Arrange
      const prefixIcon = Icon(Icons.email);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppTextField(prefixIcon: prefixIcon)),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('should display suffix icon', (WidgetTester tester) async {
      // Arrange
      const suffixIcon = Icon(Icons.visibility);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppTextField(suffixIcon: suffixIcon)),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should obscure text when obscureText is true', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController(text: 'password123');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppTextField(controller: controller, obscureText: true)),
        ),
      );

      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('should call validator when text changes', (WidgetTester tester) async {
      // Arrange
      String? validatorResult;
      String? validatorInput;

      String? validator(String? value) {
        validatorInput = value;
        validatorResult = value?.isEmpty == true ? 'Required' : null;
        return validatorResult;
      }

      // Act
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AppTextField(validator: validator),
            ),
          ),
        ),
      );

      // Enter text and trigger validation
      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pump();

      // Trigger form validation
      formKey.currentState?.validate();

      // Assert
      expect(validatorInput, equals('test@example.com'));
      expect(validatorResult, isNull);
    });

    testWidgets('should show validation error', (WidgetTester tester) async {
      // Arrange
      String? validator(String? value) {
        return value?.isEmpty == true ? 'This field is required' : null;
      }

      // Act
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AppTextField(validator: validator),
            ),
          ),
        ),
      );

      // Trigger validation with empty field
      formKey.currentState?.validate();
      await tester.pump();

      // Assert
      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('should call onChanged when text changes', (WidgetTester tester) async {
      // Arrange
      String? changedValue;
      void onChanged(String value) {
        changedValue = value;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppTextField(onChanged: onChanged)),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test input');
      await tester.pump();

      // Assert
      expect(changedValue, equals('test input'));
    });

    testWidgets('should be disabled when enabled is false', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: AppTextField(enabled: false))));

      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('should set correct keyboard type', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppTextField(keyboardType: TextInputType.emailAddress)),
        ),
      );

      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, equals(TextInputType.emailAddress));
    });
  });
}
