import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../const/colors.dart';
import '../const/fonts.dart';
import '../controllers/authController.dart';
import '../controllers/statusController.dart';
import '../models/statusModel.dart';

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
  final AuthController authController = Get.put(AuthController());

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
      padding: EdgeInsets.symmetric(horizontal:12.w,vertical: 14.h),
      color: AppColors.blueColor,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Search Icon
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(
                Icons.search,
                color: AppColors.whiteColor,
                size: 24.sp,
              ),
            ),

            // Title
            Text(
              title,
              style: AppFonts.fBold24.copyWith(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w700,
                fontSize: 22.sp,
              ),
            ),

            // Profile Avatar or Icon
            _buildHeaderAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction() {
    if (title == "Home") {
      return Obx(() {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.w),
          ),
          child: CircleAvatar(
            radius: 22.r,
            backgroundColor: Colors.white,
            backgroundImage: authController.profileImage.value != null
                ? FileImage(authController.profileImage.value!)
                : null,
            child: authController.profileImage.value == null
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
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Icon(
          Icons.more_vert,
          color: AppColors.whiteColor,
          size: 24.sp,
        ),
      );
    }
  }

  Widget _buildStatusSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      color: AppColors.blueColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Section Header
          Padding(
            padding: EdgeInsets.only(right: 20.w, bottom: 15.h),
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
                    // Navigate to status screen
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

          // Status List
          SizedBox(
            height: 120.h,
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
          // Show my status options (view, delete, etc.)
        } else {
          // View status and mark as viewed
          statusController.markAsViewed(status.id);
        }
      },
      child: Container(
        width: 70.w,
        child: Column(
          children: [
            // Status Avatar with Border
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: status.isViewed
                    ? null
                    : LinearGradient(
                  colors: [Colors.purple, Colors.pink, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                color: status.isViewed ? Colors.white.withOpacity(0.3) : null,
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: status.isMyStatus && authController.profileImage.value != null
                        ? FileImage(authController.profileImage.value!)
                        : NetworkImage(status.profileImageUrl) as ImageProvider,
                    child: status.isMyStatus && authController.profileImage.value == null
                        ? Icon(Icons.person, color: Colors.white, size: 24.sp)
                        : null,
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
                          size: 12.sp,
                        ),
                      ),
                    ),

                  // Status Type Icon
                  if (!status.isMyStatus && status.statusType == 'video')
                    Positioned(
                      top: 2.h,
                      right: 2.w,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white,
                          size: 10.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // Status Name with Text Overflow Handling
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

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTabTapped,
          backgroundColor: Colors.transparent,
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
          items: [
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
      ),
    );
  }
}