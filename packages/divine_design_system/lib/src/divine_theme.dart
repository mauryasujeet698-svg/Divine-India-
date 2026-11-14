import 'package:flutter/material.dart';

abstract final class DivineColors {
  static const Color saffron = Color(0xFFE87922);
  static const Color saffronDark = Color(0xFFC65D18);
  static const Color maroon = Color(0xFF5A1827);
  static const Color maroonDark = Color(0xFF3D101B);
  static const Color templeGold = Color(0xFFC99A3B);
  static const Color ivory = Color(0xFFFFF8ED);
  static const Color sand = Color(0xFFF3E7D5);
  static const Color surface = Color(0xFFFFFCF7);
  static const Color ink = Color(0xFF2B211B);
  static const Color muted = Color(0xFF7C6A5B);
  static const Color border = Color(0xFFE8DCCB);
  static const Color success = Color(0xFF28734E);
  static const Color warning = Color(0xFF9A6418);
}

abstract final class DivineTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: DivineColors.saffron,
      brightness: Brightness.light,
      primary: DivineColors.saffron,
      secondary: DivineColors.maroon,
      surface: DivineColors.surface,
      error: const Color(0xFFB3261E),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DivineColors.ivory,
      appBarTheme: const AppBarTheme(
        backgroundColor: DivineColors.ivory,
        foregroundColor: DivineColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: DivineColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardTheme(
        color: DivineColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: DivineColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DivineColors.surface,
        hintStyle: const TextStyle(color: DivineColors.muted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DivineColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DivineColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DivineColors.saffron, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DivineColors.saffron,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DivineColors.maroon,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: DivineColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DivineColors.surface,
        indicatorColor: DivineColors.sand,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? DivineColors.maroon
                : DivineColors.muted,
          ),
        ),
      ),
      dividerColor: DivineColors.border,
    );
  }
}
