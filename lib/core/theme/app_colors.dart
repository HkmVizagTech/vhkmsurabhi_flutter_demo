// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Common colors
  static const Color primaryColor = Color(0xFF4A148C);
  static const Color secondaryColor = Color(0xFF673AB7);
  static const Color accentColor = Color(0xFFFFC107);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onAccent = Colors.black;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFBC02D);
  static const Color infoColor = Color(0xFF1976D2);

  // Role-specific colors
  static const Color adminColor = Color(0xFFD32F2F); // Red
  static const Color employeeColor = Color(0xFF1976D2); // Blue
  static const Color preacherColor = Color(0xFFFF9800); // Orange
  static const Color approverColor = Color(0xFF388E3C); // Green
  static const Color volunteerColor = Color(0xFF7B1FA2); // Purple
  static const Color defaultRoleColor = Color(0xFF757575); // Grey

  // Security/Status colors
  static const Color securityEnabledColor = Color(0xFF388E3C); // Green
  static const Color securityDisabledColor = Color(0xFF757575); // Grey

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightOnBackground = Colors.black87;
  static const Color lightSurface = Colors.white;
  static const Color lightOnSurface = Colors.black87;
  static const Color lightBorderColor = Color(0xFFBDBDBD); // grey[400]
  static const Color lightFocusBorder = Colors.blue;
  static const Color lightButton = Colors.blue;
  static const Color lightOnButton = Colors.white;
  static const Color lightTextColor = Color(0xFF333333);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkOnBackground = Colors.white70;
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Colors.white70;
  static const Color darkBorderColor = Color(0xFF424242); // grey[800]
  static const Color darkFocusBorder = Color(0xFF64B5F6); // lightBlue
  static const Color darkButton = Color(0xFF64B5F6);
  static const Color darkOnButton = Colors.black;
  static const Color darkTextColor = Colors.white;

  // Helper methods
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return adminColor;
      case 'employee':
        return employeeColor;
      case 'preacher':
        return preacherColor;
      case 'approver':
        return approverColor;
      case 'volunteer':
        return volunteerColor;
      default:
        return defaultRoleColor;
    }
  }

  static Color getSecurityColor(bool isEnabled) {
    return isEnabled ? securityEnabledColor : securityDisabledColor;
  }
}
