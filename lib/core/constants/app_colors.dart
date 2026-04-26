import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFEDF2F7);
  static const primary = Color(0xFF3730D8);
  static const primaryLight = Color(0xFF6C63FF);
  static const primaryContainer = Color(0xFF4F46E5);
  static const secondary = Color(0xFF006E2D);
  static const green = Color(0xFF22C55E);
  static const darkGreen = Color(0xFF16A34A);
  static const red = Color(0xFFEF4444);
  static const orange = Color(0xFFF97316);
  static const blue = Color(0xFF3B82F6);
  static const purple = Color(0xFFA855F7);
  static const textDark = Color(0xFF111827);
  static const textGray = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);
  static const cardBg = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE5E7EB);

  static const secondaryContainer = Color(0xFF7CF994);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerHigh = Color(0xFFE7E8E9);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF464555);
  static const outlineVariant = Color(0xFFC7C4D8);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onPrimaryFixedVariant = Color(0xFF3323CC);
}

class DarkAppColors {
  static const background = Color(0xFF0F172A); // deep slate
  static const primary = Color(0xFF6366F1); // slightly softer indigo
  static const primaryLight = Color(0xFF818CF8);

  static const green = Color(0xFF4ADE80);
  static const darkGreen = Color(0xFF22C55E);

  static const red = Color(0xFFF87171);
  static const orange = Color(0xFFFB923C);
  static const blue = Color(0xFF60A5FA);
  static const purple = Color(0xFFC084FC);

  static const textDark = Color(0xFFF9FAFB); // near white
  static const textGray = Color(0xFFCBD5F5);
  static const textLight = Color(0xFF94A3B8);

  static const cardBg = Color(0xFF1E293B); // elevated surface
  static const divider = Color(0xFF334155);
}

Map<String, Color> taxColors = {
  "Gross Income": Colors.green,
  "Income Tax": Colors.red,
  "Federal Tax": Colors.red,
  "State Tax": Colors.orange,
  "Social Security": Colors.blue,
  "Medicare": Colors.purple,
};

Map<String, Color> darkTaxColors = {
  "Gross Income": Color(0xFF4ADE80),
  "Income Tax": Color(0xFFF87171),
  "Federal Tax": Color(0xFFF87171),
  "State Tax": Color(0xFFFB923C),
  "Social Security": Color(0xFF60A5FA),
  "Medicare": Color(0xFFC084FC),
};
