// lib/core/network/api_interceptor.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/shared_preferences/preferences_service.dart';
import 'dart:async';

class ApiInterceptor extends Interceptor {
  final Dio _dio;
  final PreferencesService _preferencesService;
  // A dedicated Dio instance for refresh token requests, without interceptors
  final Dio _tokenDio;
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  ApiInterceptor({required Dio dio, required PreferencesService preferencesService})
    : _dio = dio,
      _preferencesService = preferencesService,
      _tokenDio = Dio(
        BaseOptions(
          baseUrl: '${ApiConstants.baseApiUrl}${ApiConstants.apiVersionPath}',
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final requiresAuth = options.extra['requiresAuth'] as bool? ?? true;

    if (requiresAuth) {
      final accessToken = await _preferencesService.getAccessToken();
      if (accessToken == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            error: const AuthException(message: 'No access token found.'),
            type: DioExceptionType.cancel,
          ),
        );
      }
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final originalRequest = err.requestOptions;
    final requiresAuth = originalRequest.extra['requiresAuth'] as bool? ?? true;

    if (err.response?.statusCode == 401 && requiresAuth) {
      // Prevent infinite loops by checking if this is already a refresh request
      if (originalRequest.path.contains(ApiConstants.refreshPath)) {
        print('🔄 Refresh token request failed - clearing auth data');
        await _preferencesService.clearAuthData();
        return handler.reject(err);
      }

      if (!_isRefreshing) {
        print('🔄 Starting token refresh process...');
        _isRefreshing = true;
        _refreshCompleter = Completer<void>();

        try {
          final refreshResponse = await _refreshAccessToken();
          final newAccessToken = refreshResponse['access_token'];

          if (newAccessToken != null) {
            print('✅ Token refresh successful');
            await _preferencesService.saveAccessToken(newAccessToken);

            // Complete the refresh process successfully
            if (!_refreshCompleter!.isCompleted) {
              _refreshCompleter!.complete();
            }
            _isRefreshing = false;

            // Retry the original request
            originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';
            return handler.resolve(await _dio.fetch(originalRequest));
          } else {
            print('❌ Token refresh failed - no access token received');
            // Failed to get a new token, clear auth data and reject.
            await _preferencesService.clearAuthData();
            if (!_refreshCompleter!.isCompleted) {
              _refreshCompleter!.completeError(const AuthException(message: 'Failed to get new access token.'));
            }
            _isRefreshing = false;
            return handler.reject(err);
          }
        } catch (e) {
          print('❌ Token refresh failed with error: $e');
          // Refresh token API call itself failed.
          await _preferencesService.clearAuthData();
          if (!_refreshCompleter!.isCompleted) {
            _refreshCompleter!.completeError(const AuthException(message: 'Session expired. Please log in again.'));
          }
          _isRefreshing = false;
          return handler.reject(err);
        }
      } else {
        print('⏳ Waiting for ongoing token refresh...');
        // If a refresh is already in progress, wait for it to complete with timeout
        try {
          await _refreshCompleter?.future.timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('⏰ Token refresh timeout - clearing auth data');
              _preferencesService.clearAuthData();
              throw const AuthException(message: 'Token refresh timeout');
            },
          );

          // Retry the original request with the new token
          final newAccessToken = await _preferencesService.getAccessToken();
          if (newAccessToken != null) {
            originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';
            return handler.resolve(await _dio.fetch(originalRequest));
          } else {
            // The refresh failed and cleared auth data. Reject the request.
            return handler.reject(err);
          }
        } catch (e) {
          // The refresh failed, reject the request
          return handler.reject(err);
        }
      }
    }

    // Pass all other errors along
    return handler.next(err);
  }

  Future<Map<String, dynamic>> _refreshAccessToken() async {
    final refreshToken = await _preferencesService.getRefreshToken();
    if (refreshToken == null) {
      throw const AuthException(message: 'No refresh token found.');
    }

    final body = json.encode({'refresh_token': refreshToken});

    try {
      final response = await _tokenDio.post(
        ApiConstants.refreshPath,
        data: body,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          extra: {'requiresAuth': false}, // ✅ Critical: Prevent infinite loop
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(message: 'Failed to refresh token: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Extract error message from API response if available
      String errorMessage = 'Failed to refresh token.';
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        errorMessage = responseData['message'] ?? errorMessage;
      }
      throw AuthException(message: errorMessage);
    }
  }
}
