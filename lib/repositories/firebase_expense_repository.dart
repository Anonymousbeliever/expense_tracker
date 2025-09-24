import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'expense_repository.dart';

class FirebaseExpenseRepository implements ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  FirebaseExpenseRepository({required this.userId});

  // Collection reference for user's expenses
  CollectionReference get _expensesCollection =>
      _firestore.collection('expenses');

  // Helper method to get icon and color for a category
  (IconData, Color) _getCategoryIconAndColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return (Icons.restaurant, Colors.orange);
      case 'transport':
        return (Icons.directions_car, Colors.blue);
      case 'shopping':
        return (Icons.shopping_cart, Colors.green);
      case 'entertainment':
        return (Icons.movie, Colors.purple);
      case 'health':
        return (Icons.health_and_safety, Colors.red);
      case 'education':
        return (Icons.school, Colors.indigo);
      case 'bills':
        return (Icons.receipt_long, Colors.amber);
      default:
        return (Icons.more_horiz, Colors.grey);
    }
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    try {
      final QuerySnapshot snapshot = await _expensesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
            final iconColor = _getCategoryIconAndColor(data['category'] ?? '');
            return Expense.fromMap(data, iconColor.$1, iconColor.$2);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses: $e');
    }
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    try {
      final DocumentSnapshot doc = await _expensesCollection.doc(id).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) return null; // Security check
      
      final expenseData = {...data, 'id': doc.id};
      final iconColor = _getCategoryIconAndColor(data['category'] ?? '');
      return Expense.fromMap(expenseData, iconColor.$1, iconColor.$2);
    } catch (e) {
      throw Exception('Failed to get expense: $e');
    }
  }

  @override
  Future<void> addExpense(Expense expense) async {
    try {
      final expenseData = expense.toMap();
      expenseData['userId'] = userId; // Ensure userId is set
      expenseData['createdAt'] = FieldValue.serverTimestamp();
      expenseData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _expensesCollection.add(expenseData);
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    try {
      final expenseData = expense.toMap();
      expenseData['userId'] = userId; // Ensure userId is set
      expenseData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _expensesCollection.doc(expense.id).update(expenseData);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      // Security check: verify the expense belongs to the user
      final doc = await _expensesCollection.doc(id).get();
      if (!doc.exists) return;
      
      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) {
        throw Exception('Unauthorized: Cannot delete expense that doesn\'t belong to user');
      }
      
      await _expensesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String category) async {
    try {
      final QuerySnapshot snapshot = await _expensesCollection
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
            final iconColor = _getCategoryIconAndColor(data['category'] ?? '');
            return Expense.fromMap(data, iconColor.$1, iconColor.$2);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses by category: $e');
    }
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final QuerySnapshot snapshot = await _expensesCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
            final iconColor = _getCategoryIconAndColor(data['category'] ?? '');
            return Expense.fromMap(data, iconColor.$1, iconColor.$2);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses by date range: $e');
    }
  }

  // Additional Firebase-specific methods

  /// Get real-time stream of user's expenses
  Stream<List<Expense>> getExpensesStream() {
    return _expensesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
              final iconColor = _getCategoryIconAndColor(data['category'] ?? '');
              return Expense.fromMap(data, iconColor.$1, iconColor.$2);
            })
            .toList());
  }

  /// Get expenses summary with totals and counts
  Future<Map<String, dynamic>> getExpensesSummary() async {
    try {
      final QuerySnapshot snapshot = await _expensesCollection
          .where('userId', isEqualTo: userId)
          .get();

      double total = 0;
      Map<String, double> categoryTotals = {};
      Map<String, int> categoryCounts = {};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final category = data['category'] as String? ?? 'Unknown';

        total += amount;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      return {
        'total': total,
        'count': snapshot.docs.length,
        'categories': categoryTotals,
        'categoryCounts': categoryCounts,
        'averageAmount': snapshot.docs.isNotEmpty ? total / snapshot.docs.length : 0,
      };
    } catch (e) {
      throw Exception('Failed to get expenses summary: $e');
    }
  }

  /// Get monthly spending totals
  Future<Map<String, double>> getMonthlyTotals(int year) async {
    try {
      final startOfYear = DateTime(year, 1, 1);
      final endOfYear = DateTime(year, 12, 31, 23, 59, 59);

      final QuerySnapshot snapshot = await _expensesCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfYear))
          .get();

      Map<String, double> monthlyTotals = {};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final timestamp = data['date'] as Timestamp?;
        
        if (timestamp != null) {
          final date = timestamp.toDate();
          final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + amount;
        }
      }

      return monthlyTotals;
    } catch (e) {
      throw Exception('Failed to get monthly totals: $e');
    }
  }
}