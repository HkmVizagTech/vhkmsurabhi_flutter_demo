// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Home',
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return _buildAuthenticatedHome(context, authState.user);
          } else {
            return _buildUnauthenticatedHome(context);
          }
        },
      ),
    );
  }

  Widget _buildUnauthenticatedHome(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Welcome to Surabhi',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'A comprehensive role-based management system for organizations.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.login),
              label: const Text('Login to Continue'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedHome(BuildContext context, dynamic user) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Welcome back, ${user.firstName ?? user.email}!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You are logged in as ${user.role.toUpperCase()}',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToDashboard(context, user.role),
              icon: const Icon(Icons.dashboard),
              label: const Text('Go to Dashboard'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context, String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        context.go('/admin-dashboard');
        break;
      case 'employee':
        context.go('/employee-dashboard');
        break;
      case 'preacher':
        context.go('/preacher-dashboard');
        break;
      case 'approver':
        context.go('/approver-dashboard');
        break;
      case 'volunteer':
        context.go('/volunteer-dashboard');
        break;
      default:
        context.go('/');
    }
  }
}
