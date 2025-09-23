import '../models/expense.dart';

/// Abstract repository interface for expense data operations
abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<Expense?> getExpenseById(String id);
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<List<Expense>> getExpensesByCategory(String category);
  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate);
}

/// Local implementation of expense repository
/// This could be extended to include Firebase/API calls in the future
class LocalExpenseRepository implements ExpenseRepository {
  final List<Expense> _expenses = [];

  @override
  Future<List<Expense>> getAllExpenses() async {
    return List.unmodifiable(_expenses);
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    try {
      return _expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String category) async {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    return _expenses.where((expense) {
      return expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
}