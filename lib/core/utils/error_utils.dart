// lib/core/utils/error_utils.dart

import 'package:dio/dio.dart';

class ErrorUtils {
  /// Extracts user-friendly error message from API response
  /// Falls back to default message if no message found in response
  static String extractErrorMessage(DioException error, String defaultMessage) {
    if (error.response?.data != null && error.response!.data is Map<String, dynamic>) {
      final responseData = error.response!.data as Map<String, dynamic>;
      return responseData['message'] ?? defaultMessage;
    }
    return defaultMessage;
  }

  /// Gets appropriate error message based on status code
  static String getErrorMessageByStatusCode(int? statusCode, String? apiMessage) {
    if (apiMessage != null && apiMessage.isNotEmpty) {
      return apiMessage;
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication failed. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission for this action.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. The resource already exists.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Service temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Comprehensive error message extraction with fallbacks
  static String getComprehensiveErrorMessage(DioException error, String defaultMessage) {
    // First try to get message from API response
    if (error.response?.data != null && error.response!.data is Map<String, dynamic>) {
      final responseData = error.response!.data as Map<String, dynamic>;
      final apiMessage = responseData['message'] as String?;

      if (apiMessage != null && apiMessage.isNotEmpty) {
        return apiMessage;
      }
    }

    // Fallback to status code based message
    return getErrorMessageByStatusCode(error.response?.statusCode, null);
  }
}
