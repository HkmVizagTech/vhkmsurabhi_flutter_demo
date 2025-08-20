// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/features/auth/data/models/auth_response_model.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/features/auth/domain/usecases/login_usecase.dart';
import 'package:surabhi/core/utils/error_utils.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginParams params);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(LoginParams params) async {
    // FastAPI expects OAuth2PasswordRequestForm (application/x-www-form-urlencoded)
    try {
      final response = await apiClient.dio.post(
        ApiConstants.loginPath,
        data: {'username': params.email, 'password': params.password},
        options: Options(contentType: Headers.formUrlEncodedContentType, extra: {'requiresAuth': false}),
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      // Extract user-friendly message from API response
      final errorMessage = ErrorUtils.getComprehensiveErrorMessage(e, 'Login failed');
      throw AuthException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await apiClient.dio.post(ApiConstants.logoutPath);
      return response.data;
    } on DioException catch (e) {
      // Extract user-friendly message from API response
      final errorMessage = ErrorUtils.getComprehensiveErrorMessage(e, 'Logout failed');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }
}
