import 'package:flutter/foundation.dart';
import '../models/expense.dart';

/// Expenses Provider for state management
/// Manages the list of expenses and provides CRUD operations
class ExpensesProvider with ChangeNotifier {
  final List<Expense> _expenses = [];

  /// Get a read-only list of all expenses
  List<Expense> get expenses => List.unmodifiable(_expenses);

  /// Add a new expense to the list
  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  /// Remove an expense by ID
  void removeExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  /// Update an existing expense
  void updateExpense(String id, Expense updatedExpense) {
    final index = _expenses.indexWhere((expense) => expense.id == id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      notifyListeners();
    }
  }

  /// Get total amount of all expenses
  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Get expenses filtered by category
  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  /// Get expenses within a date range
  List<Expense> getExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return _expenses.where((expense) {
      return expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get recent expenses (last N expenses)
  List<Expense> getRecentExpenses(int count) {
    final sortedExpenses = List<Expense>.from(_expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedExpenses.take(count).toList();
  }

  /// Clear all expenses
  void clearAllExpenses() {
    _expenses.clear();
    notifyListeners();
  }

  /// Get expenses count
  int get expensesCount => _expenses.length;

  /// Check if expenses list is empty
  bool get isEmpty => _expenses.isEmpty;

  /// Check if expenses list is not empty
  bool get isNotEmpty => _expenses.isNotEmpty;
}