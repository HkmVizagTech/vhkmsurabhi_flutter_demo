// lib/core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  const ServerException({this.message = 'An unexpected server error occurred.'});

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection.'});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException({this.message = 'Authentication failed.'});

  @override
  String toString() => 'AuthException: $message';
}

class PermissionDeniedException implements Exception {
  final String message;
  const PermissionDeniedException({this.message = 'Permission denied.'});

  @override
  String toString() => 'PermissionDeniedException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'An error occurred with local storage.'});

  @override
  String toString() => 'CacheException: $message';
}

class UnhandledException implements Exception {
  final String message;
  const UnhandledException({this.message = 'An unhandled error occurred.'});

  @override
  String toString() => 'UnhandledException: $message';
}

class RateLimitException implements Exception {
  final String message;
  const RateLimitException({this.message = 'Rate limit exceeded. Please try again later.'});

  @override
  String toString() => 'RateLimitException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException({this.message = 'Validation failed.'});

  @override
  String toString() => 'ValidationException: $message';
}
