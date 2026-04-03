import 'package:supabase_flutter/supabase_flutter.dart';

class SupaBaseOTP {
  final SupabaseClient client;
  SupaBaseOTP({required this.client});

  Future<void> signInWithOTP(String number) async {
    try {
      final nNumber = _normalizeNumber(number);
      await client.auth.signInWithOtp(
        phone: nNumber,
      );
    } catch (e) {
      print("Hello $e");
      throw PhoneAuthException(code: 0, message: "Failed to send code");
    }
  }

  Future<User?> verifyPhoneAuth(String number, String otp) async {
    final authResult = await client.auth.verifyOTP(
      phone: number,
      token: otp,
      type: OtpType.sms,
    );

    if (authResult.user == null) {
      throw PhoneAuthException(code: 401, message: "User auth failed");
    }

    return authResult.user; // ✅ Return user
  }

  String _normalizeNumber(String number) {
    var normalized = number.replaceAll(RegExp(r'\D'), '');
    if (!normalized.startsWith('+')) {
      normalized = '+$normalized';
    }
    final phoneRegx = RegExp(r'^\+?[1-9]\d{8,14}$');
    if (!phoneRegx.hasMatch(normalized)) {
      throw PhoneAuthException(code: 0, message: "Invalid phone number");
    }
    return normalized;
  }
}

class PhoneAuthException implements Exception {
  final int code;
  final String message;
  PhoneAuthException({required this.code, required this.message});
}
