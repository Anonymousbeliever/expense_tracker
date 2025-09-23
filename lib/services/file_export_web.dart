// Web-specific implementation for file export
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/data/data.dart';

class WebFileExportService {
  static Future<void> exportTransactionsToCSV({
    required BuildContext context,
    required List<Expense> expenses,
    required String timeFilter,
  }) async {
    try {
      if (expenses.isEmpty) {
        _showSnackBar(context, 'No transactions to export.', Colors.orange);
        return;
      }

      // Generate CSV content
      final csvContent = _generateCSVContent(expenses);
      
      // Get file name
      final fileName = 'transactions_report_${timeFilter.replaceAll(' ', '_').toLowerCase()}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      
      // Download file for web
      final blob = html.Blob([csvContent], 'text/csv', 'native');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      
      _showSnackBar(context, 'Report downloaded successfully!', Colors.green);
    } catch (e) {
      _showSnackBar(context, 'Error exporting report: $e', Colors.red);
    }
  }

  static String _generateCSVContent(List<Expense> expenses) {
    final StringBuffer csv = StringBuffer();
    
    // Add header
    csv.writeln('Date,Category,Description,Amount (KSH)');
    
    // Sort expenses by date (newest first)
    expenses.sort((a, b) => b.date.compareTo(a.date));
    
    // Add data rows
    for (var expense in expenses) {
      final date = DateFormat('yyyy-MM-dd').format(expense.date);
      final category = expense.category.replaceAll(',', ';'); // Escape commas
      final description = expense.description.replaceAll(',', ';'); // Escape commas
      final amount = expense.amount.toStringAsFixed(2);
      
      csv.writeln('$date,$category,$description,$amount');
    }
    
    // Add summary
    csv.writeln('');
    csv.writeln('Summary');
    csv.writeln('Total Transactions,${expenses.length}');
    csv.writeln('Total Amount,${expenses.fold(0.0, (sum, expense) => sum + expense.amount).toStringAsFixed(2)}');
    csv.writeln('Report Generated,${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    
    return csv.toString();
  }

  static void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}