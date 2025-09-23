import 'package:intl/intl.dart';

class AppFormatters {
  // Currency formatter
  static String formatCurrency(double amount, {String currency = 'KSH'}) {
    final formatter = NumberFormat('#,##0.00');
    return '$currency ${formatter.format(amount)}';
  }

  // Currency formatter without symbol (for calculations display)
  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
  }

  // Compact currency formatter (e.g., 1.2K, 1.5M)
  static String formatCompactCurrency(double amount, {String currency = 'KSH'}) {
    if (amount >= 1000000) {
      return '$currency ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$currency ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatCurrency(amount, currency: currency);
    }
  }

  // Date formatters
  static String formatDisplayDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static String formatCSVDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTimestamp(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date); // Day of week
    } else {
      return formatDisplayDate(date);
    }
  }

  // Percentage formatter
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  // File name formatter for exports
  static String formatFileName(String prefix, String filter, DateTime timestamp) {
    final formattedTimestamp = DateFormat('yyyyMMdd_HHmmss').format(timestamp);
    final cleanFilter = filter.replaceAll(' ', '_').toLowerCase();
    return '${prefix}${cleanFilter}_$formattedTimestamp';
  }

  // Transaction amount formatter with sign
  static String formatTransactionAmount(double amount, {String currency = 'KSH'}) {
    final formatted = formatCurrency(amount.abs(), currency: currency);
    return amount < 0 ? '- $formatted' : '+ $formatted';
  }

  // Duration formatter
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Just now';
    }
  }

  // Validators
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidAmount(String amount) {
    try {
      final value = double.parse(amount);
      return value > 0 && value <= 999999.99;
    } catch (e) {
      return false;
    }
  }

  // Text truncation
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Capitalize first letter
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Clean CSV content (escape commas, quotes)
  static String cleanCSVContent(String content) {
    // Replace commas with semicolons and handle quotes
    return content.replaceAll(',', ';').replaceAll('"', '""');
  }
}