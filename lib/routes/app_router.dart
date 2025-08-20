// lib/routes/app_router.dart

import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:surabhi/features/auth/presentation/pages/login_page.dart';
import 'package:surabhi/features/home/presentation/pages/home_page.dart';
import 'package:surabhi/features/admin/dashboard/presentation/pages/admin_dashboard.dart';
import 'package:surabhi/features/employee/dashboard/presentation/pages/employee_dashboard.dart';
import 'package:surabhi/features/preacher/dashboard/presentation/pages/preacher_dashboard.dart';
import 'package:surabhi/features/approver/dashboard/presentation/pages/approver_dashboard.dart';
import 'package:surabhi/features/volunteer/dashboard/presentation/pages/volunteer_dashboard.dart';
import 'package:surabhi/features/admin/users/presentation/pages/create_user_page.dart';
import 'package:surabhi/features/auth/presentation/pages/twofa_choice_page.dart';
import 'package:surabhi/features/auth/presentation/pages/twofa_verify_page.dart';
import 'package:surabhi/features/settings/presentation/pages/settings_page.dart';

// Create a custom ChangeNotifier to listen to the AuthBloc stream
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Your app's router
class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  GoRouter get router => _goRouter;
  late final GoRouter _goRouter = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/home', name: 'home', builder: (context, state) => const HomePage()),
      GoRoute(path: '/2fa/choice', name: 'twofa-choice', builder: (context, state) => const TwoFAChoicePage()),
      GoRoute(path: '/2fa/verify', name: 'twofa-verify', builder: (context, state) => const TwoFAVerifyPage()),
      GoRoute(path: '/admin-dashboard', name: 'admin-dashboard', builder: (context, state) => const AdminDashboard()),
      GoRoute(
        path: '/employee-dashboard',
        name: 'employee-dashboard',
        builder: (context, state) => const EmployeeDashboard(),
      ),
      GoRoute(
        path: '/preacher-dashboard',
        name: 'preacher-dashboard',
        builder: (context, state) => const PreacherDashboard(),
      ),
      GoRoute(
        path: '/approver-dashboard',
        name: 'approver-dashboard',
        builder: (context, state) => const ApproverDashboard(),
      ),
      GoRoute(
        path: '/volunteer-dashboard',
        name: 'volunteer-dashboard',
        builder: (context, state) => const VolunteerDashboard(),
      ),
      GoRoute(
        path: '/admin/create-user',
        name: 'admin-create-user',
        builder: (context, state) => const CreateUserPage(),
      ),
      GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsPage()),
    ],
    // Tell GoRouter to listen to the AuthBloc's stream for state changes
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state; // Access the bloc instance directly

      final bool isAuthenticated = authState is AuthAuthenticated;
      final bool isUnauthenticated = authState is AuthUnauthenticated;
      final bool isLoading = authState is AuthLoading || authState is AuthInitial;

      final String? loggedInRole = isAuthenticated ? (authState).user.role : null;
      final bool require2FA = isAuthenticated && (authState).user.is2faEnabled;

      const publicPaths = ['/login', '/', '/home'];
      final bool isGoingToPublicPath = publicPaths.contains(state.fullPath);

      // 1. If still loading auth state, don't redirect yet
      if (isLoading) return null;

      // 2. If unauthenticated: allow access to public paths, redirect protected routes to home
      if (isUnauthenticated) {
        if (!isGoingToPublicPath) {
          return '/'; // Redirect to home page instead of login
        }
      }

      // 3. If authenticated and trying to go to a public path, redirect to their dashboard
      if (isAuthenticated && isGoingToPublicPath) {
        return _getDashboardPathForRole(loggedInRole);
      }

      // 4. 2FA gating: if required and not on a 2FA route, redirect to choice page
      if (require2FA && !(state.fullPath?.startsWith('/2fa') ?? false)) {
        return '/2fa/choice';
      }

      return null; // No redirect needed
    },
  );
}

String _getDashboardPathForRole(String? role) {
  switch (role) {
    case 'admin':
      return '/admin-dashboard';
    case 'employee':
      return '/employee-dashboard';
    case 'preacher':
      return '/preacher-dashboard';
    case 'approver':
      return '/approver-dashboard';
    case 'volunteer':
      return '/volunteer-dashboard';
    default:
      return '/home';
  }
}
