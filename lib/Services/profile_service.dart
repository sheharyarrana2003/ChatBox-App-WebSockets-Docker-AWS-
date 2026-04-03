import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import 'supabase_storage_service.dart'; // Relative import from same folder

class ProfileService {
  final SupabaseClient _supabase = Get.find<SupabaseClient>();
  final SupabaseStorageService _storage = Get.find<SupabaseStorageService>();

  Future<Profile?> createProfile({
    required String userId,
    required String email, // Changed from phoneNumber to email
    required String name,
    File? avatarFile,
    String? avatarFileExtension,
  }) async {
    String? avatarUrl;

    // Handle avatar upload if file is provided
    if (avatarFile != null) {
      // Determine file extension
      String ext = avatarFileExtension ??
          avatarFile.path.split('.').last.toLowerCase();

      // Validate extension
      if (!['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) {
        Get.snackbar(
          "Invalid Format",
          "Image must be JPG, PNG, WEBP or GIF. Using default avatar.",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        try {
          // Upload avatar using the storage service
          avatarUrl = await _storage.uploadAvatarFromFile(
            userId: userId,
            imageFile: avatarFile,  // Pass the File directly
          );

          if (avatarUrl == null) {
            Get.snackbar(
              "Warning",
              "Avatar upload failed. Using default avatar.",
              snackPosition: SnackPosition.BOTTOM,
            );
          } else {
            print('Avatar uploaded successfully: $avatarUrl');
          }
        } catch (e) {
          print('Avatar upload error: $e');
          Get.snackbar(
            "Upload Error",
            "Failed to upload avatar. Using default.",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    }

    // Use UI Avatars as fallback (reliable and fast)
    avatarUrl ??= 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=0D8F81&color=fff&size=200&bold=true';

    // Create profile object
    final profile = Profile(
      id: userId,
      email: email, // Changed from phoneNumber to email
      username: name,
      avatarUrl: avatarUrl,
      isOnline: true,
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // Insert profile into database
      final response = await _supabase
          .from('profiles')
          .insert(profile.toMap())
          .select()
          .single();

      print('Profile created successfully for user: $userId');
      return Profile.fromMap(response);

    } on PostgrestException catch (e) {
      print('Supabase insert error: ${e.message}');
      print('Error code: ${e.code}');
      print('Error details: ${e.details}');

      // Show user-friendly error message
      String errorMessage = 'Failed to save profile';
      if (e.message.contains('duplicate key') ?? false) {
        errorMessage = 'Profile already exists';
      } else if (e.message.contains('violates foreign key') ?? false) {
        errorMessage = 'User not found';
      }

      Get.snackbar(
        "Database Error",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return null;
    } catch (e) {
      print('Unexpected database error: $e');
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return null;
    }
  }

  /// Alternative method that handles XFile from image_picker
  Future<Profile?> createProfileWithXFile({
    required String userId,
    required String email, // Changed from phoneNumber to email
    required String name,
    dynamic imageXFile, // Can be XFile or File
  }) async {
    File? avatarFile;
    String? extension;

    if (imageXFile != null) {
      if (imageXFile is XFile) {
        avatarFile = File(imageXFile.path);
        extension = imageXFile.path.split('.').last;
      } else if (imageXFile is File) {
        avatarFile = imageXFile;
        extension = imageXFile.path.split('.').last;
      }
    }

    return createProfile(
      userId: userId,
      email: email, // Changed from phoneNumber to email
      name: name,
      avatarFile: avatarFile,
      avatarFileExtension: extension,
    );
  }

  /// Update existing profile
  Future<Profile?> updateProfile({
    required String userId,
    String? name,
    String? bio,
    File? newAvatarFile,
    String? avatarExtension,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) updates['username'] = name;
      if (bio != null) updates['bio'] = bio;
      updates['updated_at'] = DateTime.now().toIso8601String();

      // Handle avatar update
      if (newAvatarFile != null) {
        String ext = avatarExtension ??
            newAvatarFile.path.split('.').last.toLowerCase();

        final newAvatarUrl = await _storage.uploadAvatarFromFile(
          userId: userId,
          imageFile: newAvatarFile,
        );

        if (newAvatarUrl != null) {
          updates['avatar_url'] = newAvatarUrl;
        }
      }

      if (updates.isEmpty) {
        return await fetchProfile(userId);
      }

      final response = await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      print('Profile updated successfully for user: $userId');
      return Profile.fromMap(response);

    } on PostgrestException catch (e) {
      print('Update profile error: ${e.message}');
      Get.snackbar("Update Failed", e.message ?? 'Could not update profile');
      return null;
    } catch (e) {
      print('Unexpected update error: $e');
      return null;
    }
  }

  /// Fetch profile by user ID
  Future<Profile?> fetchProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();  // Use maybeSingle instead of single to avoid errors

      if (response == null) {
        print('No profile found for user: $userId');
        return null;
      }

      return Profile.fromMap(response);

    } on PostgrestException catch (e) {
      print('Fetch profile error: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected fetch error: $e');
      return null;
    }
  }

  /// Update online status
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await _supabase
          .from('profiles')
          .update({
        'is_online': isOnline,
        'last_seen': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  /// Search profiles by username
  Future<List<Profile>> searchProfiles(String query) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .ilike('username', '%$query%')
          .limit(20);

      return (response as List)
          .map((json) => Profile.fromMap(json))
          .toList();

    } catch (e) {
      print('Search profiles error: $e');
      return [];
    }
  }
}