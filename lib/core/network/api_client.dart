// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/network/api_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio, ApiInterceptor apiInterceptor) {
    _dio.options.baseUrl = '${ApiConstants.baseApiUrl}${ApiConstants.apiVersionPath}';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};
    _dio.options.followRedirects = false;
    _dio.options.receiveDataWhenStatusError = true;

    // The interceptor is provided from the outside
    if (!_dio.interceptors.contains(apiInterceptor)) {
      _dio.interceptors.add(apiInterceptor);
    }
    _dio.interceptors.add(
      PrettyDioLogger(requestHeader: true, requestBody: true, responseHeader: true, responseBody: true),
    );
  }

  Dio get dio => _dio;
}
