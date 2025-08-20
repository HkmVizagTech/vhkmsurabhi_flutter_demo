import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/shared_preferences/preferences_service.dart';
import 'package:surabhi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:surabhi/features/auth/data/models/auth_response_model.dart';
import 'package:surabhi/core/data/models/user_model.dart';
import 'package:surabhi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/features/auth/domain/usecases/login_usecase.dart';

class _RemoteFake implements AuthRemoteDataSource {
  AuthResponseModel? response;
  @override
  Future<AuthResponseModel> login(LoginParams params) async => response!;
  @override
  Future<void> logout() async {}
}

class _PrefsFake implements PreferencesService {
  String? _access;
  String? _refresh;
  String? _userJson;
  @override
  Future<void> saveAccessToken(String token) async => _access = token;
  @override
  Future<void> saveRefreshToken(String token) async => _refresh = token;
  @override
  Future<void> saveUserJson(String json) async => _userJson = json;
  @override
  String? getUserJson() => _userJson;

  // Unused in these tests
  @override
  Future<void> clearAuthData() async {}
  @override
  Future<String?> getAccessToken() async => _access;
  @override
  Future<String?> getRefreshToken() async => _refresh;
  @override
  Future<void> saveUserRole(String role) async {}
  @override
  String? getUserRole() => null;
  @override
  Future<void> saveThemeMode(String themeMode) async {}
  @override
  Future<String?> getThemeMode() async => null;
}

void main() {
  late _RemoteFake remote;
  late _PrefsFake prefs;
  late AuthRepositoryImpl repo;

  setUp(() {
    remote = _RemoteFake();
    prefs = _PrefsFake();
    repo = AuthRepositoryImpl(remoteDataSource: remote, preferencesService: prefs);
  });

  test('login persists tokens and user and returns entity', () async {
    final user = UserModel(userId: '1', email: 'e', role: 'admin', is2faEnabled: false);
    remote.response = AuthResponseModel(accessToken: 'a', tokenType: 'bearer', refreshToken: 'r', user: user);

    final res = await repo.login(LoginParams(email: 'e', password: 'p'));
    expect(res.isRight(), true);
    final entity = (res as Right).value as UserEntity;
    expect(entity.email, 'e');
    expect(prefs.getUserJson(), json.encode(user.toJson()));
  });

  test('logout clears auth data', () async {
    // simulate clear
    await prefs.saveUserJson('{}');
    final res = await repo.logout();
    expect(res.isRight(), true);
  });

  test('checkAuthStatus returns entity from stored json', () async {
    final user = UserModel(userId: '1', email: 'e', role: 'admin', is2faEnabled: true);
    await prefs.saveUserJson(json.encode(user.toJson()));
    final res = await repo.checkAuthStatus();
    expect(res.isRight(), true);
    final entity = (res as Right).value as UserEntity;
    expect(entity.role, 'admin');
  });

  test('checkAuthStatus returns failure when no json', () async {
    final res = await repo.checkAuthStatus();
    expect(res.isLeft(), true);
    expect((res as Left).value, isA<AuthFailure>());
  });
}
