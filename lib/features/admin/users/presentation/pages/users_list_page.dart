// lib/features/admin/users/presentation/pages/users_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/core/widgets/pagination_controls.dart';
import 'package:surabhi/core/widgets/user_card.dart';
import 'package:surabhi/core/widgets/error_display.dart';
import 'package:surabhi/features/admin/users/presentation/bloc/users_bloc.dart';
import 'package:surabhi/features/admin/users/presentation/pages/user_details_page.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';

class UsersListPage extends StatelessWidget {
  const UsersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'User Management',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     const Text('Users', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            //     ElevatedButton(onPressed: () => context.push('/admin/create-user'), child: const Text('Register User')),
            //   ],
            // ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<UsersBloc, UsersState>(
                builder: (context, state) {
                  if (state is UsersInitial) {
                    context.read<UsersBloc>().add(const GetUsersEvent());
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UsersLoaded) {
                    return Column(
                      children: [
                        Expanded(child: _buildUsersList(state.paginatedUsers.items)),
                        BlocBuilder<UsersBloc, UsersState>(
                          builder: (context, paginationState) {
                            final bloc = context.read<UsersBloc>();
                            return PaginationControls(
                              meta: state.paginatedUsers.meta,
                              currentPageSize: bloc.currentPageSize,
                              onPrevious: state.paginatedUsers.meta.hasPrev
                                  ? () => bloc.add(
                                      GetUsersEvent(
                                        page: state.paginatedUsers.meta.page - 1,
                                        size: bloc.currentPageSize,
                                      ),
                                    )
                                  : null,
                              onNext: state.paginatedUsers.meta.hasNext
                                  ? () => bloc.add(
                                      GetUsersEvent(
                                        page: state.paginatedUsers.meta.page + 1,
                                        size: bloc.currentPageSize,
                                      ),
                                    )
                                  : null,
                              onPageSelected: (page) => bloc.add(GetUsersEvent(page: page, size: bloc.currentPageSize)),
                              onPageSizeChanged: (newSize) => bloc.add(ChangePageSizeEvent(newSize: newSize)),
                            );
                          },
                        ),
                      ],
                    );
                  } else if (state is UsersError) {
                    return ErrorDisplay(
                      message: state.message,
                      onRetry: () => context.read<UsersBloc>().add(const GetUsersEvent()),
                      icon: Icons.people_outline,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(List<UserEntity> users) {
    if (users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserCard(
          user: user,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserDetailsPage(user: user)));
          },
        );
      },
    );
  }
}
