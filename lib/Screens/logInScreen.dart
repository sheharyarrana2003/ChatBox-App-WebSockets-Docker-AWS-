import 'dart:io';

import 'package:chatbox_app/Screens/otpScreen.dart';
import 'package:chatbox_app/const/appDurations.dart';
import 'package:chatbox_app/const/app_assets.dart';
import 'package:chatbox_app/const/fonts.dart';
import 'package:chatbox_app/controllers/authController.dart';
import 'package:chatbox_app/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../const/colors.dart';
import '../widgets/customTextField.dart';

class Loginscreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  Loginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 80.h,),
              Text(
                "Create Account",
                style: AppFonts.fBoldAuth30.copyWith(
                  fontSize: 32.sp,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "Add a profile photo and your details to get started",
                style: TextStyle(
                  color: AppColors.blackColor.withOpacity(0.6),
                  fontSize: 16.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 30.h),
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.blueColor),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blackColor.withOpacity(0.15),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Obx(() {
                      if (authController.profileImage.value != null) {
                        AppAssets.profileImage=authController.profileImage.value!;
                        return CircleAvatar(
                          radius: 80.r,
                          backgroundImage: FileImage(authController.profileImage.value!),
                        );
                      } else {
                        return CircleAvatar(
                          backgroundColor: AppColors.whiteColor,
                          radius: 80.r,
                          backgroundImage: NetworkImage(
                            "https://wallpapers.com/images/hd/generic-person-icon-profile-ulmsmhnz0kqafcqn-ulmsmhnz0kqafcqn.jpg",
                          ),
                        );
                      }
                    }),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _bottomSheet(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          border: Border.all(color: AppColors.blueColor, width: 1.5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blackColor.withOpacity(0.1),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.camera_alt, color: AppColors.blueColor, size: 24.sp),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30.h),

              Form(
                  key: authController.formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: authController.userNameController,
                        hintText: "Enter your full name",
                        labelText: "Full Name",
                        icon: Icons.person_outline,
                        validator: authController.nameValidation,
                      ),
                      SizedBox(height: 20.h),

                      CustomTextField(
                        controller: authController.numberController,
                        hintText: "e.g. +1 555 123 4567",
                        labelText: "Phone Number",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: authController.numberValidation,
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 30.h),

              Custombutton(
                title: "Continue",
                onTap: () {
                  Get.to(
                        () => Otpscreen(),
                    transition: Transition.rightToLeft,
                    duration: Duration(milliseconds: AppDurations.miliSeconds),
                  );
                },
              ),


              SizedBox(height: 20.h),

              Text(
                "By continuing, you agree to our Terms & Privacy Policy",
                style: TextStyle(
                  color: AppColors.blackColor.withOpacity(0.5),
                  fontSize: 12.sp,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _bottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 30.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(0, -5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.blackColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              "Choose Profile Photo",
              style: AppFonts.fBold24.copyWith(
                fontSize: 20.sp,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Select how you'd like to add your photo",
              style: TextStyle(
                color: AppColors.blackColor.withOpacity(0.6),
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 24.h),

            // Camera Option
            Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.blueColor.withOpacity(0.1),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.blueColor,
                    size: 24.sp,
                  ),
                ),
                title: Text(
                  "Take Photo",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blackColor,
                  ),
                ),
                subtitle: Text(
                  "Use camera to take a new photo",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.blackColor.withOpacity(0.6),
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                onTap: () {
                  authController.pickImage(ImageSource.camera);
                  Get.back();
                },
              ),
            ),

            // Gallery Option
            Container(
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.blueColor.withOpacity(0.1),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.blueColor,
                    size: 24.sp,
                  ),
                ),
                title: Text(
                  "Choose from Gallery",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blackColor,
                  ),
                ),
                subtitle: Text(
                  "Select from your photo library",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.blackColor.withOpacity(0.6),
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                onTap: () {
                  authController.pickImage(ImageSource.gallery);
                  Get.back();
                },
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}