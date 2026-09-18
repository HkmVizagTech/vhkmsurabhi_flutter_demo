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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final authenticated = authState is AuthAuthenticated;
        return AppScaffold(
          title: 'Home',
          // The welcome hero image already carries the brand header, so the
          // unauthenticated landing screen skips the top app bar to match
          // the original app's immersive welcome screen.
          showAppBar: authenticated,
          body: authenticated ? _buildAuthenticatedHome(context, authState.user) : _buildUnauthenticatedHome(context),
        );
      },
    );
  }

  Widget _buildBrandMark(ThemeData theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.secondary, width: 3),
        boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 10))],
        image: const DecorationImage(image: AssetImage('lib/assets/logos/logo.png'), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildUnauthenticatedHome(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            child: Image.asset(
              'lib/assets/images/Welcome_Screen.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  'A comprehensive role-based management system for organizations.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Login to Continue'),
                  ),
                ),
              ],
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBrandMark(theme),
            const SizedBox(height: 28),
            Text(
              'Welcome back, ${user.firstName ?? user.email}!',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: 12),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _navigateToDashboard(context, user.role),
                icon: const Icon(Icons.dashboard_rounded),
                label: const Text('Go to Dashboard'),
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
