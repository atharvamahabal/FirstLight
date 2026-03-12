import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF08080F);
  static const bg2 = Color(0xFF0E0E1A);
  static const glass = Color(0x0BFFFFFF);
  static const glassBorder = Color(0x17FFFFFF);
  static const purple = Color(0xFF9B7FF4);
  static const purpleDark = Color(0xFF7C3AED);
  static const amber = Color(0xFFF5A623);
  static const amberDark = Color(0xFFD97706);
  static const mint = Color(0xFF3DE8A0);
  static const pink = Color(0xFFF472B6);
  static const text = Color(0xFFEEF0F8);
  static const textMuted = Color(0x73EEF0F8);
  static const textDim = Color(0x40EEF0F8);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.purple,
          secondary: AppColors.amber,
          surface: AppColors.bg2,
        ),
        useMaterial3: true,
      );
}
