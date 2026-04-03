import 'package:chatbox_app/const/appDurations.dart';
import 'package:chatbox_app/const/fonts.dart';
import 'package:chatbox_app/controllers/authController.dart';
import 'package:chatbox_app/widgets/customButton.dart';
import 'package:chatbox_app/widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../const/colors.dart';
import 'mainScreen.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;
  final bool isSignUp; // true if coming from signup, false if from login

  EmailVerificationScreen({
    super.key,
    required this.email,
    this.isSignUp = true,
  });

  final AuthController authController = Get.find<AuthController>();

  // Default PIN put theme
  final defaultPinTheme = PinTheme(
    width: 56.w,
    height: 56.h,
    textStyle: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12.r),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back, color: AppColors.blueColor),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),

              SizedBox(height: 20.h),

              // Header
              Center(
                child: Column(
                  children: [
                    // Email Icon with animation
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_unread_outlined,
                        size: 60.sp,
                        color: AppColors.blueColor,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Text(
                      "Verify Your Email",
                      style: AppFonts.fBold24.copyWith(
                        color: AppColors.blueColor,
                        fontSize: 24.sp,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Email display
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        email,
                        style: AppFonts.f16.copyWith(
                          color: AppColors.blueColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Text(
                      isSignUp
                          ? "We've sent a verification code to your email"
                          : "Enter the verification code from your email",
                      textAlign: TextAlign.center,
                      style: AppFonts.f16.copyWith(
                        color: AppColors.blackColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // OTP Input using Pinput (better than regular TextField)
              Center(
                child: Pinput(
                  length: 8,
                  controller: authController.otpController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.blueColor),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: AppColors.blueColor.withOpacity(0.1),
                      border: Border.all(color: AppColors.blueColor),
                    ),
                  ),
                  onCompleted: (pin) {
                    // Auto-verify when all digits entered
                    _verifyCode();
                  },
                ),
              ),

              SizedBox(height: 8.h),

              // Manual entry option note
              Center(
                child: Text(
                  "Enter the 6-digit code",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Verify Button
              Obx(() => authController.isLoading.value
                  ? Center(child: CircularProgressIndicator(color: AppColors.blueColor))
                  : Custombutton(
                title: "Verify Email",
                onTap: _verifyCode,
              )),

              SizedBox(height: 24.h),

              // Magic Link Option
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
              ),

              // Magic Link Button
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.blueColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: AppColors.blueColor,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Use Magic Link Instead",
                          style: AppFonts.f16.copyWith(
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Click the link sent to your email",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // Resend Options
              Center(
                child: Column(
                  children: [
                    Text(
                      "Didn't receive the code?",
                      style: AppFonts.f16.copyWith(
                        color: AppColors.blackColor.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Resend options row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildResendOption(
                          icon: Icons.refresh,
                          label: "Resend Code",
                          onTap: _resendCode,
                        ),
                        SizedBox(width: 20.w),
                        Container(
                          height: 20.h,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(width: 20.w),
                        _buildResendOption(
                          icon: Icons.email,
                          label: "Resend Magic Link",
                          onTap: _resendMagicLink,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Change email option
              Center(
                child: TextButton(
                  onPressed: _changeEmail,
                  child: Text(
                    "Change email address",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResendOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.blueColor,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.blueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _verifyCode() {
    final otp = authController.otpController.text.trim();

    if (otp.isEmpty) {
      Get.snackbar(
        "Invalid Code",
        "Please enter the verification code",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Call verify method from AuthController
    authController.verifyEmailOTP(email, otp);
  }

  void _resendCode() async {
    try {
      await authController.sendEmailOTP();
      Get.snackbar(
        "Code Sent",
        "A new verification code has been sent to your email",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Failed",
        "Could not resend code: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _resendMagicLink() async {
    try {
      await authController.sendEmailOTP();
      Get.snackbar(
        "Magic Link Sent",
        "Check your email for the magic link",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Failed",
        "Could not send magic link: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _changeEmail() {
    Get.back(); // Go back to email input screen
  }
}

// Also create a simpler version for just OTP input if needed
class EmailOTPInputScreen extends StatelessWidget {
  final String email;

  EmailOTPInputScreen({super.key, required this.email});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Verification Code"),
        backgroundColor: AppColors.blueColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Verification Code",
              style: AppFonts.f18.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              "We've sent a 6-digit code to $email",
              style: AppFonts.f14.copyWith(color: Colors.grey.shade600),
            ),
            SizedBox(height: 24.h),

            // OTP Input Field
            CustomTextField(
              controller: authController.otpController,
              hintText: "Enter 6-digit code",
              labelText: "OTP",
              icon: Icons.numbers_outlined,
              keyboardType: TextInputType.number,
              maxlength: 8,
              validator: authController.validateOTP,
            ),

            SizedBox(height: 24.h),

            // Verify Button
            Obx(() => authController.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : Custombutton(
              title: "Verify",
              onTap: () {
                authController.verifyEmailOTP(
                  email,
                  authController.otpController.text,
                );
              },
            )),

            SizedBox(height: 16.h),

            // Resend Option
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: AppFonts.f14,
                  ),
                  GestureDetector(
                    onTap: () async {
                      try {
                        await authController.sendEmailOTP();
                        Get.snackbar("Success", "Code resent to $email");
                      } catch (e) {
                        Get.snackbar("Error", e.toString());
                      }
                    },
                    child: Text(
                      "Resend",
                      style: AppFonts.f14.copyWith(
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}