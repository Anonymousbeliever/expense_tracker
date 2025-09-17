import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 

List<Map<String, dynamic>> transactionsData = [
  {
    'icon': CupertinoIcons.shopping_cart,  // food icon
    'color': Colors.yellow,
    'name': 'Food',
    'amount': '- KSH 1,200.00',
    'date': 'Today',
  },
  {
    'icon': CupertinoIcons.shopping_cart, // shopping cart icon
    'color': Colors.purple,
    'name': 'Shopping',
    'amount': '- KSH 700.00',
    'date': 'Today',
  },
  {
    'icon': CupertinoIcons.heart_slash_fill, // health / heart icon
    'color': Colors.green,
    'name': 'Health',
    'amount': '- KSH 400.00',
    'date': 'Yesterday',
  },
  {
    'icon': CupertinoIcons.airplane, // travel icon
    'color': Colors.blue,
    'name': 'Travel',
    'amount': '- KSH 3,400.00',
    'date': 'Yesterday',
  },
];
