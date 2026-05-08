import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF00FF88);
  static const Color primaryDark = Color(0xFF00CC6A);
  static const Color primaryLight = Color(0xFF66FFB8);
  static const Color primaryGlow = Color(0x4000FF88);

  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF111111);
  static const Color surfaceVariant = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF222222);

  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceMuted = Color(0xFF888888);
  static const Color onSurfaceDim = Color(0xFF555555);

  static const Color border = Color(0xFF222222);
  static const Color borderLight = Color(0xFF333333);

  static const Color error = Color(0xFFFF4444);
  static const Color errorLight = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF00FF88);
  static const Color warning = Color(0xFFFFB800);
  static const Color info = Color(0xFF4FC3F7);

  static const Color gold = Color(0xFFFFD700);
  static const Color premium = Color(0xFFFFB800);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00FF88), Color(0xFF00CC6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF0A0A0A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF111111)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glowGradient = LinearGradient(
    colors: [Color(0x8000FF88), Color(0x0000FF88)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static BoxDecoration get glassMorphism => BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33FFFFFF), width: 1),
      );

  static BoxDecoration get primaryGlowDecoration => BoxDecoration(
        boxShadow: [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
      );
}
