// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand palette - taken from the Vaikuntham donor app
  // (hare_krishna_community_app lib/services/theme.dart) so both apps read
  // as one family: gold primary, golden accent, dark ink text, cream
  // surfaces and a deep-red highlight.
  static const Color gold = Color(0xFFB8860B); // Vaikuntham primaryColor / themeBrown
  static const Color golden = Color(0xFFC9A227); // goldenColor
  static const Color goldenDark = Color(0xFFA9821F); // goldenColor2
  static const Color ink = Color(0xFF101828); // themeDarkBlue
  static const Color cream = Color(0xFFF4ECC8); // themeLightCream
  static const Color beige = Color(0xFFF2E6B9); // themeBeige
  static const Color creamLight = Color(0xFFFAF6E6); // bg gradient end
  static const Color creamDeep = Color(0xFFF2E6B8); // bg gradient start
  static const Color deepRed = Color(0xFF7C0B0B); // themeDeepRed
  static const Color vaikunthamBlue = Color(0xFF1A398C); // blueColor
  static const Color vaikunthamBrown = Color(0xFFB5451E); // brownColor

  static const Color primaryColor = gold;
  static const Color secondaryColor = golden;
  static const Color accentColor = deepRed;
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onAccent = Colors.white;
  static const Color errorColor = Color(0xFFC62828);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color warningColor = Color(0xFFB7791F);
  static const Color infoColor = vaikunthamBlue;

  // Role accents, kept inside the same warm family
  static const Color adminColor = deepRed;
  static const Color employeeColor = vaikunthamBlue;
  static const Color preacherColor = gold;
  static const Color approverColor = Color(0xFF2E7D32);
  static const Color volunteerColor = vaikunthamBrown;
  static const Color defaultRoleColor = Color(0xFF6B7280);

  // Security/Status colors
  static const Color securityEnabledColor = Color(0xFF2E7D32);
  static const Color securityDisabledColor = Color(0xFF6B7280);

  // Light theme (default)
  static const Color lightBackground = creamLight;
  static const Color lightOnBackground = ink;
  static const Color lightSurface = Colors.white;
  static const Color lightOnSurface = ink;
  static const Color lightBorderColor = Color(0xFFE6D9A8); // warm beige border
  static const Color lightFocusBorder = gold;
  static const Color lightButton = gold;
  static const Color lightOnButton = Colors.white;
  static const Color lightTextColor = ink;
  static const Color lightAppBar = cream;

  // Dark theme (opt-in from Settings)
  static const Color darkBackground = Color(0xFF14110A);
  static const Color darkOnBackground = Colors.white70;
  static const Color darkSurface = Color(0xFF221D12);
  static const Color darkOnSurface = Colors.white70;
  static const Color darkBorderColor = Color(0xFF4A3F22);
  static const Color darkFocusBorder = golden;
  static const Color darkButton = golden;
  static const Color darkOnButton = Colors.black;
  static const Color darkTextColor = Colors.white;

  // Cream page background, same as Vaikuntham's bgLightLinearGradient
  static const LinearGradient creamGradient = LinearGradient(
    colors: [creamDeep, creamLight],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

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
