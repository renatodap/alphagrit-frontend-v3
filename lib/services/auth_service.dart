import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Comprehensive authentication service with error handling and logging
class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up with email and password
  /// Returns AuthResult with success/error details
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _log('SignUp attempt: $email');

      // Validate inputs
      final validation = _validateEmailPassword(email, password);
      if (!validation.isValid) {
        _log('SignUp validation failed: ${validation.message}');
        return AuthResult.error(validation.message!);
      }

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user == null) {
        _log('SignUp failed: No user returned');
        return AuthResult.error('Sign up failed. Please try again.');
      }

      _log('SignUp successful: ${response.user!.email}');

      // Check if email confirmation is required
      if (response.session == null) {
        return AuthResult.success(
          user: response.user!,
          message: 'Please check your email to confirm your account.',
          requiresEmailConfirmation: true,
        );
      }

      return AuthResult.success(
        user: response.user!,
        session: response.session!,
        message: 'Account created successfully!',
      );
    } on AuthException catch (e) {
      _log('SignUp AuthException: ${e.message}', isError: true);
      return AuthResult.error(_friendlyAuthError(e));
    } catch (e) {
      _log('SignUp unexpected error: $e', isError: true);
      return AuthResult.error('An unexpected error occurred. Please try again.');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _log('SignIn attempt: $email');

      // Validate inputs
      final validation = _validateEmailPassword(email, password);
      if (!validation.isValid) {
        _log('SignIn validation failed: ${validation.message}');
        return AuthResult.error(validation.message!);
      }

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null || response.session == null) {
        _log('SignIn failed: No user/session returned');
        return AuthResult.error('Login failed. Please try again.');
      }

      _log('SignIn successful: ${response.user!.email}');
      return AuthResult.success(
        user: response.user!,
        session: response.session!,
        message: 'Welcome back!',
      );
    } on AuthException catch (e) {
      _log('SignIn AuthException: ${e.message}', isError: true);
      return AuthResult.error(_friendlyAuthError(e));
    } catch (e) {
      _log('SignIn unexpected error: $e', isError: true);
      return AuthResult.error('An unexpected error occurred. Please try again.');
    }
  }

  /// Sign out current user
  Future<AuthResult> signOut() async {
    try {
      _log('SignOut attempt');
      await _client.auth.signOut();
      _log('SignOut successful');
      return AuthResult.success(message: 'Signed out successfully');
    } catch (e) {
      _log('SignOut error: $e', isError: true);
      return AuthResult.error('Failed to sign out. Please try again.');
    }
  }

  /// Send password reset email
  Future<AuthResult> resetPassword({required String email}) async {
    try {
      _log('ResetPassword attempt: $email');

      if (!_isValidEmail(email)) {
        return AuthResult.error('Please enter a valid email address');
      }

      await _client.auth.resetPasswordForEmail(email);

      _log('ResetPassword email sent: $email');
      return AuthResult.success(
        message: 'Password reset email sent! Check your inbox.',
      );
    } on AuthException catch (e) {
      _log('ResetPassword AuthException: ${e.message}', isError: true);
      return AuthResult.error(_friendlyAuthError(e));
    } catch (e) {
      _log('ResetPassword unexpected error: $e', isError: true);
      return AuthResult.error('Failed to send reset email. Please try again.');
    }
  }

  /// Update password (must be authenticated)
  Future<AuthResult> updatePassword({required String newPassword}) async {
    try {
      _log('UpdatePassword attempt');

      if (!isAuthenticated) {
        return AuthResult.error('You must be logged in to change your password');
      }

      if (newPassword.length < 6) {
        return AuthResult.error('Password must be at least 6 characters');
      }

      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        _log('UpdatePassword failed: No user returned');
        return AuthResult.error('Failed to update password. Please try again.');
      }

      _log('UpdatePassword successful');
      return AuthResult.success(
        user: response.user!,
        message: 'Password updated successfully!',
      );
    } on AuthException catch (e) {
      _log('UpdatePassword AuthException: ${e.message}', isError: true);
      return AuthResult.error(_friendlyAuthError(e));
    } catch (e) {
      _log('UpdatePassword unexpected error: $e', isError: true);
      return AuthResult.error('Failed to update password. Please try again.');
    }
  }

  /// Update email (must be authenticated)
  Future<AuthResult> updateEmail({required String newEmail}) async {
    try {
      _log('UpdateEmail attempt: $newEmail');

      if (!isAuthenticated) {
        return AuthResult.error('You must be logged in to change your email');
      }

      if (!_isValidEmail(newEmail)) {
        return AuthResult.error('Please enter a valid email address');
      }

      final response = await _client.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      if (response.user == null) {
        _log('UpdateEmail failed: No user returned');
        return AuthResult.error('Failed to update email. Please try again.');
      }

      _log('UpdateEmail successful: $newEmail');
      return AuthResult.success(
        user: response.user!,
        message: 'Email update link sent! Check your new email to confirm.',
        requiresEmailConfirmation: true,
      );
    } on AuthException catch (e) {
      _log('UpdateEmail AuthException: ${e.message}', isError: true);
      return AuthResult.error(_friendlyAuthError(e));
    } catch (e) {
      _log('UpdateEmail unexpected error: $e', isError: true);
      return AuthResult.error('Failed to update email. Please try again.');
    }
  }

  /// Resend email confirmation
  Future<AuthResult> resendConfirmationEmail({required String email}) async {
    try {
      _log('ResendConfirmation attempt: $email');

      if (!_isValidEmail(email)) {
        return AuthResult.error('Please enter a valid email address');
      }

      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      _log('ResendConfirmation email sent: $email');
      return AuthResult.success(
        message: 'Confirmation email resent! Check your inbox.',
      );
    } on AuthException catch (e) {
      _log('ResendConfirmation AuthException: ${e.message}', isError: true);
      return AuthResult.error(_friendlyAuthError(e));
    } catch (e) {
      _log('ResendConfirmation unexpected error: $e', isError: true);
      return AuthResult.error('Failed to resend confirmation. Please try again.');
    }
  }

  /// Validate email and password
  ValidationResult _validateEmailPassword(String email, String password) {
    if (email.isEmpty) {
      return ValidationResult(isValid: false, message: 'Please enter your email');
    }

    if (!_isValidEmail(email)) {
      return ValidationResult(isValid: false, message: 'Please enter a valid email address');
    }

    if (password.isEmpty) {
      return ValidationResult(isValid: false, message: 'Please enter your password');
    }

    if (password.length < 6) {
      return ValidationResult(isValid: false, message: 'Password must be at least 6 characters');
    }

    return ValidationResult(isValid: true);
  }

  /// Check if email is valid
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Convert Supabase AuthException to friendly error message
  String _friendlyAuthError(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return 'Invalid email or password. Please try again.';
    }

    if (message.contains('email not confirmed')) {
      return 'Please confirm your email before logging in.';
    }

    if (message.contains('user already registered')) {
      return 'An account with this email already exists.';
    }

    if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }

    if (message.contains('password')) {
      return 'Password must be at least 6 characters.';
    }

    if (message.contains('network')) {
      return 'Network error. Please check your connection.';
    }

    if (message.contains('rate limit')) {
      return 'Too many attempts. Please try again later.';
    }

    // Return original message if no friendly match
    return e.message;
  }

  /// Log auth events
  void _log(String message, {bool isError = false}) {
    final prefix = isError ? '❌ [AuthService]' : '✅ [AuthService]';
    if (kDebugMode) {
      print('$prefix $message');
    }
    // TODO: Send to remote logging service in production
  }
}

/// Result of an authentication operation
class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final Session? session;
  final bool requiresEmailConfirmation;

  const AuthResult({
    required this.success,
    this.message,
    this.user,
    this.session,
    this.requiresEmailConfirmation = false,
  });

  factory AuthResult.success({
    String? message,
    User? user,
    Session? session,
    bool requiresEmailConfirmation = false,
  }) {
    return AuthResult(
      success: true,
      message: message,
      user: user,
      session: session,
      requiresEmailConfirmation: requiresEmailConfirmation,
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult(
      success: false,
      message: message,
    );
  }
}

/// Result of input validation
class ValidationResult {
  final bool isValid;
  final String? message;

  const ValidationResult({
    required this.isValid,
    this.message,
  });
}
