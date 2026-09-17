// lib/core/theme/app_themes.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/theme/app_colors.dart';

const double _kRadius = 16.0;
const double _kCardRadius = 20.0;

const String _kBodyFont = 'Open Sans';
const String _kDisplayFont = 'Montserrat';

TextTheme _buildTextTheme(TextTheme base, Color heading, Color body) {
  return base
      .copyWith(
        displayLarge: base.displayLarge?.copyWith(fontFamily: _kDisplayFont, fontWeight: FontWeight.w700, color: heading),
        displayMedium: base.displayMedium?.copyWith(fontFamily: _kDisplayFont, fontWeight: FontWeight.w700, color: heading),
        displaySmall: base.displaySmall?.copyWith(fontFamily: _kDisplayFont, fontWeight: FontWeight.w700, color: heading),
        headlineLarge: base.headlineLarge?.copyWith(fontFamily: _kDisplayFont, fontWeight: FontWeight.w700, color: heading),
        headlineMedium: base.headlineMedium?.copyWith(fontFamily: _kDisplayFont, fontWeight: FontWeight.w700, color: heading),
        headlineSmall: base.headlineSmall?.copyWith(fontFamily: _kDisplayFont, fontWeight: FontWeight.w700, color: heading),
        titleLarge: base.titleLarge?.copyWith(fontFamily: _kDisplayFont, fontWeight: FontWeight.w700, color: heading),
        titleMedium: base.titleMedium?.copyWith(fontFamily: _kDisplayFont, fontWeight: FontWeight.w600, color: heading),
        titleSmall: base.titleSmall?.copyWith(fontFamily: _kDisplayFont, fontWeight: FontWeight.w600, color: heading),
      )
      .apply(fontFamily: _kBodyFont, bodyColor: body, displayColor: heading);
}

InputDecorationTheme _buildInputTheme({
  required Color fill,
  required Color enabledBorder,
  required Color focusedBorder,
}) {
  return InputDecorationTheme(
    filled: true,
    fillColor: fill,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(_kRadius), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kRadius),
      borderSide: BorderSide(color: enabledBorder, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kRadius),
      borderSide: BorderSide(color: focusedBorder, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kRadius),
      borderSide: const BorderSide(color: AppColors.errorColor, width: 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kRadius),
      borderSide: const BorderSide(color: AppColors.errorColor, width: 2.0),
    ),
    labelStyle: TextStyle(fontFamily: _kBodyFont, color: enabledBorder),
    hintStyle: TextStyle(fontFamily: _kBodyFont, color: enabledBorder),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  );
}

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: _kBodyFont,
  primaryColor: AppColors.primaryColor,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: AppColors.lightBackground,
  splashFactory: InkRipple.splashFactory,

  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryColor,
    secondary: AppColors.secondaryColor,
    tertiary: AppColors.accentColor,
    surface: AppColors.lightSurface,
    error: AppColors.errorColor,
    onPrimary: AppColors.onPrimary,
    onSecondary: AppColors.onSecondary,
    onSurface: AppColors.lightOnSurface,
  ),

  textTheme: _buildTextTheme(ThemeData.light().textTheme, AppColors.lightTextColor, AppColors.lightOnBackground),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: AppColors.onPrimary,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 2,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: _kDisplayFont,
      color: AppColors.onPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    ),
  ),

  inputDecorationTheme: _buildInputTheme(
    fill: AppColors.lightBackground,
    enabledBorder: AppColors.lightBorderColor,
    focusedBorder: AppColors.lightFocusBorder,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightButton,
      foregroundColor: AppColors.lightOnButton,
      disabledBackgroundColor: AppColors.lightButton.withValues(alpha: 0.4),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kRadius)),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      textStyle: const TextStyle(fontFamily: _kDisplayFont, fontSize: 16, fontWeight: FontWeight.w700),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kRadius)),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      textStyle: const TextStyle(fontFamily: _kDisplayFont, fontSize: 16, fontWeight: FontWeight.w700),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryColor,
      side: const BorderSide(color: AppColors.primaryColor, width: 1.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kRadius)),
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
      textStyle: const TextStyle(fontFamily: _kBodyFont, fontSize: 14, fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kRadius)),
      textStyle: const TextStyle(fontFamily: _kBodyFont, fontWeight: FontWeight.w600),
    ),
  ),

  snackBarTheme: const SnackBarThemeData(
    backgroundColor: AppColors.darkSurface,
    contentTextStyle: TextStyle(fontFamily: _kBodyFont, color: AppColors.darkTextColor),
    actionTextColor: AppColors.accentColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_kRadius))),
  ),

  cardTheme: CardThemeData(
    color: AppColors.lightSurface,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_kCardRadius),
      side: BorderSide(color: AppColors.lightBorderColor.withValues(alpha: 0.4)),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: AppColors.lightBackground,
    labelStyle: const TextStyle(fontFamily: _kBodyFont, fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kRadius)),
    side: BorderSide.none,
  ),

  dividerTheme: const DividerThemeData(color: AppColors.lightBorderColor, thickness: 1, space: 1),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? AppColors.secondaryColor : null,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? AppColors.secondaryColor.withValues(alpha: 0.4) : null,
    ),
  ),
);

// Define dark theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: _kBodyFont,
  primaryColor: AppColors.primaryColor,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: AppColors.darkBackground,
  splashFactory: InkRipple.splashFactory,

  colorScheme: const ColorScheme.dark(
    primary: AppColors.secondaryColor,
    secondary: AppColors.secondaryColor,
    tertiary: AppColors.accentColor,
    surface: AppColors.darkSurface,
    error: AppColors.errorColor,
    onPrimary: AppColors.darkOnButton,
    onSecondary: AppColors.onSecondary,
    onSurface: AppColors.darkOnSurface,
  ),

  textTheme: _buildTextTheme(ThemeData.dark().textTheme, AppColors.darkTextColor, AppColors.darkOnBackground),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    foregroundColor: AppColors.darkTextColor,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 2,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: _kDisplayFont,
      color: AppColors.darkTextColor,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    ),
  ),

  inputDecorationTheme: _buildInputTheme(
    fill: AppColors.darkBackground,
    enabledBorder: AppColors.darkBorderColor,
    focusedBorder: AppColors.darkFocusBorder,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkButton,
      foregroundColor: AppColors.darkOnButton,
      disabledBackgroundColor: AppColors.darkButton.withValues(alpha: 0.4),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kRadius)),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      textStyle: const TextStyle(fontFamily: _kDisplayFont, fontSize: 16, fontWeight: FontWeight.w700),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.darkButton,
      foregroundColor: AppColors.darkOnButton,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kRadius)),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      textStyle: const TextStyle(fontFamily: _kDisplayFont, fontSize: 16, fontWeight: FontWeight.w700),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.accentColor,
      side: const BorderSide(color: AppColors.accentColor, width: 1.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kRadius)),
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
      textStyle: const TextStyle(fontFamily: _kBodyFont, fontSize: 14, fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.accentColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kRadius)),
      textStyle: const TextStyle(fontFamily: _kBodyFont, fontWeight: FontWeight.w600),
    ),
  ),

  snackBarTheme: const SnackBarThemeData(
    backgroundColor: AppColors.lightSurface,
    contentTextStyle: TextStyle(fontFamily: _kBodyFont, color: AppColors.lightTextColor),
    actionTextColor: AppColors.secondaryColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_kRadius))),
  ),

  cardTheme: CardThemeData(
    color: AppColors.darkSurface,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black.withValues(alpha: 0.4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_kCardRadius),
      side: BorderSide(color: AppColors.darkBorderColor.withValues(alpha: 0.6)),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: AppColors.darkBackground,
    labelStyle: const TextStyle(fontFamily: _kBodyFont, fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kRadius)),
    side: BorderSide.none,
  ),

  dividerTheme: const DividerThemeData(color: AppColors.darkBorderColor, thickness: 1, space: 1),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? AppColors.secondaryColor : null,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? AppColors.secondaryColor.withValues(alpha: 0.4) : null,
    ),
  ),
);
