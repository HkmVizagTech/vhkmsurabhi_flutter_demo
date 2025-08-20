// lib/core/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_entity.g.dart';

@JsonSerializable()
class UserEntity extends Equatable {
  @JsonKey(name: 'id')
  final String userId;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  final String email;

  final String role;

  @JsonKey(name: 'is_2fa_enabled')
  final bool is2faEnabled;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  final String? image;

  const UserEntity({
    required this.userId,
    required this.email,
    required this.role,
    required this.is2faEnabled,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.image,
  });

  @override
  List<Object?> get props => [userId, firstName, lastName, email, phoneNumber, image, role, is2faEnabled];
}
