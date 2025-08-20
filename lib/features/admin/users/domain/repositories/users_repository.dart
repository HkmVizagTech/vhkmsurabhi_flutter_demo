// lib/features/admin/users/domain/repositories/users_repository.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/core/data/models/paginated_response.dart';
import 'package:surabhi/core/errors/failures.dart';

abstract class UsersRepository {
  Future<Either<Failure, PaginatedResponse<UserEntity>>> getUsers({int page = 1, int size = 10});
}
