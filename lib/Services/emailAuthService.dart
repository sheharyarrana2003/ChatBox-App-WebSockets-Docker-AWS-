import 'package:supabase_flutter/supabase_flutter.dart';

class EmailAuthService {
  final SupabaseClient client;

  EmailAuthService({required this.client});

  // ==================== EMAIL + PASSWORD METHODS ====================

  Future<AuthResponse> signUpWithPassword({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      print('📧 Attempting sign up for: $email');

      final response = await client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: userData,
      );

      if (response.user != null) {
        print('✅ Sign up successful for: $email');
        print('   User ID: ${response.user!.id}');
        print('   Email confirmed: ${response.user!.emailConfirmedAt != null}');
      }

      return response;
    } on AuthException catch (e) {
      print('❌ Sign up error: ${e.message}');
      throw EmailAuthException(
        code: _mapAuthErrorCode(e.message),
        message: e.message,
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw EmailAuthException(code: 0, message: 'Sign up failed');
    }
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting sign in for: $email');

      final response = await client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (response.user != null) {
        print('✅ Sign in successful for: $email');
        print('   User ID: ${response.user!.id}');
      }

      return response;
    } on AuthException catch (e) {
      print('❌ Sign in error: ${e.message}');
      throw EmailAuthException(
        code: _mapAuthErrorCode(e.message),
        message: e.message,
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw EmailAuthException(code: 0, message: 'Sign in failed');
    }
  }

  // ==================== EMAIL OTP METHODS ====================

  /// Send OTP to email - FIXED: Removed invalid 'options' parameter
  Future<void> sendEmailOTP(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      print('📧 Sending 8-digit OTP to: $normalizedEmail');

      // FIXED: Correct syntax for signInWithOtp
      await client.auth.signInWithOtp(
        email: normalizedEmail,
        shouldCreateUser: true, // Direct parameter, not inside options
      );

      print('✅ 8-digit OTP sent successfully to: $normalizedEmail');
    } on AuthException catch (e) {
      print("❌ OTP send error: ${e.message}");
      throw EmailAuthException(
        code: _mapAuthErrorCode(e.message),
        message: "Failed to send verification code",
      );
    } catch (e) {
      print("❌ Unexpected error: $e");
      throw EmailAuthException(code: 0, message: "Failed to send code");
    }
  }

  /// Verify email OTP - FIXED: Correct parameter order
  Future<User?> verifyEmailOTP({
    required String email,
    required String token,
  }) async {
    try {
      print('🔐 Verifying 8-digit OTP for: $email');
      print('📝 OTP token: $token');

      final cleanToken = token.trim();

      // FIXED: Correct parameter order - token first, then type
      final authResult = await client.auth.verifyOTP(
        email: _normalizeEmail(email),
        token: cleanToken,
        type: OtpType.email,
      );

      if (authResult.user == null) {
        throw EmailAuthException(code: 401, message: "Invalid or expired code");
      }

      print('✅ OTP verified successfully for: $email');
      print('   User ID: ${authResult.user!.id}');

      return authResult.user;
    } on AuthException catch (e) {
      print("❌ OTP verify error: ${e.message}");
      throw EmailAuthException(
        code: _mapAuthErrorCode(e.message),
        message: e.message,
      );
    } catch (e) {
      print("❌ Unexpected error: $e");
      throw EmailAuthException(code: 0, message: "Verification failed");
    }
  }

  // ==================== PASSWORD RESET METHODS ====================

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      print('📧 Sending password reset to: $normalizedEmail');

      await client.auth.resetPasswordForEmail(
        normalizedEmail,
        redirectTo: 'com.yourapp://reset-password',
      );

      print('✅ Password reset email sent to: $normalizedEmail');
    } on AuthException catch (e) {
      print("❌ Password reset error: ${e.message}");
      throw EmailAuthException(
        code: _mapAuthErrorCode(e.message),
        message: e.message,
      );
    } catch (e) {
      print("❌ Unexpected error: $e");
      throw EmailAuthException(code: 0, message: "Failed to send reset email");
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      print('🔐 Updating password...');

      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      print('✅ Password updated successfully');
    } on AuthException catch (e) {
      print("❌ Password update error: ${e.message}");
      throw EmailAuthException(
        code: _mapAuthErrorCode(e.message),
        message: e.message,
      );
    } catch (e) {
      print("❌ Unexpected error: $e");
      throw EmailAuthException(code: 0, message: "Failed to update password");
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      print('👋 User signed out');
    } on AuthException catch (e) {
      print("❌ Sign out error: ${e.message}");
      throw EmailAuthException(
        code: _mapAuthErrorCode(e.message),
        message: e.message,
      );
    } catch (e) {
      print("❌ Unexpected error: $e");
      throw EmailAuthException(code: 0, message: "Failed to sign out");
    }
  }

  User? get currentUser => client.auth.currentUser;

  bool isEmailVerified() {
    final user = client.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  /// Refresh verification status - FIXED: Use getUser instead of reloadUser
  Future<bool> refreshEmailVerificationStatus() async {
    try {
      // FIXED: getUser() is the correct method to refresh user data
      final response = await client.auth.getUser();
      return response.user?.emailConfirmedAt != null;
    } catch (e) {
      print("❌ Error refreshing user: $e");
      return false;
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    try {
      await sendEmailOTP(email);
      print('✅ Verification email resent to: $email');
    } catch (e) {
      print("❌ Error resending verification: $e");
      throw EmailAuthException(code: 0, message: "Failed to resend verification");
    }
  }

  // ==================== HELPER METHODS ====================

  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9.!#$%&"*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$'
    );
    return emailRegex.hasMatch(email.trim());
  }

  int _mapAuthErrorCode(String? message) {
    if (message == null) return 0;

    if (message.contains('Invalid login credentials')) return 401;
    if (message.contains('Email not confirmed')) return 403;
    if (message.contains('User already registered')) return 409;
    if (message.contains('Token has expired')) return 410;
    if (message.contains('Password should be at least 6 characters')) return 422;
    if (message.contains('rate limit')) return 429;

    return 0;
  }

  String getUserFriendlyErrorMessage(EmailAuthException e) {
    switch (e.code) {
      case 401: return 'Invalid email or password';
      case 403: return 'Please verify your email first';
      case 409: return 'An account with this email already exists';
      case 410: return 'Verification code expired. Please request a new one.';
      case 422: return 'Password must be at least 6 characters';
      case 429: return 'Too many attempts. Please try again later';
      default: return e.message;
    }
  }
}

class EmailAuthException implements Exception {
  final int code;
  final String message;

  EmailAuthException({required this.code, required this.message});

  @override
  String toString() => 'EmailAuthException: $message (code: $code)';
}