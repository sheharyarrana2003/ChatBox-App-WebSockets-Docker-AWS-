import 'dart:io';

import 'package:chatbox_app/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../const/colors.dart';
import '../const/fonts.dart';
import '../controllers/authController.dart';
import '../controllers/statusController.dart';
import '../models/statusModel.dart';
import '../models/profile_model.dart'; // Add this import

class BaseScreen extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final String title;
  final Function(int) onTabTapped;

  BaseScreen({
    super.key,
    required this.title,
    required this.child,
    required this.currentIndex,
    required this.onTabTapped,
  });

  final StatusController statusController = Get.put(StatusController());
  final AuthController authController = Get.find<AuthController>();
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueColor,
      body: Column(
        children: [
          _buildHeader(),
          if (title == "Home") _buildStatusSection(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      color: AppColors.blueColor,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.navTextColor),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Icon(
                Icons.search,
                color: AppColors.whiteColor,
                size: 24.sp,
              ),
            ),

            Text(
              title,
              style: AppFonts.fBold24.copyWith(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w700,
                fontSize: 22.sp,
              ),
            ),

            _buildHeaderAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction() {
    if (title == "Home") {
      return Obx(() {
        // ✅ Get profile from AuthController's savedProfile
        final profile = authController.savedProfile.value;
        final tempImage = authController.profileImage.value;

        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.w),
          ),
          child: CircleAvatar(
            radius: 22.r,
            backgroundColor: Colors.white,
            // Priority: 1. Temp image (newly selected), 2. Local file from path, 3. Network URL, 4. Default icon
            backgroundImage: _getProfileImage(profile, tempImage),
            child: _getProfileImage(profile, tempImage) == null
                ? Icon(
              Icons.person,
              color: AppColors.blueColor,
              size: 24.sp,
            )
                : null,
          ),
        );
      });
    } else {
      if (title == "Contacts" || title == "Calls") {
        return Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.navTextColor),
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Icon(
            title == "Calls" ? Icons.add_call : Icons.perm_contact_cal_rounded,
            color: AppColors.whiteColor,
            size: 24.sp,
          ),
        );
      }
      return const SizedBox.shrink();
    }
  }

  /// Helper method to get the appropriate profile image
  ImageProvider? _getProfileImage(Profile? profile, File? tempImage) {
    // Priority 1: Temporarily selected image (during profile creation/update)
    if (tempImage != null) {
      return FileImage(tempImage);
    }

    // Priority 2: Local file from saved profile path
    if (profile?.avatarUrl != null && profile!.avatarUrl!.startsWith('file://')) {
      try {
        return FileImage(File(profile.avatarUrl!));
      } catch (e) {
        print('Error loading local avatar: $e');
      }
    }

    // Priority 3: Network URL (from Supabase storage)
    if (profile?.avatarUrl != null &&
        (profile!.avatarUrl!.startsWith('http') || profile.avatarUrl!.startsWith('https'))) {
      return NetworkImage(profile.avatarUrl!);
    }

    // No valid image source
    return null;
  }

  Widget _buildStatusSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      color: AppColors.blueColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 20.w, bottom: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Status",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to status page
                  },
                  child: Text(
                    "See all",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 140.h,
            child: Obx(() {
              if (statusController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.w,
                  ),
                );
              }

              final recentStatuses = statusController.recentStatuses;

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(right: 20.w),
                itemCount: recentStatuses.length,
                separatorBuilder: (context, index) => SizedBox(width: 15.w),
                itemBuilder: (context, index) {
                  final status = recentStatuses[index];
                  return _buildStatusItem(status);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(StatusModel status) {
    return GestureDetector(
      onTap: () {
        if (status.isMyStatus) {
          // TODO: Navigate to add status
        } else {
          statusController.markAsViewed(status.id);
        }
      },
      child: Container(
        width: 60.w,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status.isViewed ? Colors.white.withOpacity(0.9) : Colors.black,
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 32.r,
                    backgroundColor: Colors.grey[300],
                    // ✅ Use local profile data for "My Status"
                    backgroundImage: status.isMyStatus
                        ? _getMyStatusImage()
                        : NetworkImage(status.profileImageUrl) as ImageProvider,
                  ),

                  // Add Status Icon (for my status)
                  if (status.isMyStatus)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.w),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 8.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            Container(
              width: 70.w,
              child: Text(
                status.isMyStatus ? "My Status" : status.userName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to get "My Status" profile image from local data
  ImageProvider? _getMyStatusImage() {
    final profile = authController.savedProfile.value;
    final tempImage = authController.profileImage.value;

    // Priority 1: Temporarily selected image
    if (tempImage != null) {
      return FileImage(tempImage);
    }

    // Priority 2: Local file from saved profile
    if (profile?.avatarUrl != null && profile!.avatarUrl!.startsWith('file://')) {
      try {
        return FileImage(File(profile.avatarUrl!));
      } catch (e) {
        print('Error loading local avatar for status: $e');
      }
    }

    // Priority 3: Network URL
    if (profile?.avatarUrl != null &&
        (profile!.avatarUrl!.startsWith('http') || profile.avatarUrl!.startsWith('https'))) {
      return NetworkImage(profile.avatarUrl!);
    }

    return null;
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabTapped,
        backgroundColor: AppColors.whiteColor,
        selectedItemColor: AppColors.blueColor,
        unselectedItemColor: AppColors.navTextColor,
        showUnselectedLabels: true,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
        selectedIconTheme: IconThemeData(size: 26.sp),
        unselectedIconTheme: IconThemeData(size: 24.sp),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message_rounded),
            activeIcon: Icon(Icons.message),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call_outlined),
            activeIcon: Icon(Icons.call),
            label: "Calls",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts_outlined),
            activeIcon: Icon(Icons.contacts),
            label: "Contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}