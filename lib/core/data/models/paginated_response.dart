// lib/core/data/models/paginated_response.dart

import 'package:json_annotation/json_annotation.dart';

part 'paginated_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> items;
  final PaginationMeta meta;

  const PaginatedResponse({required this.items, required this.meta});

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) => _$PaginatedResponseToJson(this, toJsonT);
}

@JsonSerializable()
class PaginationMeta {
  final int page;
  final int size;
  final int total;
  final int pages;
  @JsonKey(name: 'has_next')
  final bool hasNext;
  @JsonKey(name: 'has_prev')
  final bool hasPrev;

  const PaginationMeta({
    required this.page,
    required this.size,
    required this.total,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => _$PaginationMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}
