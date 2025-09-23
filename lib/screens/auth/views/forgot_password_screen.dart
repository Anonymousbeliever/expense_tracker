import 'package:flutter/material.dart';
import 'package:expense_tracker/data/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authService.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send reset email')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              color: Theme.of(context).colorScheme.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Forgot Your Password?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter your email address and we\'ll send you a link to reset your password.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          hintText: 'Enter your email address',
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Enter your email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Send Reset Link',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: Text(
                        'Back to Login',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Demo Mode: Password reset emails are simulated. Use demo credentials to test the app.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}