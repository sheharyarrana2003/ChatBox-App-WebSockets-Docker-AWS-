import 'dart:io';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class SupabaseStorageService extends GetxService {
  final SupabaseClient _supabase = Get.find<SupabaseClient>();
  static const String bucketName = 'avatars';

  @override
  void onInit() {
    super.onInit();
    _initializeBucket();
  }

  Future<void> _initializeBucket() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.name == bucketName);

      if (!bucketExists) {
        await _supabase.storage.createBucket(bucketName,
            BucketOptions(public: true));
        print('Bucket created: $bucketName');
      }
    } catch (e) {
      print('Error initializing bucket: $e');
    }
  }

  // Simple method that just takes a File
  Future<String?> uploadAvatarFromFile({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Get file extension
      final String ext = imageFile.path.split('.').last.toLowerCase();

      // Validate extension
      if (!['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) {
        Get.snackbar("Invalid Format", "Please use JPG, PNG, WEBP or GIF");
        return null;
      }

      final String path = 'avatars/avatar_$userId.$ext';

      // Delete old avatar
      await _deleteOldAvatar(userId);

      // Upload new avatar
      await _supabase.storage
          .from(bucketName)
          .upload(path, imageFile,
          fileOptions: const FileOptions(upsert: true));

      // Get public URL
      final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(path);
      print('Avatar uploaded successfully: $publicUrl');

      return publicUrl;

    } on StorageException catch (e) {
      print('Storage error: ${e.message}');
      Get.snackbar("Upload Failed", e.message ?? "Could not upload image");
      return null;
    } catch (e) {
      print('Unexpected upload error: $e');
      Get.snackbar("Error", "Failed to upload avatar");
      return null;
    }
  }

  // Method for XFile from image_picker
  Future<String?> uploadAvatarFromXFile({
    required String userId,
    required XFile imageXFile,
  }) async {
    return uploadAvatarFromFile(
      userId: userId,
      imageFile: File(imageXFile.path),
    );
  }

  Future<void> _deleteOldAvatar(String userId) async {
    try {
      final files = await _supabase.storage
          .from(bucketName)
          .list(path: 'avatars');

      for (var file in files) {
        if (file.name.startsWith('avatar_$userId')) {
          await _supabase.storage
              .from(bucketName)
              .remove(['avatars/${file.name}']);
          print('Deleted old avatar: ${file.name}');
          break;
        }
      }
    } catch (e) {
      print('Error deleting old avatar: $e');
    }
  }

  Future<void> deleteAvatar(String avatarUrl) async {
    if (avatarUrl.isEmpty) return;

    try {
      final uri = Uri.parse(avatarUrl);
      final path = uri.pathSegments.last;

      await _supabase.storage
          .from(bucketName)
          .remove([path]);

      print('Avatar deleted: $path');
    } catch (e) {
      print('Error deleting avatar: $e');
    }
  }
}