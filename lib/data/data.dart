import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 

// Expense model
class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final IconData icon;
  final Color color;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.description = '',
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, IconData icon, Color color) {
    return Expense(
      id: map['id'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      description: map['description'] ?? '',
      icon: icon,
      color: color,
    );
  }
}

// Expenses Provider for state management
class ExpensesProvider with ChangeNotifier {
  final List<Expense> _expenses = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }
}

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
