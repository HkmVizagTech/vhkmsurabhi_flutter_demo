import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/features/auth/domain/repositories/auth_repository.dart';
import 'package:surabhi/features/auth/domain/usecases/login_usecase.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockAuthRepository);
  });

  group('LoginUseCase', () {
    const testUser = UserEntity(userId: '1', email: 'test@example.com', role: 'admin', is2faEnabled: false);

    const testParams = LoginParams(email: 'test@example.com', password: 'password123');

    test('should return UserEntity when login is successful', () async {
      // Arrange
      when(mockAuthRepository.login(testParams)).thenAnswer((_) async => const Right(testUser));

      // Act
      final result = await loginUseCase(testParams);

      // Assert
      expect(result, equals(const Right(testUser)));
      verify(mockAuthRepository.login(testParams)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthFailure when login fails with invalid credentials', () async {
      // Arrange
      const failure = AuthFailure(message: 'Invalid email or password');
      when(mockAuthRepository.login(testParams)).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await loginUseCase(testParams);

      // Assert
      expect(result, equals(const Left(failure)));
      verify(mockAuthRepository.login(testParams)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure(message: 'Server error occurred');
      when(mockAuthRepository.login(testParams)).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await loginUseCase(testParams);

      // Assert
      expect(result, equals(const Left(failure)));
      verify(mockAuthRepository.login(testParams)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // Arrange
      const failure = NetworkFailure(message: 'No internet connection');
      when(mockAuthRepository.login(testParams)).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await loginUseCase(testParams);

      // Assert
      expect(result, equals(const Left(failure)));
      verify(mockAuthRepository.login(testParams)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });

  group('LoginParams', () {
    test('should be equal when properties are the same', () {
      // Arrange
      const params1 = LoginParams(email: 'test@example.com', password: 'password');
      const params2 = LoginParams(email: 'test@example.com', password: 'password');

      // Assert
      expect(params1, equals(params2));
      expect(params1.hashCode, equals(params2.hashCode));
    });

    test('should not be equal when properties are different', () {
      // Arrange
      const params1 = LoginParams(email: 'test@example.com', password: 'password1');
      const params2 = LoginParams(email: 'test@example.com', password: 'password2');

      // Assert
      expect(params1, isNot(equals(params2)));
    });

    test('should have correct props', () {
      // Arrange
      const params = LoginParams(email: 'test@example.com', password: 'password');

      // Assert
      expect(params.props, equals(['test@example.com', 'password']));
    });
  });
}
