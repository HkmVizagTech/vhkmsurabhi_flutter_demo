// lib/routes/app_navigator.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

class AppNavigator {
  AppNavigator._();

  static void navigateBasedOnRole(BuildContext context, String role) {
    String path;
    switch (role) {
      case 'admin':
        path = '/admin-dashboard';
        break;
      case 'employee':
        path = '/employee-dashboard';
        break;
      case 'preacher':
        path = '/preacher-dashboard';
        break;
      case 'approver':
        path = '/approver-dashboard';
        break;
      case 'volunteer':
        path = '/volunteer-dashboard';
        break;
      default:
        path = '/home'; // Fallback to a generic home page
        break;
    }
    context.go(path);
  }

  // Navigate to login
  static void navigateToLogin(BuildContext context) {
    context.go('/login');
  }

  // Navigate to settings
  static void navigateToSettings(BuildContext context) {
    context.push('/settings');
  }

  // Navigate to create user (admin only)
  static void navigateToCreateUser(BuildContext context) {
    context.push('/admin/create-user');
  }

  // Navigate back if possible, or to a default path
  static void navigateBackOrHome(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home'); // Or to a sensible default if no previous page
    }
  }

  // Get role-specific menu items
  static List<String> getRoleSpecificMenuItems(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return ['User Management', 'Register User'];
      case 'employee':
        return ['My Tasks'];
      case 'preacher':
        return ['Sermons'];
      case 'approver':
        return ['Pending Approvals'];
      case 'volunteer':
        return ['Activities'];
      default:
        return [];
    }
  }

  // A more robust initial navigation based on BLoC state
  static void navigateOnAuthChange(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      AppNavigator.navigateBasedOnRole(context, state.user.role);
    } else if (state is AuthUnauthenticated) {
      AppNavigator.navigateToLogin(context);
    }
    // No action needed for AuthInitial or AuthLoading, those are transient.
    // AuthError usually shows a Snackbar, then might lead to unauthenticated or login.
  }
}
