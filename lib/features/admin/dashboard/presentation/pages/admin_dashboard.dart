// lib/features/admin/dashboard/presentation/pages/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/features/admin/users/presentation/bloc/users_bloc.dart' as admin_users;
import 'package:surabhi/features/admin/users/presentation/pages/users_list_page.dart';
import 'package:surabhi/injector.dart' as di;

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<admin_users.UsersBloc>()..add(const admin_users.GetUsersEvent()),
      child: const UsersListPage(),
    );
  }
}
