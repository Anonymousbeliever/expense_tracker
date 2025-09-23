import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../repositories/repositories.dart';
import 'auth_service.dart';

/// Expenses Provider for state management with local storage
/// Manages the list of expenses and provides CRUD operations
class ExpensesProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  LocalExpenseRepository? _repository;
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  /// Constructor
  ExpensesProvider() {
    _authService.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  /// Getters
  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Handle auth state changes
  void _onAuthStateChanged() {
    final user = _authService.currentUser;
    if (user != null) {
      _repository = LocalExpenseRepository();
      loadExpenses();
    } else {
      _repository = null;
      _expenses.clear();
      notifyListeners();
    }
  }

  /// Load expenses from Firebase
  Future<void> loadExpenses() async {
    if (_repository == null) return;

    _setLoading(true);
    _clearError();

    try {
      _expenses = await _repository!.getAllExpenses();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new expense
  Future<void> addExpense(Expense expense) async {
    if (_repository == null) {
      _setError('User must be signed in to add expenses');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository!.addExpense(expense);
      _expenses.add(expense);
      _expenses.sort((a, b) => b.date.compareTo(a.date)); // Sort by date desc
      notifyListeners();
    } catch (e) {
      _setError('Failed to add expense: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Remove an expense by ID
  Future<void> removeExpense(String id) async {
    if (_repository == null) {
      _setError('User must be signed in to remove expenses');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository!.deleteExpense(id);
      _expenses.removeWhere((expense) => expense.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove expense: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing expense
  Future<void> updateExpense(String id, Expense updatedExpense) async {
    if (_repository == null) {
      _setError('User must be signed in to update expenses');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository!.updateExpense(updatedExpense);
      final index = _expenses.indexWhere((expense) => expense.id == id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
        _expenses.sort((a, b) => b.date.compareTo(a.date)); // Re-sort
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update expense: $e');
    } finally {
      _setLoading(false);
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

  /// Get expenses for current month
  List<Expense> get currentMonthExpenses {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getExpensesByDateRange(startOfMonth, endOfMonth);
  }

  /// Get total spent this month
  double get monthlyTotal {
    return currentMonthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Get category totals for this month
  Map<String, double> get monthlyCategoryTotals {
    final monthlyExpenses = currentMonthExpenses;
    final Map<String, double> categoryTotals = {};
    
    for (final expense in monthlyExpenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    return categoryTotals;
  }

  /// Get expenses summary
  Future<Map<String, dynamic>> getExpensesSummary() async {
    if (_repository == null) return {};
    
    try {
      final allExpenses = await _repository!.getAllExpenses();
      double total = 0;
      Map<String, double> categoryTotals = {};
      
      for (var expense in allExpenses) {
        total += expense.amount;
        categoryTotals[expense.category] = 
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
      
      return {
        'total': total,
        'count': allExpenses.length,
        'categories': categoryTotals,
      };
    } catch (e) {
      _setError('Failed to get expenses summary: $e');
      return {};
    }
  }

  /// Refresh expenses from repository
  Future<void> refreshExpenses() async {
    await loadExpenses();
  }

  /// Clear all local expenses (doesn't affect Firebase)
  void clearLocalExpenses() {
    _expenses.clear();
    notifyListeners();
  }

  /// Get expenses count
  int get expensesCount => _expenses.length;

  /// Check if expenses list is empty
  bool get isEmpty => _expenses.isEmpty;

  /// Check if expenses list is not empty
  bool get isNotEmpty => _expenses.isNotEmpty;

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}