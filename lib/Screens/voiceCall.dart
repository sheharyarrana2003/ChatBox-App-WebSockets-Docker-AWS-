import 'package:chatbox_app/const/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../const/colors.dart';

class VoiceScreen extends StatelessWidget {
  final String imgUrl;
  final String title;
  const VoiceScreen({super.key, required this.imgUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navTextColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.blueColor,
                width: 3.w,
              ),
            ),
            child: CircleAvatar(
              radius: 70.r,
              backgroundImage: NetworkImage(imgUrl),
            ),
          ),

          SizedBox(height: 16.h),
          Text(
            title,
            style: AppFonts.f20.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Text(
            "00:25",
            style: AppFonts.f18,
          ),

          SizedBox(height: 100.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.message,
                  color: AppColors.blueColor,
                  onPressed: () {},
                ),
                _buildActionButton(
                  icon: Icons.mic_off,
                  color: AppColors.blueColor,
                  onPressed: () {},
                ),
                _buildActionButton(
                  icon: Icons.volume_up,
                  color: AppColors.blueColor,
                  onPressed: () {},
                ),
                FloatingActionButton(
                  heroTag: "end",
                  backgroundColor: Colors.red,
                  onPressed: () {},
                  child: Icon(Icons.call_end, color: Colors.white,size: 28.sp,),
                ),
              ],
            ),
          )
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
      backgroundColor: Colors.white,
      onPressed: onPressed,
      child: Icon(icon, color: color,size: 28.sp,),
    );
  }
}
