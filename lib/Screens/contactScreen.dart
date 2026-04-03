import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/network_avatar.dart';
import '../controllers/chatController.dart';
import '../controllers/contactController.dart';
import '../models/profile_model.dart';
import 'messageScreen.dart'; // Import the chat detail screen

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactsController contactsController = Get.find<ContactsController>();
  final ChatController chatController = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();
    contactsController.loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Contacts'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => contactsController.refreshContacts(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                onChanged: (value) => contactsController.searchContacts(value),
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.teal),
                ),
              ),
            ),
          ),

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
                      Icon(Icons.people_outline, size: 80.sp, color: Colors.grey[300]),
                      SizedBox(height: 16.h),
                      Text(
                        'No contacts found',
                        style: TextStyle(fontSize: 18.sp, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
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
    );
  }

  Widget _buildContactTile(Profile contact) {
    return InkWell(
      onTap: () async {
        // Show loading indicator
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
                  Text('Starting conversation...'),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );

        try {
          // Create or get existing conversation
          final conversationId = await chatController.startConversation(contact);

          Get.back(); // Close loading dialog

          if (conversationId != null) {
            // Navigate to chat detail screen
            Get.to(
                  () => ChatDetailScreen(conversation: conversationId),
              transition: Transition.rightToLeft,
              duration: Duration(milliseconds: 300),
            );
          } else {
            Get.snackbar(
              'Error',
              'Failed to start conversation',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          Get.back(); // Close loading dialog
          Get.snackbar(
            'Error',
            'Failed to start conversation: $e',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.username,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    contact.email!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chat_bubble_outline, color: Colors.teal, size: 20.sp),
          ],
        ),
      ),
    );
  }
}