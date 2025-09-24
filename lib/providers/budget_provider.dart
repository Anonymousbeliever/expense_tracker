import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetProvider extends ChangeNotifier {
  double _currentBalance = 50000.00;
  double _monthlyBudget = 5194.00;
  
  double get currentBalance => _currentBalance;
  double get monthlyBudget => _monthlyBudget;
  double get availableBalance => _currentBalance;

  BudgetProvider() {
    _loadData();
  }

  // Load saved data from SharedPreferences
  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentBalance = prefs.getDouble('current_balance') ?? 50000.00;
    _monthlyBudget = prefs.getDouble('monthly_budget') ?? 5194.00;
    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('current_balance', _currentBalance);
    await prefs.setDouble('monthly_budget', _monthlyBudget);
  }

  // Recharge balance
  Future<void> rechargeBalance(double amount) async {
    if (amount > 0) {
      _currentBalance += amount;
      _saveData();
      notifyListeners();
    }
  }

  // Update monthly budget
  Future<void> updateMonthlyBudget(double newBudget) async {
    if (newBudget >= 0) {
      _monthlyBudget = newBudget;
      _saveData();
      notifyListeners();
    }
  }

  // Deduct amount when expense is added (called by expense provider)
  Future<void> deductBalance(double amount) async {
    if (amount > 0 && _currentBalance >= amount) {
      _currentBalance -= amount;
      _saveData();
      notifyListeners();
    }
  }

  // Add amount when expense is deleted (called by expense provider)
  Future<void> addBalance(double amount) async {
    if (amount > 0) {
      _currentBalance += amount;
      _saveData();
      notifyListeners();
    }
  }

  // Reset budget (for new month or user preference)
  Future<void> resetBudget({double? newBudget}) async {
    if (newBudget != null && newBudget >= 0) {
      _monthlyBudget = newBudget;
    }
    _saveData();
    notifyListeners();
  }

  // Get remaining budget for the month
  double getRemainingBudget(double totalSpent) {
    return _monthlyBudget - totalSpent;
  }

  // Check if user is over budget
  bool isOverBudget(double totalSpent) {
    return totalSpent > _monthlyBudget;
  }

  // Get budget usage percentage
  double getBudgetUsagePercentage(double totalSpent) {
    return _monthlyBudget > 0 ? (totalSpent / _monthlyBudget) * 100 : 0.0;
  }
}