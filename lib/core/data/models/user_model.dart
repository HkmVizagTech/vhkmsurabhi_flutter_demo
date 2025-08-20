// lib/core/data/models/user_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const UserModel({
    required super.userId,
    required super.email,
    required super.role,
    required super.is2faEnabled,
    super.firstName,
    super.lastName,
    super.phoneNumber,
    super.image,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [userId, firstName, lastName, email, phoneNumber, image, role, is2faEnabled];
}
