import 'package:chatbox_app/const/fonts.dart';
import 'package:chatbox_app/controllers/authController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../const/colors.dart';

class VideoCallScreen extends StatelessWidget {
  final String receiverImgUrl;
  final String title;

  VideoCallScreen({super.key, required this.receiverImgUrl, required this.title});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navTextColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 80.h,),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blueColor, width: 3.w),
            ),
            child: CircleAvatar(
              radius: 80.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: NetworkImage(receiverImgUrl),
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            title,
            style: AppFonts.f20.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),

          Text(
            "01:25",
            style:AppFonts.f18,
          ),

          SizedBox(height: 100.h),

          Obx(() {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.blueColor, width: 3.w),
              ),
              child: CircleAvatar(
                radius: 80.r,
                backgroundColor: Colors.white,
                backgroundImage: authController.profileImage.value != null
                    ? FileImage(authController.profileImage.value!)
                    : null,
                child: authController.profileImage.value == null
                    ? Icon(Icons.person, color: AppColors.blueColor, size: 80.sp)
                    : null,
              ),
            );
          }),

          const Spacer(),

          // Action Buttons
          Padding(
            padding: EdgeInsets.only(bottom: 30.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(icon: Icons.message, color: AppColors.whiteColor, onPressed: () {

                }),
                _buildActionButton(icon: Icons.mic_off, color: AppColors.whiteColor, onPressed: () {

                }),
                _buildActionButton(icon: Icons.videocam, color: AppColors.whiteColor, onPressed: () {

                }),
                FloatingActionButton(
                  heroTag: "end",
                  backgroundColor: Colors.red,
                  onPressed: (){},
                  child: Icon(Icons.call_end, color: AppColors.whiteColor,size: 28.sp,),
                )

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return FloatingActionButton(
      heroTag: icon.toString(),
      backgroundColor: color,
      onPressed: onPressed,
      child: Icon(icon, color: AppColors.blueColor,size: 28.sp,),
    );
  }
}
