import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/data/data.dart';
import 'package:expense_tracker/repositories/expense_repository.dart';
import 'app_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final authService = AuthService();
            return authService;
          },
        ),
        ChangeNotifierProxyProvider<AuthService, ExpensesProvider>(
          create: (context) => ExpensesProvider(),
          update: (context, auth, previous) => previous ?? ExpensesProvider(),
        ),
        Provider<ExpenseRepository>(
          create: (context) => LocalExpenseRepository(),
        ),
      ],
      child: const MyAppView(),
    );
  }
}