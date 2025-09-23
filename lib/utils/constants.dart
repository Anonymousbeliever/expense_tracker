import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Expense Tracker';
  static const String appVersion = '1.0.0';

  // Budget and Financial Constants
  static const double defaultMonthlyBudget = 5194.00;
  static const String defaultCurrency = 'KSH';
  static const String currencySymbol = 'KSH';

  // Time Filters
  static const String filter7Days = '7 Days';
  static const String filter30Days = '30 Days';
  static const List<String> timeFilters = [filter7Days, filter30Days];

  // Expense Categories with Icons and Colors
  static const Map<String, Map<String, dynamic>> expenseCategories = {
    'Food': {
      'icon': CupertinoIcons.cart_fill,
      'color': Colors.orange,
      'description': 'Meals, groceries, dining out',
    },
    'Transportation': {
      'icon': CupertinoIcons.car_fill,
      'color': Colors.blue,
      'description': 'Public transport, fuel, parking',
    },
    'Entertainment': {
      'icon': CupertinoIcons.game_controller_solid,
      'color': Colors.purple,
      'description': 'Movies, games, subscriptions',
    },
    'Health': {
      'icon': CupertinoIcons.heart_fill,
      'color': Colors.red,
      'description': 'Medical, pharmacy, fitness',
    },
    'Shopping': {
      'icon': CupertinoIcons.shopping_cart,
      'color': Colors.green,
      'description': 'Clothes, electronics, accessories',
    },
    'Education': {
      'icon': CupertinoIcons.book_fill,
      'color': Colors.indigo,
      'description': 'Courses, books, training',
    },
    'Travel': {
      'icon': CupertinoIcons.airplane,
      'color': Colors.teal,
      'description': 'Vacation, business trips',
    },
    'Utilities': {
      'icon': CupertinoIcons.lightbulb_fill,
      'color': Colors.amber,
      'description': 'Electricity, water, internet',
    },
    'Other': {
      'icon': CupertinoIcons.ellipsis_circle_fill,
      'color': Colors.grey,
      'description': 'Miscellaneous expenses',
    },
  };

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double smallPadding = 8.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double creditCardHeight = 220.0;

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxDescriptionLength = 100;
  static const double minExpenseAmount = 0.01;
  static const double maxExpenseAmount = 999999.99;

  // Storage Keys (for SharedPreferences)
  static const String themeKey = 'app_theme';
  static const String userPreferencesKey = 'user_preferences';
  static const String expensesKey = 'saved_expenses';

  // Date Formats
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String csvDateFormat = 'yyyy-MM-dd';
  static const String timestampFormat = 'yyyy-MM-dd HH:mm:ss';

  // Export Constants
  static const String csvFileExtension = '.csv';
  static const String reportFilePrefix = 'transactions_report_';
  static const List<String> csvHeaders = [
    'Date',
    'Category',
    'Description',
    'Amount (KSH)'
  ];

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String validationError = 'Please check your input and try again.';

  // Success Messages
  static const String expenseAdded = 'Expense added successfully!';
  static const String expenseUpdated = 'Expense updated successfully!';
  static const String expenseDeleted = 'Expense deleted successfully!';
  static const String reportExported = 'Report exported successfully!';
}