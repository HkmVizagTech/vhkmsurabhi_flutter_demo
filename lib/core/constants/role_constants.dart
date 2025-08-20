// lib/core/constants/role_constants.dart

class RoleConstants {
  RoleConstants._();

  static const String admin = 'admin';
  static const String employee = 'employee';
  static const String preacher = 'preacher';
  static const String approver = 'approver';
  static const String volunteer = 'volunteer';

  static const List<String> roles = [admin, employee, preacher, approver, volunteer];

  static bool isValidRole(String role) {
    return roles.contains(role);
  }

  static String getRoleDisplayName(String role) {
    switch (role) {
      case admin:
        return 'Admin';
      case employee:
        return 'Employee';
      case preacher:
        return 'Preacher';
      case approver:
        return 'Approver';
      case volunteer:
        return 'Volunteer';
      default:
        return 'Unknown';
    }
  }
}
