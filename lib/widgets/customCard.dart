import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../const/colors.dart';

class Customcard extends StatelessWidget {
  final String title;
  final model;
  const Customcard({super.key, required this.model, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundImage: NetworkImage(model.profileImageUrl),
                backgroundColor: Colors.grey[300],
              ),
              if (title=="Home")
                if(model.isOnline)
                  Positioned(
                    bottom: 2.h,
                    right: 2.w,
                    child: Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.w),
                      ),
                    ),
                  ),
            ],
          ),

          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        model.userName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if(title=="Home")
                      Text(
                        model.timestamp,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      )
                    else if(title=="Calls")
                      Row(
                        children: [
                          Icon(
                            Icons.call,
                            color: AppColors.navTextColor,
                            size: 24,
                          ),
                          SizedBox(width: 10.w,),
                          Icon(
                            Icons.video_call,
                            color: AppColors.navTextColor,
                            size: 24,
                          )
                        ],
                      )
                  ],
                ),
                SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
    title == "Home"
    ? (model.lastMessage ?? "")
        : title == "Calls"
    ? (model.timestamp ?? "")
        : (model.bio ?? ""),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                     if(title=="Home")
                       if (model.unreadCount > 0)
                         Container(
                           margin: EdgeInsets.only(left: 8.w),
                           padding: EdgeInsets.symmetric(
                             horizontal: 8.w,
                             vertical: 4.h,
                           ),
                           decoration: BoxDecoration(
                             color: AppColors.blueColor,
                             borderRadius: BorderRadius.circular(50.r),
                           ),
                           child: Text(
                             model.unreadCount > 99 ? '99+' : '${model.unreadCount}',
                             style: TextStyle(
                               color: Colors.white,
                               fontSize: 12.sp,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                    ],
                  ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
