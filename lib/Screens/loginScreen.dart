import 'package:chatbox_app/Screens/signUpScreen.dart';
import 'package:chatbox_app/const/appDurations.dart';
import 'package:chatbox_app/const/fonts.dart';
import 'package:chatbox_app/controllers/authController.dart';
import 'package:chatbox_app/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../const/colors.dart';
import '../widgets/customTextField.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  LoginScreen({super.key});

  // Password visibility toggle
  final RxBool isPasswordVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Section with Welcome Back
              SizedBox(height: 40.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 50.sp,
                  color: AppColors.blueColor,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Welcome Back!",
                style: AppFonts.fBoldAuth30.copyWith(
                  fontSize: 32.sp,
                  color: AppColors.blueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Sign in to continue chatting",
                style: TextStyle(
                  color: AppColors.blackColor.withOpacity(0.6),
                  fontSize: 16.sp,
                ),
              ),

              SizedBox(height: 50.h),

              // Form Section
              Form(
                key: authController.formKey,
                child: Column(
                  children: [
                    // Email Field
                    CustomTextField(
                      controller: authController.emailController,
                      hintText: "e.g. john@example.com",
                      labelText: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: authController.validateEmail,
                    ),
                    SizedBox(height: 20.h),

                    // Password Field with visibility toggle
                    Obx(() => CustomTextField(
                      controller: authController.passwordController,
                      hintText: "Enter your password",
                      labelText: "Password",
                      icon: Icons.lock_outline_rounded,
                      obscureText: !isPasswordVisible.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible.value
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: AppColors.blueColor,
                          size: 20.sp,
                        ),
                        onPressed: () => isPasswordVisible.toggle(),
                      ),
                      validator: authController.validatePassword,
                    )),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to forgot password screen
                    Get.snackbar(
                      "Coming Soon",
                      "Password reset feature coming soon!",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: AppColors.blueColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Sign In Button
              Obx(() => authController.isLoading.value
                  ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.blueColor,
                ),
              )
                  : Custombutton(
                title: "Sign In",
                onTap: _handleSignIn,
              )),

              SizedBox(height: 30.h),

              // OR Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                ],
              ),

              SizedBox(height: 30.h),

              // Continue without signing in
              OutlinedButton(
                onPressed: () {
                  // Navigate to home as guest
                  Get.snackbar(
                    "Guest Mode",
                    "You can browse, but won't be able to chat",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.blueColor,
                  side: BorderSide(color: AppColors.blueColor.withOpacity(0.3)),
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "Continue as Guest",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
              ),

              SizedBox(height: 20.h),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: AppColors.blackColor.withOpacity(0.6),
                      fontSize: 14.sp,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      authController.toggleMode(); // Switch to signup mode
                      Get.to(
                            () => SignupScreen(),
                        transition: Transition.rightToLeft,
                        duration: Duration(milliseconds: AppDurations.miliSeconds),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: AppColors.blueColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Terms and Privacy
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: AppColors.blackColor.withOpacity(0.5),
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: "By signing in, you agree to our ",
                    ),
                    TextSpan(
                      text: "Terms of Service",
                      style: TextStyle(
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: TextStyle(
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle Sign In
  void _handleSignIn() {
    if (authController.formKey.currentState!.validate()) {
      authController.signInWithEmail();
    }
  }
}