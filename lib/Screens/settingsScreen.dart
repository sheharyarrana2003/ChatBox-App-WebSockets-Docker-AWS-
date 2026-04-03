// Screens/SettingsScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../const/colors.dart';
import '../const/fonts.dart';
import '../controllers/authController.dart';
import '../models/profile_model.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueColor,
      body: Column(
        children: [
          // Header Section (Blue part)
          _buildHeader(),

          // White Container with Settings
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
              ),
              child: Obx(() {
                final profile = authController.savedProfile.value;

                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Profile Card (Inside White Container)
                      _buildUserProfileCard(profile),

                      SizedBox(height: 20.h),

                      // Settings Sections
                      _buildSettingsSection(
                        title: "Account",
                        items: [
                          _buildSettingTile(
                            icon: Icons.privacy_tip_outlined,
                            title: "Privacy",
                            subtitle: "Last seen, profile photo, status",
                            onTap: () {},
                          ),
                          _buildSettingTile(
                            icon: Icons.security_outlined,
                            title: "Security",
                            subtitle: "Two-step verification, change PIN",
                            onTap: () {},
                          ),
                          _buildSettingTile(
                            icon: Icons.phone_android_outlined,
                            title: "Change Number",
                            subtitle: "Transfer account to new number",
                            onTap: () {},
                          ),
                        ],
                      ),

                      SizedBox(height: 15.h),

                      _buildSettingsSection(
                        title: "Chat",
                        items: [
                          _buildSettingTile(
                            icon: Icons.message_outlined,
                            title: "Chat History",
                            subtitle: "Backup, export, delete chats",
                            onTap: () {},
                          ),
                          _buildSettingTile(
                            icon: Icons.palette_outlined,
                            title: "Theme",
                            subtitle: "Dark mode, accent color",
                            onTap: () {},
                          ),
                          _buildSettingTile(
                            icon: Icons.wallpaper_outlined,
                            title: "Wallpaper",
                            subtitle: "Set chat background",
                            onTap: () {},
                          ),
                        ],
                      ),

                      SizedBox(height: 15.h),

                      _buildSettingsSection(
                        title: "Notifications",
                        items: [
                          _buildSettingTile(
                            icon: Icons.notifications_none_outlined,
                            title: "Message Notifications",
                            subtitle: "Sound, vibration, popup",
                            onTap: () {},
                          ),
                          _buildSettingTile(
                            icon: Icons.group_outlined,
                            title: "Group Notifications",
                            subtitle: "Mute, custom settings",
                            onTap: () {},
                          ),
                          _buildSettingTile(
                            icon: Icons.call_outlined,
                            title: "Call Notifications",
                            subtitle: "Ringtone, vibration",
                            onTap: () {},
                          ),
                        ],
                      ),

                      SizedBox(height: 15.h),

                      _buildSettingsSection(
                        title: "Storage & Data",
                        items: [
                          _buildSettingTile(
                            icon: Icons.storage_outlined,
                            title: "Storage Usage",
                            subtitle: "Manage device storage",
                            onTap: () {},
                          ),
                          _buildSettingTile(
                            icon: Icons.wifi_outlined,
                            title: "Network Usage",
                            subtitle: "Data saver, auto-download",
                            onTap: () {},
                          ),
                          _buildSettingTile(
                            icon: Icons.cloud_upload_outlined,
                            title: "Backup",
                            subtitle: "Google Drive backup",
                            onTap: () {},
                          ),
                        ],
                      ),

                      SizedBox(height: 15.h),

                      _buildSettingsSection(
                        title: "Help",
                        items: [
                          _buildSettingTile(
                            icon: Icons.help_outline,
                            title: "Help Center",
                            subtitle: "FAQs, guides, support",
                            onTap: () {},
                          ),
                          _buildSettingTile(
                            icon: Icons.privacy_tip_outlined,
                            title: "Privacy Policy",
                            subtitle: "Read our privacy policy",
                            onTap: () {},
                          ),
                          _buildSettingTile(
                            icon: Icons.info_outline,
                            title: "App Info",
                            subtitle: "Version 1.0.0, licenses",
                            onTap: () {},
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Logout Button
                      _buildLogoutButton(),

                      SizedBox(height: 20.h),

                      // App Version
                      Center(
                        child: Text(
                          "Chat Room v1.0.0",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Blue Header Section
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      width: double.infinity,
      color: AppColors.blueColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Settings",
                  style: AppFonts.fBold24.copyWith(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 24.sp,
                  ),
                ),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// User Profile Card inside white container
  Widget _buildUserProfileCard(Profile? profile) {
    final String displayName = profile?.username ?? 'User';
    final String? avatarUrl = profile?.avatarUrl;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.blueColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.blueColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.blueColor,
                width: 2.w,
              ),
            ),
            child: CircleAvatar(
              radius: 40.r,
              backgroundColor: Colors.grey[200],
              backgroundImage: _getProfileImage(profile),
              child: avatarUrl == null
                  ? Icon(
                Icons.person,
                color: AppColors.blueColor,
                size: 40.sp,
              )
                  : null,
            ),
          ),

          SizedBox(width: 16.w),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppFonts.f16.copyWith(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  profile?.email ?? 'No email',
                  style: AppFonts.f12.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "Online",
                    style: AppFonts.f20.copyWith(
                      color: AppColors.blueColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Edit Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.blueColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                // Navigate to edit profile
                Get.snackbar(
                  "Coming Soon",
                  "Edit profile feature coming soon!",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.blueColor,
                  colorText: Colors.white,
                );
              },
              icon: Icon(
                Icons.edit,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to get profile image from local data
  ImageProvider? _getProfileImage(Profile? profile) {
    final tempImage = authController.profileImage.value;

    // Priority 1: Temporarily selected image
    if (tempImage != null) {
      return FileImage(tempImage);
    }

    // Priority 2: Network URL (from Supabase storage)
    if (profile?.avatarUrl != null &&
        (profile!.avatarUrl!.startsWith('http') || profile.avatarUrl!.startsWith('https'))) {
      return NetworkImage(profile.avatarUrl!);
    }

    return null;
  }

  /// Settings Section with Title
  Widget _buildSettingsSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: Text(
            title,
            style: AppFonts.f14.copyWith(
              color: AppColors.blueColor,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  /// Individual Setting Tile
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.blueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: AppColors.blueColor,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.f14.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppFonts.f12.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  /// Logout Button
  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () => _showLogoutDialog(),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.red,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              "Logout",
              style: AppFonts.f16.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Logout Confirmation Dialog
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          "Logout",
          style: AppFonts.f18.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.blackColor,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: AppFonts.f14.copyWith(
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: AppFonts.f14.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              await authController.signOut(); // Call sign out
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }
}