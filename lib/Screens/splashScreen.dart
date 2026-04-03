import 'package:chatbox_app/Screens/signUpScreen.dart';
import 'package:chatbox_app/Screens/mainScreen.dart';
import 'package:chatbox_app/const/appDurations.dart';
import 'package:chatbox_app/const/app_assets.dart';
import 'package:chatbox_app/const/colors.dart';
import 'package:chatbox_app/controllers/authController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Services/shared_pref_session.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Show splash for at least 2 seconds for smooth transition
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Check if user is logged in via LocalStorageService
      final isLoggedIn = await LocalStorageService.isLoggedIn();
      final savedUserId = await LocalStorageService.getUserId();
      final savedProfile = await LocalStorageService.getSavedProfile();

      print('🔍 Splash Screen Check:');
      print('   isLoggedIn: $isLoggedIn');
      print('   savedUserId: $savedUserId');
      print('   hasProfile: ${savedProfile != null}');

      if (isLoggedIn && savedUserId != null) {
        // User has saved session, check Supabase session
        final currentUser = authController.user.value;

        if (currentUser != null) {
          // Valid Supabase session, go to home
          print('✅ Valid session found - Navigating to Home');

          // Restore profile to controller if available
          if (savedProfile != null) {
            authController.savedProfile.value = savedProfile;
          }

          Get.offAll(
                () => MainNavigation(),
            transition: Transition.rightToLeft,
            duration: Duration(milliseconds: AppDurations.miliSeconds),
          );
        } else {
          // Supabase session expired but we have local data
          // Try to refresh token or go to login
          print('⚠️ Session expired - Navigating to Login');
          await LocalStorageService.clearUserSession();

          Get.offAll(
                () => SignupScreen(),
            transition: Transition.rightToLeft,
            duration: Duration(milliseconds: AppDurations.miliSeconds),
          );
        }
      } else {
        // No saved session, go to login
        print('👤 No session found - Navigating to Login');

        Get.offAll(
              () => SignupScreen(),
          transition: Transition.rightToLeft,
          duration: Duration(milliseconds: AppDurations.miliSeconds),
        );
      }
    } catch (e) {
      print('❌ Error in splash screen: $e');
      // On error, go to login as safe fallback
      Get.offAll(
            () => SignupScreen(),
        transition: Transition.rightToLeft,
        duration: Duration(milliseconds: AppDurations.miliSeconds),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo with fade-in animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.5, end: 1),
              duration: const Duration(seconds: 1),
              child: Image.asset(
                AppAssets.app_icon,
                width: 150,
                height: 150,
              ),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: value,
                    child: child,
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // App name with fade-in animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              child: Text(
                'Chat Room',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
            ),

            const SizedBox(height: 40),

            // Loading indicator
            CircularProgressIndicator(
              color: AppColors.blueColor,
            ),

            const SizedBox(height: 20),

            // Loading text with fade animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              child: Text(
                'Loading your chats...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}