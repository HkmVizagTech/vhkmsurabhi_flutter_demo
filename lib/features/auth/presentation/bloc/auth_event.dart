// lib/features/auth/presentation/bloc/auth_event.dart

part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});
}

class LogoutRequested extends AuthEvent {}

/// Dev-only bypass: skips the real login API call (which has no backend to
/// talk to yet) and signs straight in as a fake user with the given [role],
/// so the role-based dashboards can be built/reviewed without a server.
class DevBypassLoginRequested extends AuthEvent {
  final String role;

  const DevBypassLoginRequested({required this.role});

  @override
  List<Object> get props => [role];
}
