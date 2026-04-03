// services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/profile_model.dart';

class LocalStorageService {
  static const String _userIdKey = 'user_id';
  static const String _userEmail = 'user_email';
  static const String _userProfileKey = 'user_profile';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _authTokenKey = 'auth_token';

  // Save user session after successful login
  static Future<void> saveUserSession({
    required String userId,
    required String email,
    Map<String, dynamic>? profileData,
    String? authToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmail, email);
    await prefs.setBool(_isLoggedInKey, true);

    if (authToken != null) {
      await prefs.setString(_authTokenKey, authToken);
    }

    if (profileData != null) {
      await prefs.setString(_userProfileKey, jsonEncode(profileData));
    }

    print('✅ User session saved locally');
  }

  // Save profile data separately
  static Future<void> saveProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile.toMap()));
    print('✅ Profile saved locally');
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get user phone
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmail);
  }

  // Get saved profile
  static Future<Profile?> getSavedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_userProfileKey);

    if (profileJson != null) {
      try {
        final Map<String, dynamic> profileMap = jsonDecode(profileJson);
        return Profile.fromMap(profileMap);
      } catch (e) {
        print('Error parsing saved profile: $e');
        return null;
      }
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get auth token if needed
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Clear all user data on logout
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmail);
    await prefs.remove(_userProfileKey);
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_authTokenKey);

    print('👋 User session cleared');
  }

  // Update specific profile fields
  static Future<void> updateProfileField(String field, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_userProfileKey);

    if (profileJson != null) {
      try {
        Map<String, dynamic> profileMap = jsonDecode(profileJson);
        profileMap[field] = value;
        await prefs.setString(_userProfileKey, jsonEncode(profileMap));
        print('✅ Profile field updated: $field');
      } catch (e) {
        print('Error updating profile field: $e');
      }
    }
  }
}