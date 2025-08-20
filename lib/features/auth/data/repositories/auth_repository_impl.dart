// lib/features/auth/data/repositories/auth_repository.dart
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/shared_preferences/preferences_service.dart';
import 'package:surabhi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:surabhi/core/data/models/user_model.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/features/auth/domain/usecases/login_usecase.dart';
import 'package:surabhi/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final PreferencesService preferencesService;

  AuthRepositoryImpl({required this.remoteDataSource, required this.preferencesService});

  @override
  Future<Either<Failure, UserEntity>> login(LoginParams params) async {
    try {
      final authResponse = await remoteDataSource.login(params);

      await preferencesService.saveAccessToken(authResponse.accessToken);
      await preferencesService.saveRefreshToken(authResponse.refreshToken);
      final userJson = json.encode(authResponse.user.toJson());
      await preferencesService.saveUserJson(userJson);

      final userEntity = authResponse.user;

      return Right(userEntity);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(const UnhandledFailure(message: 'An error occurred.'));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      // Assuming a server-side logout is not critical for local state
      await remoteDataSource.logout();
    } catch (e) {
      // Server-side logout failed, but we should proceed with local logout
    }
    await preferencesService.clearAuthData();
    return const Right(true);
  }

  @override
  Future<Either<Failure, UserEntity>> checkAuthStatus() async {
    final userJson = preferencesService.getUserJson();
    if (userJson == null) {
      return Left(const AuthFailure(message: 'No user data found.'));
    }

    try {
      final Map<String, dynamic> userMap = json.decode(userJson);
      final userModel = UserModel.fromJson(userMap);
      return Right(userModel);
    } catch (e) {
      return Left(const CacheFailure(message: 'Failed to parse user data.'));
    }
  }
}
