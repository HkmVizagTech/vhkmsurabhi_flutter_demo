// lib/core/utils/app_bar_actions.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/routes/app_navigator.dart';

class AppBarActions {
  // Common Logout Button
  static Widget logoutButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Logout',
      onPressed: () {
        BlocProvider.of<AuthBloc>(context).add(LogoutRequested());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logging out...')));
      },
    );
  }

  static Widget loginButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.login),
      tooltip: 'Login',
      onPressed: () {
        AppNavigator.navigateToLogin(context);
      },
    );
  }

  // Example: General settings button (could be conditional)
  static Widget generalSettingsButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      tooltip: 'Settings',
      onPressed: () {
        // Navigate to general settings
        // context.go('/settings');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('General Settings')));
      },
    );
  }
}
