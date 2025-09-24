import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';

class RechargeDialog extends StatefulWidget {
  const RechargeDialog({super.key});

  @override
  State<RechargeDialog> createState() => _RechargeDialogState();
}

class _RechargeDialogState extends State<RechargeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _rechargeController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    _budgetController.text = budgetProvider.monthlyBudget.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _rechargeController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      
      final rechargeAmount = double.tryParse(_rechargeController.text);
      final newBudget = double.tryParse(_budgetController.text);

      // Update recharge amount if provided
      if (rechargeAmount != null && rechargeAmount > 0) {
        await budgetProvider.rechargeBalance(rechargeAmount);
      }

      // Update budget if it has changed
      if (newBudget != null && newBudget != budgetProvider.monthlyBudget) {
        await budgetProvider.updateMonthlyBudget(newBudget);
      }

      if (mounted) {
        Navigator.of(context).pop();
        
        String message = '';
        if (rechargeAmount != null && rechargeAmount > 0 && newBudget != null) {
          message = 'Balance recharged and budget updated successfully!';
        } else if (rechargeAmount != null && rechargeAmount > 0) {
          message = 'Balance recharged successfully!';
        } else if (newBudget != null) {
          message = 'Budget updated successfully!';
        } else {
          message = 'No changes made';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Recharge & Budget'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add funds to your balance and adjust your monthly budget.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _rechargeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Recharge Amount (KSH)',
                hintText: 'Enter amount to add',
                prefixIcon: const Icon(Icons.add_circle_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid positive amount';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Monthly Budget (KSH)',
                hintText: 'Set your monthly spending limit',
                prefixIcon: const Icon(Icons.pie_chart_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a budget amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount < 0) {
                  return 'Enter a valid budget amount';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleUpdate,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}