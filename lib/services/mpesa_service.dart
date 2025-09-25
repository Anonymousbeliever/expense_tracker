import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class MpesaService {
  static String get baseUrl => AppConfig.mpesaApiBaseUrl;

  /// Initialize service and validate configuration
  static void initialize() {
    AppConfig.validateConfiguration();
    if (AppConfig.enableDebugLogs) {
      print('MpesaService initialized with base URL: $baseUrl');
    }
  }

  /// Initiate STK Push for premium upgrade
  static Future<MpesaResponse> initiateSTKPush({
    required String phoneNumber,
    required String amount,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stkpush'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'amount': amount,
          'userId': userId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return MpesaResponse.success(
          checkoutRequestId: data['data']['checkoutRequestId'],
          merchantRequestId: data['data']['merchantRequestId'],
          responseDescription: data['data']['responseDescription'],
          transactionId: data['data']['transactionId'],
        );
      } else {
        return MpesaResponse.error(
          message: data['error'] ?? 'STK Push failed',
          details: data['details'] ?? [],
        );
      }
    } catch (e) {
      return MpesaResponse.error(
        message: 'Network error: ${e.toString()}',
        details: [],
      );
    }
  }

  /// Check transaction status
  static Future<TransactionStatus> checkTransactionStatus(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transaction/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return TransactionStatus(
          transactionId: data['data']['transactionId'],
          status: data['data']['status'],
          amount: data['data']['amount']?.toDouble() ?? 0.0,
          resultCode: data['data']['resultCode'],
          resultDescription: data['data']['resultDescription'],
          createdAt: DateTime.tryParse(data['data']['createdAt'] ?? ''),
          updatedAt: DateTime.tryParse(data['data']['updatedAt'] ?? ''),
        );
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch transaction status');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Check API health
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      return response.statusCode == 200 && data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}

/// M-Pesa API response model
class MpesaResponse {
  final bool success;
  final String? checkoutRequestId;
  final String? merchantRequestId;
  final String? responseDescription;
  final String? transactionId;
  final String? errorMessage;
  final List<String>? errorDetails;

  MpesaResponse._({
    required this.success,
    this.checkoutRequestId,
    this.merchantRequestId,
    this.responseDescription,
    this.transactionId,
    this.errorMessage,
    this.errorDetails,
  });

  factory MpesaResponse.success({
    required String checkoutRequestId,
    required String merchantRequestId,
    required String responseDescription,
    required String transactionId,
  }) {
    return MpesaResponse._(
      success: true,
      checkoutRequestId: checkoutRequestId,
      merchantRequestId: merchantRequestId,
      responseDescription: responseDescription,
      transactionId: transactionId,
    );
  }

  factory MpesaResponse.error({
    required String message,
    required List<String> details,
  }) {
    return MpesaResponse._(
      success: false,
      errorMessage: message,
      errorDetails: details,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'MpesaResponse(success: true, transactionId: $transactionId)';
    } else {
      return 'MpesaResponse(success: false, error: $errorMessage)';
    }
  }
}

/// Transaction status model
class TransactionStatus {
  final String transactionId;
  final String status;
  final double amount;
  final int? resultCode;
  final String? resultDescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransactionStatus({
    required this.transactionId,
    required this.status,
    required this.amount,
    this.resultCode,
    this.resultDescription,
    this.createdAt,
    this.updatedAt,
  });

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get isSuccessful => isCompleted && resultCode == 0;

  @override
  String toString() {
    return 'TransactionStatus(id: $transactionId, status: $status, amount: $amount)';
  }
}