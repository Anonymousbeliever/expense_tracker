import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDeleteButton;
  final bool showCategory;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
    this.showDeleteButton = false,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: expense.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              expense.icon,
              color: expense.color,
              size: 20,
            ),
          ),
          title: Text(
            expense.description.isEmpty ? expense.category : expense.description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            showCategory && expense.description.isNotEmpty
                ? '${expense.category} • ${DateFormat('MMM dd, yyyy').format(expense.date)}'
                : DateFormat('MMM dd, yyyy').format(expense.date),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: showDeleteButton
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'KSH ${NumberFormat('#,##0.00').format(expense.amount)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                )
              : Text(
                  '- KSH ${NumberFormat('#,##0.00').format(expense.amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
        ),
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double padding;

  const CategoryIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 20,
    this.padding = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}