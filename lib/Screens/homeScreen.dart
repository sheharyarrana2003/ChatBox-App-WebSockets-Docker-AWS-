import 'package:chatbox_app/Screens/contactScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../controllers/authController.dart';
import '../controllers/chatController.dart';
import '../models/conversationModel_.dart';
import '../widgets/network_avatar.dart';
import 'messageScreen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ChatController chatController = Get.find<ChatController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (chatController.isLoadingConversations.value &&
            chatController.conversations.isEmpty) {
          return Center(child: CircularProgressIndicator(color: Colors.teal));
        }

        if (chatController.conversations.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => chatController.loadConversations(),
          color: Colors.teal,
          child: ListView.builder(
            padding: EdgeInsets.all(12.w),
            itemCount: chatController.conversations.length,
            itemBuilder: (context, index) {
              final conversation = chatController.conversations[index];
              return _buildConversationTile(conversation);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => ContactsScreen());
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.message, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text('No conversations yet',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          Text('Tap the + button to start chatting',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildConversationTile(ConversationModel conversation) {
    final otherUser = conversation.otherUser;
    final hasUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: () {
        chatController.currentConversationId = conversation.id;
        chatController.loadMessages(conversation.id);
        Get.to(() => ChatDetailScreen(conversation: conversation));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                NetworkAvatar(
                  url: otherUser.avatarUrl,
                  radius: 28.r,
                  name: otherUser.username,
                ),
                if (otherUser.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12.w,
                      height: 12.w,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherUser.username,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (conversation.lastMessage != null)
                        Text(
                          _formatTimestamp(conversation.lastMessage!.timestamp),
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          final isTyping = chatController
                              .typingUsers[conversation.id]
                              ?.contains(otherUser.id) ?? false;

                          if (isTyping) {
                            return Row(
                              children: [
                                SizedBox(width: 16.w, height: 16.w,
                                    child: CircularProgressIndicator(strokeWidth: 2)),
                                SizedBox(width: 4.w),
                                Text('Typing...', style: TextStyle(color: Colors.teal)),
                              ],
                            );
                          }

                          return Text(
                            conversation.lastMessage?.content ?? 'No messages yet',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: hasUnread ? Colors.black87 : Colors.grey[600],
                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ),
                      if (hasUnread)
                        Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: TextStyle(color: Colors.white, fontSize: 10.sp),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    // Less than 1 minute ago
    if (difference.inMinutes < 1) {
      return 'now';
    }

    // Less than 1 hour ago
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }

    // Less than 24 hours ago
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }

    // Less than 7 days ago
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    // Show date for older messages
    return DateFormat('dd/MM/yy').format(timestamp);
  }
}