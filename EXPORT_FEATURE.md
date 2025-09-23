# Export Functionality - Expense Tracker

## Overview
The expense tracker now includes a comprehensive export functionality that allows users to download transaction reports in CSV format. This feature is implemented with cross-platform support for Web, Android, iOS, and Desktop platforms.

## Features

### 📊 Export Options
- **Time-based filtering**: Export transactions for the last 7 days or 30 days
- **CSV format**: Standard comma-separated values format for easy import into spreadsheet applications
- **Complete transaction data**: Includes date, category, description, and amount for each transaction
- **Summary statistics**: Total transaction count and sum

### 🎯 Access Points
1. **App Bar Download Icon**: Quick access from the stats screen header
2. **Export Report Button**: Prominent button alongside the time filter dropdown

### 🛠️ Technical Implementation

#### File Export Service (`lib/services/file_export_service.dart`)
- **Cross-platform support**: Handles Web, Android, iOS, and Desktop platforms differently
- **Permission handling**: Automatically requests storage permissions on Android
- **Error handling**: Comprehensive error handling with user feedback via SnackBars
- **File naming**: Automatic timestamped filenames for organization

#### Platform-Specific Behavior
- **Web**: Direct browser download using `dart:html`
- **Android**: Saves to Downloads folder with storage permission request
- **iOS**: Saves to app's Documents directory
- **Desktop**: Saves to system Downloads folder or Documents as fallback

### 📱 User Experience

#### Export Process
1. Navigate to the Stats screen
2. Select desired time filter (7 Days or 30 Days)
3. Tap either:
   - Download icon in the app bar
   - "Export Report" button
4. Grant storage permission if prompted (Android)
5. Receive confirmation message with file location

#### CSV File Structure
```csv
Date,Category,Description,Amount (KSH)
2025-09-23,Food,Lunch at restaurant,1250.00
2025-09-22,Transport,Uber ride,450.00
...

Summary
Total Transactions,15
Total Amount,12750.50
Report Generated,2025-09-23 14:30:15
```

### 🔒 Permissions

#### Android Manifest (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
```

#### Dependencies (`pubspec.yaml`)
```yaml
dependencies:
  path_provider: ^2.1.4      # File system access
  permission_handler: ^11.3.1 # Permission management
```

### 💡 Usage Tips
- **Empty data handling**: The app shows appropriate messages when no transactions are available
- **File organization**: Files are automatically timestamped for easy identification
- **Cross-platform**: Works consistently across all supported platforms
- **Accessibility**: Includes tooltips and clear visual feedback

### 🔧 Code Integration
The export feature integrates seamlessly with the existing `ExpensesProvider` state management:

```dart
// Usage in StatScreen
await FileExportService.exportTransactionsToCSV(
  context: context,
  expenses: filteredExpenses,
  timeFilter: _selectedFilter,
);
```

This implementation provides a robust, user-friendly way to export transaction data while maintaining the app's existing design patterns and user experience standards.