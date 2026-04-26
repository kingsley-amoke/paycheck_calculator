import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

final lightTheme = ThemeData(
  fontFamily: 'SF Pro Display',
  useMaterial3: true,
  brightness: Brightness.light,

  scaffoldBackgroundColor: AppColors.background,

  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.primaryLight,
    onSecondary: Colors.white,
    error: AppColors.red,
    onError: Colors.white,
    surface: AppColors.cardBg,
    onSurface: AppColors.textDark,
  ),

  cardColor: AppColors.cardBg,
  dividerColor: AppColors.divider,

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textDark),
    bodyMedium: TextStyle(color: AppColors.textGray),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.textDark,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

final darkTheme = ThemeData(
  fontFamily: 'SF Pro Display',
  useMaterial3: true,
  brightness: Brightness.dark,

  scaffoldBackgroundColor: DarkAppColors.background,

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: DarkAppColors.primary,
    onPrimary: Colors.white,
    secondary: DarkAppColors.primaryLight,
    onSecondary: Colors.white,
    error: DarkAppColors.red,
    onError: Colors.black,
    surface: DarkAppColors.cardBg,
    onSurface: DarkAppColors.textDark,
  ),

  cardColor: DarkAppColors.cardBg,
  dividerColor: DarkAppColors.divider,

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: DarkAppColors.textDark),
    bodyMedium: TextStyle(color: DarkAppColors.textGray),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: DarkAppColors.background,
    foregroundColor: DarkAppColors.textDark,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DarkAppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
