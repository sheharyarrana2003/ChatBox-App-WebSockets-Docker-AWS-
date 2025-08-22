import 'package:chatbox_app/Screens/homeScreen.dart';
import 'package:chatbox_app/const/appDurations.dart';
import 'package:chatbox_app/const/fonts.dart';
import 'package:chatbox_app/controllers/authController.dart';
import 'package:chatbox_app/widgets/customButton.dart';
import 'package:chatbox_app/widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../const/colors.dart';
import 'mainScreen.dart';

class Otpscreen extends StatelessWidget {
  final AuthController authController=Get.put(AuthController());
  Otpscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 30.h,),
                Text("OTP Verification",style: AppFonts.fBold24.copyWith(color: AppColors.blueColor),),
                SizedBox(height: 16.h,),
                RichText(
                  text: TextSpan(
                      children: [
                        TextSpan(
                          text: "We have sent an OTP to ",
                          style: AppFonts.f16.copyWith(color: AppColors.blackColor),
                        ),
                        TextSpan(
                            text: authController.numberController.text,
                            style: AppFonts.f16.copyWith(color: AppColors.blueColor)
                        )
                      ]
                  ),
                ),
                SizedBox(height: 15.h,),
                CustomTextField(
                  controller: authController.otpController,
                  hintText: "Enter OTP",
                  labelText: "OTP",
                  icon: Icons.numbers_outlined,
                  keyboardType: TextInputType.phone,
                  validator: authController.otpValidation,
                ),
                SizedBox(height: 20.h,),
                Custombutton(title: "Verfiy", onTap: (){
                  Get.offAll(()=>MainNavigation(),
                  transition: Transition.rightToLeft,
                    duration: Duration(milliseconds: AppDurations.miliSeconds)
                  );
                }),
                SizedBox(height: 20.h,),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Didn't receive an OTP? ",
                        style: AppFonts.f16.copyWith(color: AppColors.blackColor),
                      ),
                      TextSpan(
                        text: "Resend OTP",
                        style: AppFonts.f16.copyWith(color: AppColors.blueColor)
                      )
                    ]
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
