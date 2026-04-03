import 'package:chatbox_app/Screens/loginScreen.dart';
import 'package:chatbox_app/const/appDurations.dart';
import 'package:chatbox_app/const/fonts.dart';
import 'package:chatbox_app/controllers/authController.dart';
import 'package:chatbox_app/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../const/colors.dart';
import '../widgets/customTextField.dart';

class SignupScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  SignupScreen({super.key});

  // Password visibility toggles
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

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
              // Header Section
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 40.sp,
                  color: AppColors.blueColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Create Account",
                style: AppFonts.fBoldAuth30.copyWith(
                  fontSize: 28.sp,
                  color: AppColors.blueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Fill in your details to get started",
                style: TextStyle(
                  color: AppColors.blackColor.withOpacity(0.6),
                  fontSize: 14.sp,
                ),
              ),

              SizedBox(height: 30.h),

              // Profile Image Section
              _buildProfileImageSection(),

              SizedBox(height: 30.h),

              // Form Section
              Form(
                key: authController.formKey,
                child: Column(
                  children: [
                    // Username Field
                    CustomTextField(
                      controller: authController.userNameController,
                      hintText: "e.g. John Doe",
                      labelText: "Username",
                      icon: Icons.person_outline_rounded,
                      validator: authController.validateName,
                    ),
                    SizedBox(height: 16.h),

                    // Email Field
                    CustomTextField(
                      controller: authController.emailController,
                      hintText: "e.g. john@example.com",
                      labelText: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: authController.validateEmail,
                    ),
                    SizedBox(height: 16.h),

                    // Password Field
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
                    SizedBox(height: 16.h),

                    // Confirm Password Field
                    Obx(() => CustomTextField(
                      controller: authController.confirmPasswordController,
                      hintText: "Re-enter your password",
                      labelText: "Confirm Password",
                      icon: Icons.lock_outline_rounded,
                      obscureText: !isConfirmPasswordVisible.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible.value
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: AppColors.blueColor,
                          size: 20.sp,
                        ),
                        onPressed: () => isConfirmPasswordVisible.toggle(),
                      ),
                      validator: authController.validateConfirmPassword,
                    )),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // Password Requirements
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Password Requirements:",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blueColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildRequirementTile(
                      "At least 6 characters",
                      authController.passwordController.text.length >= 6,
                    ),
                    _buildRequirementTile(
                      "Contains a number",
                      RegExp(r'[0-9]').hasMatch(authController.passwordController.text),
                    ),
                    _buildRequirementTile(
                      "Contains a letter",
                      RegExp(r'[a-zA-Z]').hasMatch(authController.passwordController.text),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // Sign Up Button
              Obx(() => authController.isLoading.value
                  ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.blueColor,
                ),
              )
                  : Custombutton(
                title: "Create Account",
                onTap: _handleSignUp,
              )),

              SizedBox(height: 16.h),

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
                      text: "By creating an account, you agree to our ",
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

              SizedBox(height: 20.h),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: AppColors.blackColor.withOpacity(0.6),
                      fontSize: 14.sp,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      authController.toggleMode(); // Switch to signup mode
                      Get.to(
                            () => LoginScreen(),
                        transition: Transition.rightToLeft,
                        duration: Duration(milliseconds: AppDurations.miliSeconds),
                      );
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: AppColors.blueColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Profile Image Section
  Widget _buildProfileImageSection() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.blueColor, width: 2.w),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withOpacity(0.1),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Obx(() {
            final image = authController.profileImage.value;
            final name = authController.userNameController.text.trim();

            return CircleAvatar(
              radius: 65.r,
              backgroundImage: image != null
                  ? FileImage(image)
                  : NetworkImage(
                "https://ui-avatars.com/api/?name=${Uri.encodeComponent(name.isNotEmpty ? name : 'User')}&background=0088CC&color=fff&size=130",
              ) as ImageProvider,
              backgroundColor: AppColors.whiteColor,
            );
          }),
        ),

        // Camera Button
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => _showImagePickerBottomSheet(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.blueColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.whiteColor, width: 2.w),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: AppColors.whiteColor,
                size: 20.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Requirement Tile
  Widget _buildRequirementTile(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14.sp,
            color: isMet ? Colors.green : Colors.grey,
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: isMet ? Colors.green : Colors.grey.shade600,
              decoration: isMet ? TextDecoration.lineThrough : TextDecoration.none,
              decorationColor: Colors.green,
              decorationThickness: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Handle Sign Up
  void _handleSignUp() {
    if (authController.formKey.currentState!.validate()) {
      authController.signUpWithEmail();
    }
  }

  // Image Picker Bottom Sheet
  void _showImagePickerBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 30.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 50.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.blackColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.5.r),
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              "Profile Photo",
              style: AppFonts.fBold24.copyWith(
                fontSize: 20.sp,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Choose how to add your photo",
              style: TextStyle(
                color: AppColors.blackColor.withOpacity(0.6),
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 24.h),

            // Camera Option
            _buildPickerOption(
              icon: Icons.camera_alt_rounded,
              title: "Take Photo",
              subtitle: "Use camera to take a new photo",
              color: Colors.blue,
              onTap: () {
                authController.pickImage(ImageSource.camera);
                Get.back();
              },
            ),
            SizedBox(height: 12.h),

            // Gallery Option
            _buildPickerOption(
              icon: Icons.photo_library_rounded,
              title: "Choose from Gallery",
              subtitle: "Select from your photo library",
              color: Colors.purple,
              onTap: () {
                authController.pickImage(ImageSource.gallery);
                Get.back();
              },
            ),

            SizedBox(height: 12.h),

            // Remove Option (if image exists)
            if (authController.profileImage.value != null)
              _buildPickerOption(
                icon: Icons.delete_outline_rounded,
                title: "Remove Photo",
                subtitle: "Remove current profile photo",
                color: Colors.red,
                onTap: () {
                  authController.profileImage.value = null;
                  Get.back();
                },
              ),

            SizedBox(height: 12.h),

            // Cancel Button
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blueColor,
                side: BorderSide(color: AppColors.blueColor.withOpacity(0.3)),
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Picker Option Tile
  Widget _buildPickerOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.blackColor.withOpacity(0.6),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        onTap: onTap,
      ),
    );
  }
}