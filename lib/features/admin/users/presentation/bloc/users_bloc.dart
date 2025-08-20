// lib/features/admin/users/presentation/bloc/users_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/core/data/models/paginated_response.dart';
import 'package:surabhi/features/admin/users/domain/usecases/get_users_usecase.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase getUsersUseCase;
  DateTime? _lastRequestTime;
  static const _debounceDelay = Duration(milliseconds: 500);
  int _currentPageSize = 10; // Default page size (not final because it changes)

  UsersBloc({required this.getUsersUseCase}) : super(UsersInitial()) {
    on<GetUsersEvent>(_onGetUsers);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<ChangePageSizeEvent>(_onChangePageSize);
  }

  int get currentPageSize => _currentPageSize;

  Future<void> _onGetUsers(GetUsersEvent event, Emitter<UsersState> emit) async {
    // Debouncing: Prevent rapid successive calls
    final now = DateTime.now();
    if (_lastRequestTime != null && now.difference(_lastRequestTime!) < _debounceDelay) {
      print('🚫 Debouncing: Ignoring rapid successive GetUsersEvent');
      return;
    }
    _lastRequestTime = now;

    // Prevent multiple simultaneous requests
    if (state is UsersLoading) {
      print('🚫 Already loading: Ignoring GetUsersEvent');
      return;
    }

    print('📥 Processing GetUsersEvent: page=${event.page}, size=${event.size}');
    emit(UsersLoading());

    final result = await getUsersUseCase(page: event.page, size: event.size);
    result.fold(
      (failure) {
        print('❌ GetUsers failed: ${failure.message}');
        emit(UsersError(failure.message));
      },
      (paginatedUsers) {
        print('✅ GetUsers success: ${paginatedUsers.items.length} users loaded');
        emit(UsersLoaded(paginatedUsers));
      },
    );
  }

  Future<void> _onLoadMoreUsers(LoadMoreUsersEvent event, Emitter<UsersState> emit) async {
    final currentState = state;

    // Prevent multiple simultaneous load more requests
    if (currentState is UsersLoadingMore) {
      print('🚫 Already loading more: Ignoring LoadMoreUsersEvent');
      return;
    }

    if (currentState is UsersLoaded && currentState.paginatedUsers.meta.hasNext) {
      print('📥 Processing LoadMoreUsersEvent: page=${currentState.paginatedUsers.meta.page + 1}');
      emit(UsersLoadingMore(currentState.paginatedUsers));

      final result = await getUsersUseCase(page: currentState.paginatedUsers.meta.page + 1, size: event.size);

      result.fold(
        (failure) {
          print('❌ LoadMoreUsers failed: ${failure.message}');
          // On error, revert to the previous loaded state instead of showing error
          emit(UsersLoaded(currentState.paginatedUsers));
        },
        (newPaginatedUsers) {
          print('✅ LoadMoreUsers success: ${newPaginatedUsers.items.length} more users loaded');
          final allUsers = [...currentState.paginatedUsers.items, ...newPaginatedUsers.items];
          emit(UsersLoaded(PaginatedResponse(items: allUsers, meta: newPaginatedUsers.meta)));
        },
      );
    } else {
      print('🚫 Cannot load more: No more pages available');
    }
  }

  Future<void> _onChangePageSize(ChangePageSizeEvent event, Emitter<UsersState> emit) async {
    print('📏 Changing page size from $_currentPageSize to ${event.newSize}');

    // Update the current page size
    _currentPageSize = event.newSize;

    // Reset to first page with new page size
    print('📥 Fetching first page with new size: ${event.newSize}');
    emit(UsersLoading());

    final result = await getUsersUseCase(page: 1, size: event.newSize);
    result.fold(
      (failure) {
        print('❌ ChangePageSize failed: ${failure.message}');
        emit(UsersError(failure.message));
      },
      (paginatedUsers) {
        print('✅ ChangePageSize success: ${paginatedUsers.items.length} users loaded with size ${event.newSize}');
        emit(UsersLoaded(paginatedUsers));
      },
    );
  }
}
