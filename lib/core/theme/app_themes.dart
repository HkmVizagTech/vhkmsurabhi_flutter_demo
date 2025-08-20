// lib/core/theme/app_themes.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/theme/app_colors.dart';

final ThemeData lightTheme = ThemeData(
  primaryColor: AppColors.primaryColor,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: AppColors.lightBackground,

  // Define light color scheme
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryColor,
    secondary: AppColors.secondaryColor,
    surface: AppColors.lightSurface,
    error: AppColors.errorColor,
    onPrimary: AppColors.onPrimary,
    onSecondary: AppColors.onSecondary,
    onSurface: AppColors.lightOnSurface,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: AppColors.onPrimary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(color: AppColors.onPrimary, fontSize: 20, fontWeight: FontWeight.bold),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightSurface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.lightFocusBorder, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.lightBorderColor, width: 1.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.errorColor, width: 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.errorColor, width: 2.0),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightButton,
      foregroundColor: AppColors.lightOnButton,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),

  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor)),

  snackBarTheme: const SnackBarThemeData(
    backgroundColor: AppColors.darkSurface,
    contentTextStyle: TextStyle(color: AppColors.darkTextColor),
    actionTextColor: AppColors.primaryColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
  ),

  cardTheme: const CardThemeData(
    color: AppColors.lightSurface,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  dividerTheme: const DividerThemeData(color: AppColors.lightBorderColor, thickness: 1, space: 1),
);

// Define dark theme
final ThemeData darkTheme = ThemeData(
  primaryColor: AppColors.primaryColor,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: AppColors.darkBackground,

  // Define dark color scheme
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryColor,
    secondary: AppColors.secondaryColor,
    surface: AppColors.darkSurface,
    error: AppColors.errorColor,
    onPrimary: AppColors.onPrimary,
    onSecondary: AppColors.onSecondary,
    onSurface: AppColors.darkOnSurface,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.onPrimary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(color: AppColors.darkTextColor, fontSize: 20, fontWeight: FontWeight.bold),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkSurface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.darkFocusBorder, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.darkBorderColor, width: 1.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.errorColor, width: 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.errorColor, width: 2.0),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkButton,
      foregroundColor: AppColors.darkOnButton,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),

  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor)),

  snackBarTheme: const SnackBarThemeData(
    backgroundColor: AppColors.lightSurface,
    contentTextStyle: TextStyle(color: AppColors.lightTextColor),
    actionTextColor: AppColors.primaryColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
  ),

  cardTheme: const CardThemeData(
    color: AppColors.darkSurface,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  dividerTheme: const DividerThemeData(color: AppColors.darkBorderColor, thickness: 1, space: 1),
);
