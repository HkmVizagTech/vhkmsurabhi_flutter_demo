// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/features/auth/domain/usecases/login_usecase.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(LoginParams params);
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, UserEntity>> checkAuthStatus();
}
