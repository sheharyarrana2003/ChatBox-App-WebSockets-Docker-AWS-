import 'dart:io';
import 'package:chatbox_app/Screens/mainScreen.dart'; // ✅ Fixed import: MainNavigation is in mainScreen.dart
import 'package:chatbox_app/const/appDurations.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Services/profile_service.dart';
import '../models/profile_model.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final ProfileService _service = Get.find<ProfileService>();

  var profile = Rxn<Profile>();
  var isLoading = false.obs;

  /// Create profile after OTP verification
  Future<Profile?> createMyProfile({
    required String userId,
    required String email,
    required String name,
    File? avatarFile,
    String? avatarFileExtension,
  }) async {
    // ✅ Prevent multiple simultaneous calls
    if (isLoading.value) return null;

    try {
      isLoading(true);

      final result = await _service.createProfile(
        userId: userId,
        email: email,
        name: name,
        avatarFile: avatarFile,
        avatarFileExtension: avatarFileExtension,
      );

      if (result != null) {
        profile.value = result;
        print("✅ Profile created successfully for user: $userId");

        // ✅ Navigate only after success
        Get.offAll(
              () => MainNavigation(), // ✅ Should be defined in mainScreen.dart
          transition: Transition.rightToLeft,
          duration: Duration(milliseconds: AppDurations.miliSeconds),
        );

        return profile.value;
      } else {
        Get.snackbar("Setup Failed", "Could not save profile. Please try again.");
        return null;
      }
    } on Exception catch (e) {
      print("❌ Profile creation failed: $e");
      Get.snackbar("Error", "Something went wrong. Please retry.");
      return null;
    } finally {
      isLoading(false);
    }
  }

  Future<Profile?> getMyProfile() async {
    if (isLoading.value) return profile.value;

    try {
      isLoading(true);
      final SupabaseClient supabase = Get.find<SupabaseClient>();
      final String? userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        print("❌ No user logged in");
        return null;
      }

      final data = await _service.fetchProfile(userId);
      if (data != null) {
        profile.value = data;
        print("📄 Profile loaded: ${data.username}");
        return data;
      } else {
        print("📄 No profile found for user: $userId");
        return null;
      }
    } catch (e) {
      print("❌ Failed to load profile: $e");
      return null;
    } finally {
      isLoading(false);
    }
  }

  /// Clear profile (on logout)
  void clearProfile() {
    profile.value = null;
  }
}