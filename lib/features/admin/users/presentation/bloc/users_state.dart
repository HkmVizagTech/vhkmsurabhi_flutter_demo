// lib/features/admin/users/presentation/bloc/users_state.dart

part of 'users_bloc.dart';

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoadingMore extends UsersState {
  final PaginatedResponse<UserEntity> paginatedUsers;

  const UsersLoadingMore(this.paginatedUsers);

  @override
  List<Object> get props => [paginatedUsers];
}

class UsersLoaded extends UsersState {
  final PaginatedResponse<UserEntity> paginatedUsers;

  const UsersLoaded(this.paginatedUsers);

  @override
  List<Object> get props => [paginatedUsers];
}

class UsersError extends UsersState {
  final String message;

  const UsersError(this.message);

  @override
  List<Object> get props => [message];
}
