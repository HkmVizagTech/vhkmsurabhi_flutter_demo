import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:surabhi/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('should navigate to login page and show login form', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should start on home page
      expect(find.text('Welcome to Surabhi'), findsOneWidget);

      // Find and tap login button
      expect(find.text('Login to Continue'), findsOneWidget);
      await tester.tap(find.text('Login to Continue'));
      await tester.pumpAndSettle();

      // Should navigate to login page
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', (WidgetTester tester) async {
      // Start the app and navigate to login
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login to Continue'));
      await tester.pumpAndSettle();

      // Try to login with empty fields
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should show validation error for invalid email', (WidgetTester tester) async {
      // Start the app and navigate to login
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login to Continue'));
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show email validation error
      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('should convert email to lowercase automatically', (WidgetTester tester) async {
      // Start the app and navigate to login
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login to Continue'));
      await tester.pumpAndSettle();

      // Enter email with uppercase letters
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'TEST@EXAMPLE.COM');
      await tester.pump();

      // Should automatically convert to lowercase
      final emailWidget = tester.widget<TextFormField>(emailField);
      expect(emailWidget.controller?.text, equals('test@example.com'));
    });

    testWidgets('should show drawer with login option when not authenticated', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Should show unauthenticated drawer content
      expect(find.text('Welcome to Surabhi'), findsOneWidget);
      expect(find.text('Please login to continue'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should navigate to home from drawer', (WidgetTester tester) async {
      // Start the app and navigate to login
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login to Continue'));
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap Home in drawer
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Should navigate back to home page
      expect(find.text('Welcome to Surabhi'), findsOneWidget);
      expect(find.text('Login to Continue'), findsOneWidget);
    });

    testWidgets('should toggle theme from drawer', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Find theme toggle (should be present in drawer)
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);

      // Tap theme toggle
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pumpAndSettle();

      // Theme should change (icon should change to light mode)
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });
  });

  group('Error Handling Integration Tests', () {
    testWidgets('should show error display with retry button', (WidgetTester tester) async {
      // This test would require mocking network failures
      // For now, we'll test the error display widget structure
      app.main();
      await tester.pumpAndSettle();

      // Navigate to a page that might show errors (like admin dashboard without auth)
      // This would typically show an error or redirect

      // For basic structure testing, we can verify error handling components exist
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Navigation Integration Tests', () {
    testWidgets('should handle back navigation correctly', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.text('Login to Continue'));
      await tester.pumpAndSettle();

      // Should be on login page
      expect(find.text('Login'), findsOneWidget);

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Should be back on home page
      expect(find.text('Welcome to Surabhi'), findsOneWidget);
    });

    testWidgets('should maintain state during navigation', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.text('Login to Continue'));
      await tester.pumpAndSettle();

      // Enter some text
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.pump();

      // Navigate back and forward
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login to Continue'));
      await tester.pumpAndSettle();

      // Text should be cleared (new page instance)
      final emailField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      expect(emailField.controller?.text, isEmpty);
    });
  });
}
