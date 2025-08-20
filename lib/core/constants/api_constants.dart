// lib/core/constants/api_constants.dart

class ApiConstants {
  ApiConstants._();

  static const String baseApiUrl = 'http://10.0.2.2:8000';
  static const String apiVersionPath = '/api/v1';

  static const String loginPath = '/auth/login';
  static const String refreshPath = '/auth/refresh';
  static const String logoutPath = '/auth/logout';

  static const String userCreatePath = '/users/create';
  static const String userListPath = '/users';
  static const String userByEmailPath = '/users/by-email';

  static String getFullApiUrl(String path) {
    return '$baseApiUrl$apiVersionPath$path';
  }
}
