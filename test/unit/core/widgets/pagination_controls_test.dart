import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surabhi/core/data/models/paginated_response.dart';
import 'package:surabhi/core/widgets/pagination_controls.dart';

void main() {
  group('PaginationControls', () {
    const testMeta = PaginationMeta(page: 2, pages: 5, size: 10, total: 50, hasNext: true, hasPrev: true);

    testWidgets('should display pagination info', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PaginationControls(meta: testMeta)),
        ),
      );

      // Assert
      expect(find.text('Page 2 of 5 (50 total items)'), findsOneWidget);
    });

    testWidgets('should display navigation buttons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PaginationControls(meta: testMeta)),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('should call onPrevious when previous button is tapped', (WidgetTester tester) async {
      // Arrange
      bool previousCalled = false;
      void onPrevious() {
        previousCalled = true;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationControls(meta: testMeta, onPrevious: onPrevious),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      // Assert
      expect(previousCalled, isTrue);
    });

    testWidgets('should call onNext when next button is tapped', (WidgetTester tester) async {
      // Arrange
      bool nextCalled = false;
      void onNext() {
        nextCalled = true;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationControls(meta: testMeta, onNext: onNext),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      // Assert
      expect(nextCalled, isTrue);
    });

    testWidgets('should disable previous button when hasPrev is false', (WidgetTester tester) async {
      // Arrange
      const metaFirstPage = PaginationMeta(page: 1, pages: 5, size: 10, total: 50, hasNext: true, hasPrev: false);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationControls(meta: metaFirstPage, onPrevious: () {}),
          ),
        ),
      );

      // Assert
      final previousButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_left));
      expect(previousButton.onPressed, isNull);
    });

    testWidgets('should disable next button when hasNext is false', (WidgetTester tester) async {
      // Arrange
      const metaLastPage = PaginationMeta(page: 5, pages: 5, size: 10, total: 50, hasNext: false, hasPrev: true);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationControls(meta: metaLastPage, onNext: () {}),
          ),
        ),
      );

      // Assert
      final nextButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_right));
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('should display page size selector when onPageSizeChanged is provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationControls(meta: testMeta, currentPageSize: 10, onPageSizeChanged: (size) {}),
          ),
        ),
      );

      // Assert
      expect(find.text('Show:'), findsOneWidget);
      expect(find.byType(DropdownButton<int>), findsOneWidget);
    });

    testWidgets('should call onPageSizeChanged when page size is changed', (WidgetTester tester) async {
      // Arrange
      int? selectedSize;
      void onPageSizeChanged(int size) {
        selectedSize = size;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationControls(meta: testMeta, currentPageSize: 10, onPageSizeChanged: onPageSizeChanged),
          ),
        ),
      );

      // Tap dropdown
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();

      // Select different size
      await tester.tap(find.text('20').last);
      await tester.pumpAndSettle();

      // Assert
      expect(selectedSize, equals(20));
    });

    testWidgets('should show loading indicator when isLoading is true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PaginationControls(meta: testMeta, isLoading: true)),
        ),
      );

      // Assert
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should disable buttons when isLoading is true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationControls(meta: testMeta, isLoading: true, onPrevious: () {}, onNext: () {}),
          ),
        ),
      );

      // Assert
      final previousButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_left));
      final nextButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_right));

      expect(previousButton.onPressed, isNull);
      expect(nextButton.onPressed, isNull);
    });
  });
}
