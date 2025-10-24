import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:alphagrit/services/auth_service.dart';
import 'package:alphagrit/app/providers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Improved login/signup screen with comprehensive error handling and validation
class LoginSignupScreen extends ConsumerStatefulWidget {
  final bool isSignup;

  const LoginSignupScreen({
    super.key,
    this.isSignup = false,
  });

  @override
  ConsumerState<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends ConsumerState<LoginSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _isSignup = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isSignup = widget.isSignup;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Clear previous messages
    setState(() {
      _successMessage = null;
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      final result = _isSignup
          ? await authService.signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _fullNameController.text.trim().isEmpty
                  ? null
                  : _fullNameController.text.trim(),
            )
          : await authService.signIn(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );

      if (!mounted) return;

      if (result.success) {
        setState(() => _successMessage = result.message);

        // If email confirmation required, show message but don't navigate
        if (result.requiresEmailConfirmation) {
          // User needs to confirm email, stay on this screen
          return;
        }

        // Navigate back or to home after successful auth
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
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

  void _toggleMode() {
    setState(() {
      _isSignup = !_isSignup;
      _successMessage = null;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: GritColors.black,
      appBar: AppBar(
        backgroundColor: GritColors.black,
        elevation: 0,
        title: Text(
          (_isSignup ? t.signup : t.login).toUpperCase(),
          style: const TextStyle(
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

                    // Full Name field (signup only)
                    if (_isSignup) ...[
                      TextFormField(
                        controller: _fullNameController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'Full Name (Optional)',
                          labelStyle: TextStyle(color: GritColors.grey),
                          prefixIcon: Icon(Icons.person_outline, color: GritColors.grey),
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
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                    ],

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
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: GritColors.grey),
                        prefixIcon: Icon(Icons.lock_outline, color: GritColors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: GritColors.grey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
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
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Forgot password link (login only)
                    if (!_isSignup)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading ? null : () => context.push('/forgot-password'),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: const Color(0xFF4A90E2),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
                            : Text(
                                (_isSignup ? t.signup : t.login).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Toggle mode
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignup ? 'Already have an account?' : 'Need an account?',
                          style: TextStyle(
                            color: GritColors.grey,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _toggleMode,
                          child: Text(
                            _isSignup ? t.login : t.signup,
                            style: const TextStyle(
                              color: Color(0xFF4A90E2),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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
