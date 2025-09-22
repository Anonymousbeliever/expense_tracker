import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/data/theme_provider.dart';
import 'app_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyAppView(),
    );
  }
}