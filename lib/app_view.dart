import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/data/theme_provider.dart';
import 'package:expense_tracker/screens/auth/views/auth_wrapper.dart';

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
        background: Colors.grey.shade100,
        surface: Colors.white,
        onBackground: Colors.black,
        onSurface: Colors.black,
        primary: const Color(0xFF00B2E7),
        secondary: const Color(0xFFE064F7),
        tertiary: const Color(0xFFFF8D6C),
        outline: Colors.grey,
        outlineVariant: Colors.grey.shade300,
      ),
      cardColor: Colors.white,
      scaffoldBackgroundColor: Colors.grey.shade100,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00B2E7),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        background: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E),
        onBackground: Colors.white,
        onSurface: Colors.white,
        primary: const Color(0xFF00B2E7),
        secondary: const Color(0xFFE064F7),
        tertiary: const Color(0xFFFF8D6C),
        outline: Colors.grey.shade600,
        outlineVariant: Colors.grey.shade700,
      ),
      cardColor: const Color(0xFF1E1E1E),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00B2E7),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}