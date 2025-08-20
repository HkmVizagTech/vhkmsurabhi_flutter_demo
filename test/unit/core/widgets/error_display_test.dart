import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surabhi/core/widgets/error_display.dart';

void main() {
  group('ErrorDisplay', () {
    testWidgets('should display error message', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Something went wrong';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ErrorDisplay(message: errorMessage)),
        ),
      );

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Oops! Something went wrong'), findsOneWidget);
    });

    testWidgets('should display custom icon when provided', (WidgetTester tester) async {
      // Arrange
      const customIcon = Icons.network_check;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(message: 'Network error', icon: customIcon),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(customIcon), findsOneWidget);
    });

    testWidgets('should display default error icon when no icon provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ErrorDisplay(message: 'Error message')),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display retry button when onRetry is provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(message: 'Error message', onRetry: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should display custom retry button text', (WidgetTester tester) async {
      // Arrange
      const customRetryText = 'Try Again';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(message: 'Error message', onRetry: () {}, retryButtonText: customRetryText),
          ),
        ),
      );

      // Assert
      expect(find.text(customRetryText), findsOneWidget);
    });

    testWidgets('should not display retry button when onRetry is null', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ErrorDisplay(message: 'Error message')),
        ),
      );

      // Assert
      expect(find.text('Retry'), findsNothing);
    });
  });

  group('ErrorSnackBar', () {
    testWidgets('should show snackbar with message', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Network error occurred';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => ErrorSnackBar.show(context, errorMessage),
                child: const Text('Show Error'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
