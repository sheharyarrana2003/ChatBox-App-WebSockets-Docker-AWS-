import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ContactsService extends GetxService {
  final SupabaseClient _supabase = Get.find<SupabaseClient>();

  // Get all users from profiles table
  Future<List<Profile>> getAllUsers() async {
    try {
      print('🔍 ContactsService: Fetching all users');

      // Check authentication
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('❌ ContactsService: No authenticated user');
        return [];
      }

      print('✅ ContactsService: Authenticated as ${currentUser.id}');

      final response = await _supabase
          .from('profiles')
          .select()
          .order('username');

      print('📦 ContactsService: Raw response type: ${response.runtimeType}');
      print('📦 ContactsService: Raw response length: ${response.length}');

      if (response.isEmpty) {
        print('⚠️ ContactsService: No profiles found');
        return [];
      }

      final profiles = <Profile>[];
      for (var json in response) {
        try {
          final profile = Profile.fromMap(json);
          profiles.add(profile);
          print('   ✅ Loaded: ${profile.username} (${profile.id})');
        } catch (e) {
          print('   ❌ Error parsing profile: $e');
          print('   JSON: $json');
        }
      }

      print('✅ ContactsService: Successfully loaded ${profiles.length} profiles');
      return profiles;
    } catch (e) {
      print('❌ ContactsService Error: $e');
      return [];
    }
  }

  // Search users by username
  Future<List<Profile>> searchUsers(String query, String currentUserId) async {
    try {
      print('🔍 Searching users for: "$query"');

      final response = await _supabase
          .from('profiles')
          .select()
          .ilike('username', '%$query%')
          .neq('id', currentUserId)
          .limit(20)
          .order('username');

      print('📦 Search found: ${response.length} users');

      return response.map<Profile>((json) => Profile.fromMap(json)).toList();
    } catch (e) {
      print('❌ Search error: $e');
      return [];
    }
  }

  // Get user by ID
  Future<Profile?> getUserById(String userId) async {
    try {
      print('🔍 Getting user by ID: $userId');

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromMap(response);
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }
}