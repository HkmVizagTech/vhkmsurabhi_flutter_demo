// lib/features/auth/data/models/auth_response_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:surabhi/core/data/models/user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  final UserModel user;

  AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
