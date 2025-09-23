import 'package:flutter/material.dart';

class AppThemes {
  // Primary color scheme
  static const Color primaryBlue = Color(0xFF667eea);
  static const Color primaryPurple = Color(0xFF764ba2);
  static const Color accentGreen = Color(0xFF00FF75);
  static const Color accentPurple = Color(0xFF3700FF);

  // Light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: primaryPurple,
        onSecondary: Colors.white,
        tertiary: primaryBlue,
        onTertiary: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF1C1B1F),
        background: Color(0xFFFFFBFE),
        onBackground: Color(0xFF1C1B1F),
        error: Color(0xFFB3261E),
        onError: Colors.white,
        outline: Color(0xFF79747E),
        outlineVariant: Color(0xFFCAC4D0),
        surfaceVariant: Color(0xFFE7E0EC),
        onSurfaceVariant: Color(0xFF49454F),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFBFE),
        foregroundColor: Color(0xFF1C1B1F),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F7F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Color(0xFF79747E),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Dark theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: primaryPurple,
        onSecondary: Colors.white,
        tertiary: primaryBlue,
        onTertiary: Colors.white,
        surface: Color(0xFF1C1B1F),
        onSurface: Color(0xFFE6E1E5),
        background: Color(0xFF0F0F0F),
        onBackground: Color(0xFFE6E1E5),
        error: Color(0xFFF2B8B5),
        onError: Color(0xFF601410),
        outline: Color(0xFF938F99),
        outlineVariant: Color(0xFF49454F),
        surfaceVariant: Color(0xFF49454F),
        onSurfaceVariant: Color(0xFFCAC4D0),
      ),
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: Color(0xFF1C1B1F),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F0F0F),
        foregroundColor: Color(0xFFE6E1E5),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2B2B2B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3F3F3F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3F3F3F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1C1B1F),
        selectedItemColor: primaryBlue,
        unselectedItemColor: Color(0xFF938F99),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Gradient definitions
  static const LinearGradient creditCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryPurple, primaryBlue],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGreen, accentPurple],
    stops: [0.0, 1.0],
  );
}