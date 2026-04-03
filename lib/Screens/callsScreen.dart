import 'package:chatbox_app/const/fonts.dart';
import 'package:chatbox_app/widgets/customCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../const/colors.dart';
import '../controllers/callsController.dart';

class CallsScreen extends StatelessWidget {
  CallsScreen({super.key});
  final CallController callsController=Get.put(CallController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueColor,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 15.h,horizontal: 15.w),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recent Calls",style: AppFonts.f16.copyWith(fontWeight: FontWeight.w700),),
            Expanded(
              child: _buildCallsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallsList(){
    return Obx(
        (){
          if(callsController.isLoading.value){
            return Center(child: CircularProgressIndicator(color: AppColors.blueColor,),);
          }
          final calls=callsController.callsList;
          if(calls.isEmpty){
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.call_end,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "No calls found",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            separatorBuilder: (context,index)=>SizedBox(height: 8.h,),
            itemCount: calls.length,
              itemBuilder: (context,index){
              final call=calls[index];
              return Customcard(model: call,title: "Calls",);
              },
          );
        }
    );
  }

}
