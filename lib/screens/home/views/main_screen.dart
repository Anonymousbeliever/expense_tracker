import 'package:expense_tracker/data/data.dart';
import 'package:expense_tracker/widgets/widgets.dart';
import 'package:expense_tracker/screens/auth/auth.dart';
import 'package:expense_tracker/screens/transactions/transactions.dart';
import 'package:expense_tracker/screens/help_support/help_support.dart';
import 'package:expense_tracker/screens/in_app_purchase/in_app_purchase.dart';
import 'package:expense_tracker/services/firebase_auth_service.dart';
import 'package:expense_tracker/providers/firebase_expenses_provider.dart';
import 'package:expense_tracker/providers/budget_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  void _showRechargeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RechargeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<FirebaseAuthService>(context);
    final currentUser = authService.currentUser;

    return Consumer2<FirebaseExpensesProvider, BudgetProvider>(
      builder: (context, expensesProvider, budgetProvider, child) {
        final totalExpenses = expensesProvider.totalExpenses;
        final recentExpenses = expensesProvider.expenses.take(5).toList();
        
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              Icon(CupertinoIcons.person_fill, color: Colors.white),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome!",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              Text(
                                currentUser?.displayName ?? "User",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'logout') {
                            await authService.signOut();
                          } else if (value == 'theme') {
                            final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                            themeProvider.setDarkTheme(!themeProvider.getIsDarkTheme);
                          } else if (value == 'profile') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfileScreen()),
                            );
                          } else if (value == 'settings') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            );
                          } else if (value == 'help') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                            );
                          } else if (value == 'premium') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const InAppPurchaseScreen()),
                            );
                          }
                        },
                        icon: Icon(CupertinoIcons.settings),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'profile',
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.person, size: 16),
                                SizedBox(width: 8),
                                Text('Profile'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'theme',
                            child: Consumer<ThemeProvider>(
                              builder: (context, themeProvider, child) {
                                return Row(
                                  children: [
                                    Icon(
                                      themeProvider.getIsDarkTheme
                                          ? CupertinoIcons.sun_max
                                          : CupertinoIcons.moon,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      themeProvider.getIsDarkTheme ? 'Light Mode' : 'Dark Mode',
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'settings',
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.settings, size: 16),
                                SizedBox(width: 8),
                                Text('Settings'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'help',
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.question_circle, size: 16),
                                SizedBox(width: 8),
                                Text('Help & Support'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'premium',
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.star_circle, size: 16),
                                SizedBox(width: 8),
                                Text('Upgrade to Premium'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.square_arrow_right, size: 16),
                                SizedBox(width: 8),
                                Text('Logout'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  CreditCard(
                    currentBalance: budgetProvider.currentBalance - totalExpenses,
                    monthlyBudget: budgetProvider.monthlyBudget,
                    totalSpent: totalExpenses,
                    isActive: true,
                  ),
                  SizedBox(height: 10),
                  // Recharge & Budget Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRechargeDialog(context),
                      icon: Icon(Icons.account_balance_wallet),
                      label: Text('Recharge & Budget'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AllTransactionsScreen()),
                          );
                        },
                        child: Text(
                          'View all',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: recentExpenses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.money_dollar_circle,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No expenses yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start tracking your expenses!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: recentExpenses.length,
                            itemBuilder: (context, int i) {
                              final expense = recentExpenses[i];
                              return ExpenseTile(
                                expense: expense,
                                showCategory: false,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}