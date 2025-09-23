import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:expense_tracker/data/data.dart';
import 'package:expense_tracker/models/models.dart';
import 'package:flutter/material.dart';
import '../lib/firebase_options.dart';

void main() {
  // Suppress print statements in tests
  print('Running Expense Tracker Integration Tests...');

  setUpAll(() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // Firebase already initialized or not available in test environment
      print('Firebase initialization skipped in test environment');
    }
  });

  group('Integration Tests', () {
    group('Firebase Setup Tests', () {
      test('Firebase should be available for future integration', () {
        // This test verifies that Firebase options are configured
        // but doesn't require actual Firebase connection in demo mode
        expect(DefaultFirebaseOptions.currentPlatform, isNotNull);
      });
    });

    group('Demo Auth Service Tests', () {
      late AuthService authService;

      setUp(() {
        authService = AuthService();
      });

      test('AuthService should initialize correctly', () {
        expect(authService, isNotNull);
        expect(authService.currentUser, isNull);
        expect(authService.isLoading, false);
      });

      test('AuthService should have stream available', () {
        expect(authService.authStateChanges, isA<Stream>());
      });

      test('AuthService should handle sign in', () async {
        // Test demo sign in functionality
        expect(authService.currentUser, isNull);
        
        // Test successful sign in with valid credentials
        final user = await authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );
        expect(user, isNotNull);
        expect(user.email, 'test@example.com');
        expect(authService.currentUser, isNotNull);
        expect(authService.currentUser!.email, 'test@example.com');
      });

      test('AuthService should handle sign out', () async {
        // First sign in
        await authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );
        expect(authService.currentUser, isNotNull);
        
        // Then sign out
        await authService.signOut();
        expect(authService.currentUser, isNull);
      });
    });

    group('Demo Expenses Provider Tests', () {
      test('ExpensesProvider should initialize correctly', () {
        final provider = ExpensesProvider();
        expect(provider, isNotNull);
        expect(provider.expenses, isA<List<Expense>>());
      });

      test('ExpensesProvider should handle expense operations', () {
        final provider = ExpensesProvider();
        final initialCount = provider.expenses.length;
        
        // Test adding expense
        final expense = Expense(
          id: 'test-1',
          category: 'Food',
          amount: 25.0,
          date: DateTime.now(),
          description: 'Test expense',
          icon: Icons.fastfood,
          color: Colors.orange,
        );
        
        provider.addExpense(expense);
        expect(provider.expenses.length, initialCount + 1);
        expect(provider.expenses.last.id, 'test-1');
        
        // Test removing expense
        provider.removeExpense('test-1');
        expect(provider.expenses.length, initialCount);
      });
    });

    group('Model Tests', () {
      test('Expense model should serialize correctly', () {
        final expense = Expense(
          id: 'test-expense',
          category: 'Food',
          amount: 50.0,
          date: DateTime(2025, 1, 1),
          description: 'Test meal',
          icon: Icons.restaurant,
          color: Colors.red,
        );

        final map = expense.toMap();
        expect(map['id'], 'test-expense');
        expect(map['category'], 'Food');
        expect(map['amount'], 50.0);
        expect(map['description'], 'Test meal');

        final recreated = Expense.fromMap(map, Icons.restaurant, Colors.red);
        expect(recreated.id, expense.id);
        expect(recreated.category, expense.category);
        expect(recreated.amount, expense.amount);
        expect(recreated.description, expense.description);
      });

      test('User model should work correctly', () {
        final user = User(
          id: 'test-user',
          email: 'test@example.com',
          displayName: 'Test User',
          createdAt: DateTime(2025, 1, 1),
          lastLoginAt: DateTime(2025, 1, 1),
        );

        expect(user.id, 'test-user');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');

        final copy = user.copyWith(displayName: 'Updated User');
        expect(copy.displayName, 'Updated User');
        expect(copy.email, 'test@example.com'); // Should remain unchanged
      });
    });

    group('Error Handling Tests', () {
      test('Auth service should handle errors gracefully', () async {
        final authService = AuthService();
        
        // Test with invalid credentials - should throw an exception
        expect(() async {
          await authService.signInWithEmailAndPassword(
            email: 'invalid@example.com',
            password: 'wrongpassword',
          );
        }, throwsA(isA<Exception>()));
        
        // Ensure user remains null after failed sign-in
        expect(authService.currentUser, isNull);
      });

      test('Should handle provider operations safely', () {
        final authService = AuthService();
        expect(authService.currentUser, isNull);

        final provider = ExpensesProvider();
        expect(provider.expenses, isA<List<Expense>>());
        
        // Test that operations don't crash
        expect(() => provider.removeExpense('non-existent'), returnsNormally);
      });
    });
  });
}