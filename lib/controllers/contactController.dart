import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Services/contact_service.dart';
import '../models/profile_model.dart';
import 'authController.dart';

class ContactsController extends GetxController {
  final ContactsService _contactsService = Get.find<ContactsService>();
  final AuthController _authController = Get.find<AuthController>();

  var contacts = <Profile>[].obs;
  var filteredContacts = <Profile>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

// Load all contacts except current user
  Future<void> loadContacts() async {
    try {
      isLoading.value = true;
      final currentUserId = _authController.user.value?.id;

      print('🔍 Current User ID: $currentUserId');

      if (currentUserId == null) {
        print('❌ No current user found');
        return;
      }

      final allContacts = await _contactsService.getAllUsers();

      print('📊 Total profiles in database: ${allContacts.length}');

      // Print all users for debugging
      for (var user in allContacts) {
        print('   - User: ${user.username}, ID: ${user.id}, Email: ${user.email}');
      }

      // Filter out current user
      contacts.value = allContacts.where((user) {
        final isNotCurrentUser = user.id != currentUserId;
        if (!isNotCurrentUser) {
          print('✅ Filtered out current user: ${user.username}');
        }
        return isNotCurrentUser;
      }).toList();

      filteredContacts.value = contacts;
      print('📱 Final contacts count: ${contacts.length}');

    } catch (e) {
      print('❌ Error loading contacts: $e');
    } finally {
      isLoading.value = false;
    }
  }
  // Search contacts
  void searchContacts(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredContacts.value = contacts;
      return;
    }

    filteredContacts.value = contacts.value.where((contact) {
      return contact.username.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Refresh contacts
  Future<void> refreshContacts() async {
    await loadContacts();
  }
}