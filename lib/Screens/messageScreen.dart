import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/authController.dart';
import '../controllers/chatController.dart';
import '../models/conversationModel_.dart';
import '../models/profile_model.dart';
import '../widgets/messageBubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final dynamic conversation; // Can be ConversationModel or String ID

  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatController chatController = Get.find<ChatController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  Timer? _typingTimer;
  bool _isTyping = false;

  // Local state for conversation
  late ConversationModel _conversation;
  bool _isLoadingConversation = true;

  @override
  void initState() {
    super.initState();
    _initializeConversation();
    _scrollToBottom();

    // Listen for new messages
    ever(chatController.currentMessages, (_) => _scrollToBottom());
    messageController.addListener(_onTextChanged);

    // Add listener to scroll when keyboard appears
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _scrollToBottom();
      }
    });
  }

  Future<void> _initializeConversation() async {
    try {
      if (widget.conversation is ConversationModel) {
        _conversation = widget.conversation;
        _isLoadingConversation = false;
        chatController.currentConversationId = _conversation.id;
        await chatController.loadMessages(_conversation.id);
        if (mounted) setState(() {});
      } else if (widget.conversation is String) {
        final conversationId = widget.conversation as String;
        print('📱 Loading conversation with ID: $conversationId');
        chatController.currentConversationId = conversationId;
        await chatController.loadMessages(conversationId);
        final conv = await chatController.getConversationById(conversationId);
        if (conv != null) {
          _conversation = conv;
        } else {
          _conversation = ConversationModel(
            id: conversationId,
            otherUser: Profile(
              id: 'temp',
              email: 'user@example.com',
              username: 'User',
              avatarUrl: null,
              isOnline: false,
              lastSeen: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            lastMessage: null,
            unreadCount: 0,
            updatedAt: DateTime.now(),
          );
        }
        _isLoadingConversation = false;
        if (mounted) setState(() {});
      } else {
        throw Exception('Invalid conversation type');
      }
    } catch (e) {
      print('❌ Error initializing conversation: $e');
      _conversation = ConversationModel(
        id: 'error',
        otherUser: Profile(
          id: 'error',
          email: 'error@example.com',
          username: 'Error Loading',
          avatarUrl: null,
          isOnline: false,
          lastSeen: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        lastMessage: null,
        unreadCount: 0,
        updatedAt: DateTime.now(),
      );
      _isLoadingConversation = false;
      if (mounted) setState(() {});
      Get.snackbar('Error', 'Failed to load conversation details',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _onTextChanged() {
    if (messageController.text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      chatController.sendTypingIndicator(true);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_isTyping) {
        _isTyping = false;
        chatController.sendTypingIndicator(false);
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients && scrollController.position.maxScrollExtent > 0) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    print("Message: ${messageController.text}");
    if (messageController.text.trim().isEmpty) return;
    final text = messageController.text;
    messageController.clear();
    await chatController.sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingConversation) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.teal, title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    final otherUser = _getOtherUser();
    final currentUser = authController.savedProfile.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: otherUser.avatarUrl != null
                      ? NetworkImage(otherUser.avatarUrl!)
                      : null,
                  child: otherUser.avatarUrl == null
                      ? Text(
                    otherUser.username.isNotEmpty
                        ? otherUser.username[0].toUpperCase()
                        : '?',
                    style: TextStyle(color: Colors.teal),
                  )
                      : null,
                ),
                if (otherUser.isOnline)
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
                    otherUser.username,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  Obx(() {
                    final isTyping = chatController
                        .typingUsers[_conversation.id]
                        ?.contains(otherUser.id) ?? false;
                    return Text(
                      isTyping ? 'Typing...' : (otherUser.isOnline ? 'Online' : 'Offline'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isTyping
                            ? Colors.white70
                            : (otherUser.isOnline ? Colors.greenAccent : Colors.white70),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.phone, color: Colors.white),
            onPressed: () => Get.snackbar('Coming Soon', 'Voice calls coming soon!'),
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: Colors.white),
            onPressed: () => Get.snackbar('Coming Soon', 'Video calls coming soon!'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List - Expanded takes remaining space
          Expanded(
            child: Obx(() {
              if (chatController.isLoadingMessages.value) {
                return Center(child: CircularProgressIndicator(color: Colors.teal));
              }
              if (chatController.currentMessages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 60.sp, color: Colors.grey[300]),
                      SizedBox(height: 16.h),
                      Text('No messages yet', style: TextStyle(fontSize: 16.sp, color: Colors.grey[500])),
                      SizedBox(height: 8.h),
                      Text('Send a message to start chatting', style: TextStyle(fontSize: 14.sp, color: Colors.grey[400])),
                    ],
                  ),
                );
              }
              return ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                itemCount: chatController.currentMessages.length,
                reverse: false,
                itemBuilder: (context, index) {
                  final message = chatController.currentMessages[index];
                  final isMe = message.sender.id == currentUser?.id;
                  return MessageBubble(
                    message: message,
                    isMe: isMe,
                    onRead: !isMe ? () => chatController.markMessageAsRead(message.id) : null,
                  );
                },
              );
            }),
          ),

          // Typing indicator - Shows above message input
          Obx(() {
            final typingUsers = chatController.typingUsers[_conversation.id] ?? {};
            if (typingUsers.isNotEmpty) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${otherUser.username} is typing...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12.sp, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          }),

          // Message Input - Fixed at bottom
          _buildMessageInput(),
        ],
      ),
    );
  }

  Profile _getOtherUser() {
    try {
      return _conversation.otherUser;
    } catch (e) {
      return Profile(
        id: 'unknown',
        email: 'unknown@email.com',
        username: 'Unknown User',
        avatarUrl: null,
        isOnline: false,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment button
            IconButton(
              icon: Icon(Icons.attach_file, color: Colors.teal, size: 24.sp),
              onPressed: () => Get.snackbar('Coming Soon', 'File sharing coming soon!',
                  snackPosition: SnackPosition.BOTTOM),
            ),
            // Text field
            Expanded(
              child: TextField(
                controller: messageController,
                focusNode: focusNode,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: 8.w),
            // Send button
            Obx(() {
              return chatController.isSendingMessage.value
                  ? Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withOpacity(0.1),
                ),
                child: Center(
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal),
                  ),
                ),
              )
                  : FloatingActionButton(
                onPressed: _sendMessage,
                mini: true,
                backgroundColor: Colors.teal,
                child: Icon(Icons.send, size: 18.sp),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    messageController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }
}