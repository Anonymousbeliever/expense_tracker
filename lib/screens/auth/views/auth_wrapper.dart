import 'package:flutter/material.dart';
import 'package:expense_tracker/data/auth_service.dart';
import 'package:expense_tracker/models/user.dart';
import 'package:expense_tracker/screens/home/home.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Expense Tracker',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}