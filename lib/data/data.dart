// Export models for easy importing
export '../models/expense.dart';
export '../models/user.dart';
export '../models/category.dart';

// Export providers
export 'expenses_provider.dart';
export 'theme_provider.dart';
export 'auth_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Sample transaction data (can be removed once real data is implemented)
List<Map<String, dynamic>> transactionsData = [
  {
    'icon': CupertinoIcons.cart_fill,
    'color': Colors.orange,
    'name': 'Food',
    'amount': '- KSH 1,200.00',
    'date': 'Today',
  },
  {
    'icon': CupertinoIcons.shopping_cart,
    'color': Colors.green,
    'name': 'Shopping',
    'amount': '- KSH 700.00',
    'date': 'Today',
  },
  {
    'icon': CupertinoIcons.heart_fill,
    'color': Colors.red,
    'name': 'Health',
    'amount': '- KSH 400.00',
    'date': 'Yesterday',
  },
  {
    'icon': CupertinoIcons.airplane,
    'color': Colors.teal,
    'name': 'Travel',
    'amount': '- KSH 3,400.00',
    'date': 'Yesterday',
  },
];
