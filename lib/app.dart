import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/data/data.dart';
import 'package:expense_tracker/services/firebase_auth_service.dart';
import 'package:expense_tracker/providers/firebase_expenses_provider.dart';
import 'package:expense_tracker/providers/budget_provider.dart';
import 'app_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        
        // Budget Provider
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
        
        // Firebase Auth Service
        ChangeNotifierProvider(
          create: (context) => FirebaseAuthService(),
        ),
        
        // Firebase Expenses Provider (depends on auth service)
        ChangeNotifierProxyProvider<FirebaseAuthService, FirebaseExpensesProvider>(
          create: (context) => FirebaseExpensesProvider(
            Provider.of<FirebaseAuthService>(context, listen: false)
          ),
          update: (context, auth, previous) => 
              previous ?? FirebaseExpensesProvider(auth),
        ),
      ],
      child: const MyAppView(),
    );
  }
}