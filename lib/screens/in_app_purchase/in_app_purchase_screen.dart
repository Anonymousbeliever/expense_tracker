import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/services/mpesa_service.dart';
import 'package:expense_tracker/services/firebase_auth_service.dart';
import 'package:expense_tracker/config/app_config.dart';
import 'dart:async';

class InAppPurchaseScreen extends StatefulWidget {
  const InAppPurchaseScreen({super.key});

  @override
  State<InAppPurchaseScreen> createState() => _InAppPurchaseScreenState();
}

class _InAppPurchaseScreenState extends State<InAppPurchaseScreen> {
  int _currentStep = 0;
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  
  String? _transactionId;
  Timer? _statusCheckTimer;
  bool _isProcessing = false;
  String _statusMessage = '';

  void _goToPaymentForm() {
    setState(() {
      _currentStep = 1;
      _amountController.text = AppConfig.premiumPlanAmount; // Use configured amount
    });
  }

  Future<void> _submitPayment() async {
    if (_phoneController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    setState(() {
      _isProcessing = true;
      _statusMessage = AppConfig.isDevelopment 
        ? 'Connecting to M-Pesa... (Demo Mode)' 
        : 'Initiating payment...';
    });

    try {
      // Initialize M-Pesa service
      MpesaService.initialize();
      
      final authService = Provider.of<FirebaseAuthService>(context, listen: false);
      final userId = authService.currentUser?.id;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (AppConfig.enableDebugLogs) {
        print('Initiating STK Push - Phone: ${_phoneController.text.trim()}, Amount: ${_amountController.text.trim()}, User: $userId');
      }

      // Initiate STK Push
      final response = await MpesaService.initiateSTKPush(
        phoneNumber: _phoneController.text.trim(),
        amount: _amountController.text.trim(),
        userId: userId,
      );

      if (response.success && response.transactionId != null) {
        _transactionId = response.transactionId!;
        
        setState(() {
          _statusMessage = 'Payment request sent successfully!';
        });

        if (AppConfig.enableDebugLogs) {
          print('STK Push successful - Transaction ID: $_transactionId');
        }

        // Show demo M-Pesa prompt for presentation
        if (AppConfig.isDevelopment) {
          await _showDemoMpesaPrompt();
        } else {
          // Start polling for transaction status in production mode
          _startStatusPolling();
        }
        
      } else {
        throw Exception(response.errorMessage ?? 'Failed to initiate payment');
      }
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '';
      });
      
      if (AppConfig.enableDebugLogs) {
        print('Payment error: ${e.toString()}');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _startStatusPolling() {
    if (_transactionId == null) return;
    
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final status = await MpesaService.checkTransactionStatus(_transactionId!);
        
        if (status.isCompleted) {
          _stopStatusPolling();
          
          if (status.isSuccessful) {
            setState(() {
              _isProcessing = false;
              _currentStep = 2; // Success page
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Payment successful! You are now a Premium user.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            setState(() {
              _isProcessing = false;
              _statusMessage = 'Payment failed: ${status.resultDescription ?? "Unknown error"}';
            });
          }
        } else if (status.isFailed) {
          _stopStatusPolling();
          
          setState(() {
            _isProcessing = false;
            _statusMessage = 'Payment cancelled or failed: ${status.resultDescription ?? "Unknown error"}';
          });
        } else {
          // Still pending
          setState(() {
            _statusMessage = 'Waiting for payment confirmation...';
          });
        }
        
      } catch (e) {
        // Continue polling on error, but limit attempts
        if (timer.tick > 40) { // Stop after ~2 minutes (40 * 3 seconds)
          _stopStatusPolling();
          setState(() {
            _isProcessing = false;
            _statusMessage = 'Payment status check timed out. Please contact support if payment was deducted.';
          });
        }
      }
    });
  }

  Future<void> _showDemoMpesaPrompt() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // M-Pesa Logo/Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.phone_android,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'M-PESA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Message content
                const Text(
                  'DEMO: STK Push Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Pay KES ${_amountController.text}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                const Text(
                  'to Expense Tracker Premium',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Demo PIN input
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Enter M-Pesa PIN:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) => 
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: Text('*', style: TextStyle(fontSize: 20)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _statusMessage = 'Payment cancelled by user';
                          _isProcessing = false;
                        });
                        _stopStatusPolling();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _statusMessage = 'Processing payment... Please wait.';
                        });
                        
                        // In demo mode, simulate successful payment after a short delay
                        if (AppConfig.isDevelopment) {
                          _simulateSuccessfulPayment();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('OK'),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Auto complete button for demo
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _statusMessage = 'Auto-completing payment for demo...';
                    });
                    _simulateSuccessfulPayment();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  child: const Text('Auto Complete (Demo)', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(height: 10),
                const Text(
                  '(Demo Mode - No real money will be charged)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _simulateSuccessfulPayment() {
    // Stop any existing polling
    _stopStatusPolling();
    
    // Simulate processing time
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _currentStep = 2; // Move to success page
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payment successful! You are now a Premium user.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        
        if (AppConfig.enableDebugLogs) {
          print('Demo: Payment completed successfully');
        }
      }
    });
  }
  
  void _stopStatusPolling() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
  }

  void _reset() {
    _stopStatusPolling();
    setState(() {
      _currentStep = 0;
      _phoneController.clear();
      _amountController.clear();
      _isProcessing = false;
      _statusMessage = '';
      _transactionId = null;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _stopStatusPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        title: Text('In-App Purchase', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      _buildStepIndicator(0, 'Plans'),
                      Expanded(child: _buildStepLine(0)),
                      _buildStepIndicator(1, 'Payment'),
                      Expanded(child: _buildStepLine(1)),
                      _buildStepIndicator(2, 'Success'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                if (_currentStep == 0) ...[
                  Card(
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upgrade Your Plan',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Unlock premium features with our affordable plans!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Basic Plan
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.star_outline, 
                                         color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Basic Plan (Free)',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '• Track unlimited expenses\n• Basic analytics\n• Monthly reports',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Premium Plan
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primaryContainer,
                                  Theme.of(context).colorScheme.secondaryContainer,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.star, 
                                         color: Theme.of(context).colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Premium Plan',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                                          ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'KSH 5/month',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '• All Basic features\n• Advanced analytics & insights\n• Cloud backup & sync\n• Export to multiple formats\n• Priority customer support\n• Custom categories\n• Budget alerts & notifications',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _goToPaymentForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Upgrade to Premium',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                if (_currentStep == 1) ...[
                  Card(
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payment,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'M-Pesa Payment',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Secure payment powered by Safaricom M-Pesa',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'M-Pesa Phone Number',
                              hintText: 'e.g., +254712345678',
                              prefixIcon: Icon(
                                Icons.phone,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            readOnly: true, // Make amount read-only since it's pre-set
                            decoration: InputDecoration(
                              labelText: 'Amount (KSH)',
                              hintText: '5.00',
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _currentStep = 0;
                                    _phoneController.clear();
                                    _amountController.clear();
                                  });
                                },
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Back'),
                              ),
                              ElevatedButton.icon(
                                onPressed: _isProcessing ? null : _submitPayment,
                                icon: _isProcessing 
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.lock),
                                label: Text(_isProcessing ? 'Processing...' : 'Pay Securely'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Status message display
                          if (_statusMessage.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isProcessing 
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Theme.of(context).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  if (_isProcessing)
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.onErrorContainer,
                                    ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _statusMessage,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: _isProcessing
                                          ? Theme.of(context).colorScheme.onPrimaryContainer
                                          : Theme.of(context).colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                
                if (_currentStep == 2) ...[
                  Card(
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Payment Successful!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '🎉 Welcome to Premium!',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Thank you for upgrading to Premium. Your plan is now active and you have access to all premium features.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Activated: September 25, 2025, 10:41 AM CEST',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _reset,
                                  child: const Text('Back to Plans'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Go back to main app
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  child: const Text('Continue'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    final isCompleted = _currentStep > step;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted 
              ? Theme.of(context).colorScheme.primary
              : isActive 
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
              width: 2,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.circle,
            size: 16,
            color: isCompleted 
              ? Theme.of(context).colorScheme.onPrimary
              : isActive 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isActive 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isCompleted = _currentStep > step;
    
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isCompleted 
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}