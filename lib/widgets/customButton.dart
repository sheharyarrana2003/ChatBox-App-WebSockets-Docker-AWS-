import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import '../Screens/otpScreen.dart';
import '../const/appDurations.dart';
import '../const/colors.dart';

class Custombutton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const Custombutton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blueColor,
        foregroundColor: AppColors.whiteColor,
        elevation: 3,
        shadowColor: AppColors.blackColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(10.sp),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
