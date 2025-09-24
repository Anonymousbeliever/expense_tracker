import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../repositories/repositories.dart';
import '../services/firebase_auth_service.dart';

/// Firebase Expenses Provider for state management
/// Manages the list of expenses with real-time Firebase integration
class FirebaseExpensesProvider with ChangeNotifier {
  final FirebaseAuthService _authService;
  FirebaseExpenseRepository? _repository;
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  /// Constructor
  FirebaseExpensesProvider(this._authService) {
    _authService.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  /// Getters
  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get total amount of all expenses
  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Get expenses filtered by category (from cached data)
  List<Expense> getCachedExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  /// Get expenses within a date range (from cached data)
  List<Expense> getCachedExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return _expenses.where((expense) => 
        expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        expense.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  /// Handle auth state changes
  void _onAuthStateChanged() {
    final user = _authService.currentUser;
    if (user != null) {
      _repository = FirebaseExpenseRepository(userId: user.id);
      _startListeningToExpenses();
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
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load expenses: $e');
      _setLoading(false);
    }
  }

  /// Add a new expense
  Future<void> addExpense(Expense expense) async {
    if (_repository == null) {
      _setError('User not authenticated');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository!.addExpense(expense);
      // Don't reload manually - the real-time listener will update the list
      _setLoading(false);
    } catch (e) {
      _setError('Failed to add expense: $e');
      _setLoading(false);
    }
  }

  /// Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    if (_repository == null) {
      _setError('User not authenticated');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository!.updateExpense(expense);
      // Don't reload manually - the real-time listener will update the list
      _setLoading(false);
    } catch (e) {
      _setError('Failed to update expense: $e');
      _setLoading(false);
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String id) async {
    if (_repository == null) {
      _setError('User not authenticated');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository!.deleteExpense(id);
      // Don't reload manually - the real-time listener will update the list
      _setLoading(false);
    } catch (e) {
      _setError('Failed to delete expense: $e');
      _setLoading(false);
    }
  }

  /// Get expense by ID
  Future<Expense?> getExpenseById(String id) async {
    if (_repository == null) return null;

    try {
      return await _repository!.getExpenseById(id);
    } catch (e) {
      _setError('Failed to get expense: $e');
      return null;
    }
  }

  /// Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) async {
    if (_repository == null) return [];

    try {
      return await _repository!.getExpensesByCategory(category);
    } catch (e) {
      _setError('Failed to get expenses by category: $e');
      return [];
    }
  }

  /// Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    if (_repository == null) return [];

    try {
      return await _repository!.getExpensesByDateRange(startDate, endDate);
    } catch (e) {
      _setError('Failed to get expenses by date range: $e');
      return [];
    }
  }

  /// Get total spending by category
  Map<String, double> getCategoryTotals() {
    Map<String, double> categoryTotals = {};
    
    for (var expense in _expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    return categoryTotals;
  }

  /// Get expenses summary from Firebase
  Future<Map<String, dynamic>> getExpensesSummary() async {
    if (_repository == null) return {};
    
    try {
      return await _repository!.getExpensesSummary();
    } catch (e) {
      _setError('Failed to get expenses summary: $e');
      return {};
    }
  }

  /// Get monthly totals for a specific year
  Future<Map<String, double>> getMonthlyTotals(int year) async {
    if (_repository == null) return {};
    
    try {
      return await _repository!.getMonthlyTotals(year);
    } catch (e) {
      _setError('Failed to get monthly totals: $e');
      return {};
    }
  }

  /// Listen to real-time expense updates
  void _startListeningToExpenses() {
    if (_repository == null) return;

    _repository!.getExpensesStream().listen(
      (expenses) {
        _expenses = expenses;
        notifyListeners();
      },
      onError: (error) {
        _setError('Real-time sync error: $error');
      },
    );
  }

  /// Refresh expenses from Firebase
  Future<void> refreshExpenses() async {
    await loadExpenses();
  }

  /// Clear all local expenses (doesn't affect Firebase)
  void clearLocalExpenses() {
    _expenses.clear();
    notifyListeners();
  }

  /// Get total amount of all expenses
  double get totalAmount {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Get expenses count
  int get expensesCount => _expenses.length;

  /// Check if expenses list is empty
  bool get isEmpty => _expenses.isEmpty;

  /// Check if expenses list is not empty
  bool get isNotEmpty => _expenses.isNotEmpty;

  /// Get expenses for current month
  List<Expense> get currentMonthExpenses {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return _expenses.where((expense) {
      return expense.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             expense.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get spending for current month
  double get currentMonthTotal {
    return currentMonthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

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