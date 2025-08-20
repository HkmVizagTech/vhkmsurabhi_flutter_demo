import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/core/data/models/user_model.dart';
import 'package:surabhi/core/data/models/paginated_response.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

/// Test helper utilities for common test operations
class TestHelpers {
  /// Creates a test user entity
  static UserEntity createTestUser({
    String userId = '1',
    String email = 'test@example.com',
    String role = 'admin',
    bool is2faEnabled = false,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? image,
  }) => UserEntity(
    userId: userId,
    email: email,
    role: role,
    is2faEnabled: is2faEnabled,
    firstName: firstName,
    lastName: lastName,
    phoneNumber: phoneNumber,
    image: image,
  );

  /// Creates a test user model
  static UserModel createTestUserModel({
    String userId = '1',
    String email = 'test@example.com',
    String role = 'admin',
    bool is2faEnabled = false,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserModel(
    userId: userId,
    email: email,
    role: role,
    is2faEnabled: is2faEnabled,
    firstName: firstName,
    lastName: lastName,
    phoneNumber: phoneNumber,
    image: image,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// Creates a test paginated response
  static PaginatedResponse<T> createTestPaginatedResponse<T>({
    required List<T> items,
    int page = 1,
    int pages = 1,
    int size = 10,
    int? total,
    bool? hasNext,
    bool? hasPrev,
  }) => PaginatedResponse<T>(
    items: items,
    meta: PaginationMeta(
      page: page,
      pages: pages,
      size: size,
      total: total ?? items.length,
      hasNext: hasNext ?? page < pages,
      hasPrev: hasPrev ?? page > 1,
    ),
  );

  /// Creates a MaterialApp wrapper for widget testing
  static Widget createTestApp({required Widget child, List<BlocProvider>? providers, ThemeData? theme}) {
    Widget app = MaterialApp(
      home: Scaffold(body: child),
      theme: theme,
    );

    if (providers != null && providers.isNotEmpty) {
      app = MultiBlocProvider(providers: providers, child: app);
    }

    return app;
  }

  /// Creates a test app with auth bloc
  static Widget createTestAppWithAuth({
    required Widget child,
    AuthBloc? authBloc,
    List<BlocProvider>? additionalProviders,
  }) {
    final providers = <BlocProvider>[
      if (authBloc != null) BlocProvider<AuthBloc>.value(value: authBloc),
      ...?additionalProviders,
    ];

    return createTestApp(child: child, providers: providers.isNotEmpty ? providers : null);
  }

  /// Pumps a widget with MaterialApp wrapper
  static Future<void> pumpTestWidget(
    WidgetTester tester,
    Widget widget, {
    List<BlocProvider>? providers,
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(createTestApp(child: widget, providers: providers, theme: theme));
  }

  /// Pumps a widget with auth bloc
  static Future<void> pumpTestWidgetWithAuth(
    WidgetTester tester,
    Widget widget, {
    AuthBloc? authBloc,
    List<BlocProvider>? additionalProviders,
  }) async {
    await tester.pumpWidget(
      createTestAppWithAuth(child: widget, authBloc: authBloc, additionalProviders: additionalProviders),
    );
  }

  /// Verifies that a mock was called with specific parameters
  static void verifyCall<T>(Mock mock, Function invocation, {int times = 1}) {
    verify(invocation).called(times);
  }

  /// Verifies that a mock was never called
  static void verifyNeverCalled(Mock mock, Function invocation) {
    verifyNever(invocation);
  }

  /// Common test expectations for error states
  static void expectErrorState(WidgetTester tester, {String? errorMessage, bool shouldHaveRetryButton = true}) {
    expect(find.text('Oops! Something went wrong'), findsOneWidget);

    if (errorMessage != null) {
      expect(find.text(errorMessage), findsOneWidget);
    }

    if (shouldHaveRetryButton) {
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    }
  }

  /// Common test expectations for loading states
  static void expectLoadingState(WidgetTester tester) {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Common test expectations for empty states
  static void expectEmptyState(WidgetTester tester, {String message = 'No data found'}) {
    expect(find.text(message), findsOneWidget);
  }

  /// Enters text in a form field by label
  static Future<void> enterTextByLabel(WidgetTester tester, String label, String text) async {
    final field = find.widgetWithText(TextFormField, label);
    await tester.enterText(field, text);
    await tester.pump();
  }

  /// Taps a button by text
  static Future<void> tapButtonByText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pump();
  }

  /// Waits for animations to complete
  static Future<void> waitForAnimations(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  /// Creates a mock response for HTTP calls
  static Map<String, dynamic> createMockApiResponse({
    bool success = true,
    String? message,
    Map<String, dynamic>? data,
  }) => {'success': success, if (message != null) 'message': message, if (data != null) ...data};

  /// Creates a mock error response
  static Map<String, dynamic> createMockErrorResponse({
    String message = 'An error occurred',
    String errorType = 'server_error',
    String? requestId,
  }) => {'success': false, 'message': message, 'error_type': errorType, if (requestId != null) 'request_id': requestId};
}

/// Extension methods for easier testing
extension WidgetTesterExtensions on WidgetTester {
  /// Finds a widget by its key
  Finder findByKey(String key) => find.byKey(Key(key));

  /// Finds a text field by its label
  Finder findTextFieldByLabel(String label) => find.widgetWithText(TextFormField, label);

  /// Finds a button by its text
  Finder findButtonByText(String text) => find.widgetWithText(ElevatedButton, text);

  /// Enters text and pumps
  Future<void> enterTextAndPump(Finder finder, String text) async {
    await enterText(finder, text);
    await pump();
  }

  /// Taps and pumps
  Future<void> tapAndPump(Finder finder) async {
    await tap(finder);
    await pump();
  }

  /// Taps and settles
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }
}
