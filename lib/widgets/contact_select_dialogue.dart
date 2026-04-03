import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/authController.dart';
import '../../models/profile_model.dart';
import '../../widgets/network_avatar.dart';
import '../Screens/messageScreen.dart';
import '../controllers/chatController.dart';
import '../controllers/contactController.dart';
import '../models/conversationModel_.dart';

class ContactSelectionDialog extends StatelessWidget {
  ContactSelectionDialog({super.key});

  late final ContactsController contactsController = Get.find<ContactsController>();
  final ChatController chatController = Get.find<ChatController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        height: 600.h,
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Contact',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Search Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                onChanged: (value) => contactsController.searchContacts(value),
                decoration: InputDecoration(
                  hintText: 'Search by name or phone...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.teal),
                  suffixIcon: Obx(() => contactsController.searchQuery.value.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, size: 18.sp),
                    onPressed: () {
                      contactsController.searchContacts('');
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ) : Container()
                      ),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Contacts List
            Expanded(
              child: Obx(() {
                if (contactsController.isLoading.value) {
                  return Center(child: CircularProgressIndicator(color: Colors.teal));
                }

                if (contactsController.filteredContacts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 60.sp,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'No contacts found',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (contactsController.searchQuery.value.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              contactsController.searchContacts('');
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: Text('Clear search'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: contactsController.filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = contactsController.filteredContacts[index];
                    return _buildContactTile(contact);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(Profile contact) {
    return InkWell(
      onTap: () => _startConversation(contact),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                NetworkAvatar(
                  url: contact.avatarUrl,
                  radius: 24.r,
                  name: contact.username,
                ),
                if (contact.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),

            // Contact details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.username,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    contact.email!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Last seen or online status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: contact.isOnline ? Colors.green : Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                contact.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: contact.isOnline ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startConversation(Profile contact) async {
    try {
      final currentUser = authController.savedProfile.value;
      if (currentUser == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      // Close dialog first
      Get.back();

      // Show loading
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.teal),
                SizedBox(height: 16.h),
                Text('Creating conversation...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Create or get conversation
      final conversationId = await chatController.createOrGetConversation(
        currentUser.id,
        contact.id,
      );

      Get.back(); // Close loading dialog

      if (conversationId != null) {
        // Navigate to chat screen
        chatController.currentConversationId = conversationId;
        await chatController.loadMessages(conversationId);

        // Create conversation model for navigation
        final conversation = ConversationModel(
          id: conversationId,
          otherUser: contact,
          lastMessage: null,
          unreadCount: 0,
          updatedAt: DateTime.now(),
        );

        Get.to(() => ChatDetailScreen(conversation: conversation));
      } else {
        Get.snackbar(
          'Error',
          'Failed to create conversation',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error starting conversation: $e');
      Get.back(); // Close loading dialog if open
      Get.snackbar(
        'Error',
        'Failed to start conversation',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}