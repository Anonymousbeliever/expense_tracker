import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:expense_tracker/data/data.dart';

class FileExportService {
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
      
      if (kIsWeb) {
        // For web, show message that download is not supported in this version
        _showSnackBar(context, 'Web download will be added in a future update. Use mobile/desktop version.', Colors.orange);
        return;
      }

      // For mobile/desktop platforms
      if (!kIsWeb && Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          _showSnackBar(context, 'Storage permission required to save file.', Colors.red);
          return;
        }
      }
      
      final filePath = await _saveFileToDevice(csvContent, fileName);

      if (filePath != null) {
        _showSnackBar(context, 'Report saved successfully!', Colors.green);
      } else {
        _showSnackBar(context, 'Failed to save report.', Colors.red);
      }
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

  static Future<String?> _saveFileToDevice(String content, String fileName) async {
    try {
      Directory? directory;
      
      if (!kIsWeb && Platform.isAndroid) {
        // For Android, save to Downloads folder
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (!kIsWeb && Platform.isIOS) {
        // For iOS, save to Documents folder
        directory = await getApplicationDocumentsDirectory();
      } else if (!kIsWeb) {
        // For desktop platforms
        directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(content);
        return file.path;
      }
    } catch (e) {
      print('Error saving file: $e');
    }
    return null;
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