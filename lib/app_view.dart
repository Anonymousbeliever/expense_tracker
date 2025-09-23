import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/data/theme_provider.dart';
import 'package:expense_tracker/screens/auth/auth.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Expense Tracker',
          theme: _lightTheme(),
          darkTheme: _darkTheme(),
          themeMode: themeProvider.getIsDarkTheme ? ThemeMode.dark : ThemeMode.light,
          home: const AuthWrapper(),
        );
      },
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        background: Colors.grey.shade50,
        surface: Colors.white,
        onBackground: Colors.black87,
        onSurface: Colors.black87,
        primary: const Color(0xFF1E90FF), // Light blue
        secondary: const Color(0xFF6A0DAD), // Purple
        tertiary: const Color(0xFFFFA500), // Orange
        outline: Colors.grey.shade400,
        outlineVariant: Colors.grey.shade200,
        surfaceVariant: Colors.grey.shade100,
      ),
      cardColor: Colors.white,
      scaffoldBackgroundColor: Colors.grey.shade50,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E90FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        background: const Color(0xFF1F1F1F),
        surface: const Color(0xFF2C2C2C),
        onBackground: Colors.white70,
        onSurface: Colors.white70,
        primary: const Color(0xFF1E90FF), // Light blue
        secondary: const Color(0xFF6A0DAD), // Purple
        tertiary: const Color(0xFFFFA500), // Orange
        outline: Colors.grey.shade600,
        outlineVariant: Colors.grey.shade700,
        surfaceVariant: const Color(0xFF3A3A3A),
      ),
      cardColor: const Color(0xFF2C2C2C),
      scaffoldBackgroundColor: const Color(0xFF1F1F1F),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C2C2C),
        foregroundColor: Colors.white70,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E90FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        filled: true,
        fillColor: const Color(0xFF3A3A3A),
      ),
    );
  }
}