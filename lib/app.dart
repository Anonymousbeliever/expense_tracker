import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/data/data.dart';
import 'app_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ExpensesProvider()),
      ],
      child: const MyAppView(),
    );
  }
}