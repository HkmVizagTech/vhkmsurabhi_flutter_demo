// lib/features/admin/users/data/repositories/users_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/features/admin/users/data/datasources/users_remote_datasource.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/core/data/models/paginated_response.dart';
import 'package:surabhi/features/admin/users/domain/repositories/users_repository.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/errors/failures.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedResponse<UserEntity>>> getUsers({int page = 1, int size = 10}) async {
    try {
      final paginatedUsers = await remoteDataSource.getUsers(page: page, size: size);
      final userEntities = paginatedUsers.items.map((user) => user as UserEntity).toList();
      return Right(PaginatedResponse(items: userEntities, meta: paginatedUsers.meta));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
