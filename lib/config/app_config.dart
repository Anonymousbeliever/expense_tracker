// Configuration file for M-Pesa integration
// TODO: Replace with your actual values

class AppConfig {
  // Firebase Project Configuration
  static const String firebaseProjectId = 'expense-tracker-8ab00'; // Your Firebase project ID
  
  // M-Pesa Service Configuration
  static String get mpesaApiBaseUrl => 
      isDevelopment 
        ? 'http://127.0.0.1:5001/expense-tracker-8ab00/us-central1/api'
        : 'https://us-central1-$firebaseProjectId.cloudfunctions.net/api';
  
  // Premium Plan Configuration
  static const String premiumPlanAmount = '5.00';
  static const String premiumPlanCurrency = 'KES';
  static const String premiumPlanDescription = 'Expense Tracker Premium Plan';
  
  // Development Configuration
  static const bool isDevelopment = true; // Set to false for production
  static const bool enableDebugLogs = true;
  
  // Validation
  static bool get isConfigured => firebaseProjectId != 'YOUR_PROJECT_ID';
  
  static void validateConfiguration() {
    if (!isConfigured) {
      throw Exception(
        'App not configured properly. Please set your Firebase Project ID in lib/config/app_config.dart'
      );
    }
  }
}