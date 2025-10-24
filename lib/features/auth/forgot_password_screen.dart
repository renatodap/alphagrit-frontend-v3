import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:alphagrit/services/auth_service.dart';
import 'package:alphagrit/app/providers.dart';

/// Forgot password screen - sends password reset email
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _successMessage = null;
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.resetPassword(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      if (result.success) {
        setState(() => _successMessage = result.message);
        _emailController.clear();

        // Navigate back after delay
        await Future.delayed(const Duration(seconds: 3));
        if (mounted && context.canPop()) {
          context.pop();
        }
      } else {
        setState(() => _errorMessage = result.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GritColors.black,
      appBar: AppBar(
        backgroundColor: GritColors.black,
        elevation: 0,
        title: const Text(
          'RESET PASSWORD',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E3A5F).withOpacity(0.2),
              GritColors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: const Color(0xFF4A90E2),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'Enter your email address and we\'ll send you a link to reset your password.',
                      style: TextStyle(
                        color: GritColors.grey,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Success message
                    if (_successMessage != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _successMessage!,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: GritColors.red.withOpacity(0.1),
                          border: Border.all(color: GritColors.red, width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: GritColors.red, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: GritColors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: GritColors.grey),
                        prefixIcon: Icon(Icons.email_outlined, color: GritColors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GritColors.grey.withOpacity(0.3), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color(0xFF4A90E2), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GritColors.red, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GritColors.red, width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2C2C34),
                      ),
                      style: TextStyle(color: GritColors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: GritColors.black,
                          shape: const BeveledRectangleBorder(),
                          elevation: 8,
                          disabledBackgroundColor: GritColors.grey,
                        ),
                        onPressed: _isLoading ? null : _handleSubmit,
                        child: _isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(GritColors.black),
                                ),
                              )
                            : const Text(
                                'SEND RESET LINK',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Back to login
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/login');
                              }
                            },
                      child: Text(
                        'Back to Login',
                        style: TextStyle(
                          color: GritColors.grey,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
}
