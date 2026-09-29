// lib/core/mock/demo_identity.dart
//
// "Who is using the app" for the mock approval / DRM screens. The dev-bypass
// login only carries a role, so each role maps to one fixed demo person:
// the preacher is kCurrentPreacherCode, the approver is a member of the
// seeded "DCC Approver" level and the admin is the "Admin" level member.
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/constants/role_constants.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

class DemoIdentity {
  final String role;
  final String name;
  // Set only for a preacher: scopes donors to Donor.EnrolledBy
  final String? preacherCode;

  const DemoIdentity({required this.role, required this.name, this.preacherCode});

  bool get isAdmin => role == RoleConstants.admin;
  bool get isApprover => role == RoleConstants.approver;
  bool get isPreacher => role == RoleConstants.preacher;
  bool get isEmployee => role == RoleConstants.employee;

  factory DemoIdentity.forRole(String role) {
    switch (role.toLowerCase()) {
      case RoleConstants.admin:
        return const DemoIdentity(role: RoleConstants.admin, name: 'Temple President');
      case RoleConstants.approver:
        return const DemoIdentity(role: RoleConstants.approver, name: 'Radha Madhava Das');
      case RoleConstants.employee:
        return const DemoIdentity(role: RoleConstants.employee, name: 'Donor Care Office');
      case RoleConstants.volunteer:
        return const DemoIdentity(role: RoleConstants.volunteer, name: 'Volunteer');
      default:
        return const DemoIdentity(role: RoleConstants.preacher, name: kCurrentPreacherCode, preacherCode: kCurrentPreacherCode);
    }
  }

  /// Reads the logged-in role from AuthBloc (defaults to the demo preacher).
  static DemoIdentity of(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    return DemoIdentity.forRole(state is AuthAuthenticated ? state.user.role : RoleConstants.preacher);
  }
}

/// "just now", "5 min ago", "3 hours ago", "2 days ago"
String timeAgo(DateTime when, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(when);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return diff.inHours == 1 ? '1 hour ago' : '${diff.inHours} hours ago';
  final days = diff.inDays;
  if (days == 1) return 'yesterday';
  if (days < 60) return '$days days ago';
  return '${(days / 30).floor()} months ago';
}
