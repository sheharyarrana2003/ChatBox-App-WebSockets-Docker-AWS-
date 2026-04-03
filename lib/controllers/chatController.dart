import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Services/chat_service.dart';
import '../Services/contact_service.dart';
import '../Services/socket_service.dart';
import '../models/conversationModel_.dart';
import '../models/messageModel_.dart';
import '../models/profile_model.dart';
import 'authController.dart';

class ChatController extends GetxController {
  final ChatService _chatService = Get.find<ChatService>();
  final SocketService _socketService = Get.find<SocketService>();
  final ContactsService _contactsService = Get.find<ContactsService>();
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseClient _supabase = Get.find<SupabaseClient>();

  // Observable state
  var conversations = <ConversationModel>[].obs;
  var currentMessages = <MessageModel>[].obs;
  var isLoadingConversations = false.obs;
  var isLoadingMessages = false.obs;
  var isSendingMessage = false.obs;
  var typingUsers = <String, Set<String>>{}.obs;

  String? currentConversationId;
  Profile? currentUser;

  @override
  void onInit() {
    super.onInit();
    ever(_authController.savedProfile, (profile){
      if(profile!=null){
        currentUser=profile;
        loadConversations();
      }
    });

    if(_authController.savedProfile.value!=null){
      currentUser=_authController.savedProfile.value;
      loadConversations();
    }
  }

  // Load all conversations
  Future<void> loadConversations() async {
    if (currentUser == null) return;

    isLoadingConversations.value = true;
    try {
      final convos = await _chatService.getConversations(currentUser!.id);
      conversations.value = convos;

      for (var conv in convos) {
        _socketService.joinRoom(conv.id);
      }

      print('✅ Loaded ${convos.length} conversations');
    } catch (e) {
      print('❌ Error loading conversations: $e');
    } finally {
      isLoadingConversations.value = false;
    }
  }

  Future<String?> createOrGetConversation(String userId1, String userId2) async {
    try {
      return await _chatService.getOrCreateConversationSimple(userId1, userId2);
    } catch (e) {
      print('❌ Error creating conversation: $e');
      return null;
    }
  }

  Future<ConversationModel?> getConversationById(String conversationId) async {
    try {
      final currentUserId = _authController.user.value?.id;
      if (currentUserId == null) return null;

      final conversation = await _chatService.getConversationById(conversationId, currentUserId);

      if (conversation != null) {
        final exists = conversations.any((c) => c.id == conversationId);
        if (!exists) {
          conversations.add(conversation);
        }
        return conversation;
      }

      return await _createMinimalConversation(conversationId);

    } catch (e) {
      print('❌ Error in getConversationById: $e');
      return null;
    }
  }

  Future<ConversationModel?> _createMinimalConversation(String conversationId) async {
    try {
      final currentUserId = _authController.user.value?.id;
      if (currentUserId == null) return null;

      final participants = await _supabase
          .from('conversation_participants')
          .select('user_id')
          .eq('conversation_id', conversationId);

      if (participants.isEmpty) return null;

      final otherUserId = participants.firstWhere(
            (p) => p['user_id'] != currentUserId,
      )['user_id'];

      if (otherUserId == null) return null;

      final userData = await _supabase
          .from('profiles')
          .select()
          .eq('id', otherUserId)
          .single();

      final otherUser = Profile.fromMap(userData);

      return ConversationModel(
        id: conversationId,
        otherUser: otherUser,
        lastMessage: null,
        unreadCount: 0,
        updatedAt: DateTime.now(),
      );

    } catch (e) {
      print('❌ Error creating minimal conversation: $e');
      return null;
    }
  }

  // Load messages for a conversation
  Future<void> loadMessages(String conversationId) async {
    if (currentUser == null) return;

    isLoadingMessages.value = true;
    currentConversationId = conversationId;

    try {
      final msgs = await _chatService.getMessages(conversationId, currentUser!.id);
      currentMessages.value = msgs;

      _socketService.joinRoom(conversationId);
      await _markMessagesAsDelivered(msgs);

      print('✅ Loaded ${msgs.length} messages');
    } catch (e) {
      print('❌ Error loading messages: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  void handleMessageDelivered(Map<String, dynamic> data) {
    print('✅ Message delivered: ${data['messageId']}');

    final messageId = data['messageId'];
    final index = currentMessages.indexWhere((m) => m.id == messageId);

    if (index != -1) {
      final message = currentMessages[index];
      currentMessages[index] = MessageModel(
        id: message.id,
        conversationId: message.conversationId,
        sender: message.sender,
        content: message.content,
        type: message.type,
        timestamp: message.timestamp,
        deliveredAt: DateTime.now(),
        readAt: message.readAt,
        fileUrl: message.fileUrl,
        fileName: message.fileName,
        fileSize: message.fileSize,
      );
      currentMessages.refresh();
    }
  }

  void handleMessageRead(Map<String, dynamic> data) {
    print('👁️ Message read receipt received: ${data['messageId']}');

    final messageId = data['messageId'];
    final index = currentMessages.indexWhere((m) => m.id == messageId);

    if (index != -1) {
      final message = currentMessages[index];
      currentMessages[index] = MessageModel(
        id: message.id,
        conversationId: message.conversationId,
        sender: message.sender,
        content: message.content,
        type: message.type,
        timestamp: message.timestamp,
        deliveredAt: message.deliveredAt ?? DateTime.now(),
        readAt: DateTime.now(),
        fileUrl: message.fileUrl,
        fileName: message.fileName,
        fileSize: message.fileSize,
      );
      currentMessages.refresh();
    }
  }

  // Send a message
  Future<void> sendMessage(String content, {
    MessageType type = MessageType.text,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) async {
    if (currentConversationId == null || currentUser == null) return;
    if (content.trim().isEmpty && fileUrl == null) return;

    isSendingMessage.value = true;

    try {
      final message = await _chatService.sendMessage(
        conversationId: currentConversationId!,
        sender: currentUser!,
        content: content,
        type: type,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
      );

      if (message != null) {
        currentMessages.add(message);
        _socketService.sendMessage(currentConversationId!, content);
        await _updateConversationWithMessage(message);
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message');
    } finally {
      isSendingMessage.value = false;
    }
  }

  // Handle incoming message from socket
  void handleIncomingMessage(Map<String, dynamic> data) async {
    print('📨 Handling incoming message from ${data['senderId']}');

    final sender = await _contactsService.getUserById(data['senderId']);
    if (sender == null) return;

    final message = MessageModel.fromJson({
      'id': data['id'],
      'conversation_id': data['roomId'],
      'content': data['content'],
      'type': data['type'] ?? 'text',
      'timestamp': data['timestamp'],
    }, sender);

    if (message.conversationId == currentConversationId) {
      currentMessages.add(message);
      await _chatService.markAsDelivered(message.id, currentUser!.id);
    }

    await _updateConversationListWithMessage(message);
  }

  // Handle typing indicator
  void handleTypingIndicator(Map<String, dynamic> data) {
    final roomId = data['roomId'];
    final userId = data['userId'];
    final isTyping = data['isTyping'];

    if (!typingUsers.containsKey(roomId)) {
      typingUsers[roomId] = {};
    }

    if (isTyping) {
      typingUsers[roomId]!.add(userId);
    } else {
      typingUsers[roomId]!.remove(userId);
    }
    typingUsers.refresh();
  }

  // Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    if (currentConversationId == null) return;
    _socketService.sendTyping(currentConversationId!, isTyping);
  }

  // Handle user online status
  void handleUserOnline(Map<String, dynamic> data) {
    final userId = data['userId'];
    _updateUserOnlineStatus(userId, true);
  }

  void handleUserOffline(Map<String, dynamic> data) {
    final userId = data['userId'];
    _updateUserOnlineStatus(userId, false);
  }

  // ✅ FIXED: Mark message as read - this sends read receipt to socket
  Future<void> markMessageAsRead(String messageId) async {
    if (currentUser == null || currentConversationId == null) return;

    print('📖 Marking message as read: $messageId');

    // Update in database
    await _chatService.markAsRead(messageId, currentUser!.id);

    // Send read receipt via socket to notify sender
    _socketService.markMessageRead(currentConversationId!, messageId);

    // Update local message status
    final index = currentMessages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final msg = currentMessages[index];
      currentMessages[index] = MessageModel(
        id: msg.id,
        conversationId: msg.conversationId,
        sender: msg.sender,
        content: msg.content,
        type: msg.type,
        timestamp: msg.timestamp,
        deliveredAt: msg.deliveredAt ?? DateTime.now(),
        readAt: DateTime.now(),
        fileUrl: msg.fileUrl,
        fileName: msg.fileName,
        fileSize: msg.fileSize,
      );
      currentMessages.refresh();
    }
  }

  // Start conversation with a contact
  Future<String?> startConversation(Profile contact) async {
    try {
      final currentUser = _authController.savedProfile.value;
      if (currentUser == null) return null;

      final conversationId = await _chatService.getOrCreateConversationSimple(
        currentUser.id,
        contact.id,
      );

      if (conversationId != null) {
        currentConversationId = conversationId;
        await loadMessages(conversationId);
        return conversationId;
      }
      return null;
    } catch (e) {
      print('❌ Error starting conversation: $e');
      return null;
    }
  }

  // Leave current conversation room
  void leaveCurrentConversation() {
    if (currentConversationId != null) {
      _socketService.leaveRoom(currentConversationId!);
      currentConversationId = null;
    }
  }

  // Private helper methods
  Future<void> _markMessagesAsDelivered(List<MessageModel> messages) async {
    final unreadMessages = messages.where(
            (m) => m.sender.id != currentUser!.id && m.deliveredAt == null
    );

    for (var message in unreadMessages) {
      await _chatService.markAsDelivered(message.id, currentUser!.id);
    }
  }

  Future<void> _updateConversationWithMessage(MessageModel message) async {
    final index = conversations.indexWhere((c) => c.id == message.conversationId);
    if (index != -1) {
      final conv = conversations[index];
      conversations[index] = ConversationModel(
        id: conv.id,
        otherUser: conv.otherUser,
        lastMessage: message,
        unreadCount: message.sender.id != currentUser!.id ? 1 : 0,
        updatedAt: message.timestamp,
        isTyping: false,
      );
      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      conversations.refresh();
    }
  }

  Future<void> _updateConversationListWithMessage(MessageModel message) async {
    final index = conversations.indexWhere((c) => c.id == message.conversationId);
    if (index != -1) {
      final conv = conversations[index];
      conversations[index] = ConversationModel(
        id: conv.id,
        otherUser: conv.otherUser,
        lastMessage: message,
        unreadCount: message.sender.id != currentUser!.id
            ? conv.unreadCount + 1
            : conv.unreadCount,
        updatedAt: message.timestamp,
        isTyping: false,
      );
      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      conversations.refresh();
    } else {
      loadConversations();
    }
  }

  void _updateUserOnlineStatus(String userId, bool isOnline) {
    for (var i = 0; i < conversations.length; i++) {
      if (conversations[i].otherUser.id == userId) {
        final conv = conversations[i];
        final updatedUser = conv.otherUser.copyWith(isOnline: isOnline);

        conversations[i] = ConversationModel(
          id: conv.id,
          otherUser: updatedUser,
          lastMessage: conv.lastMessage,
          unreadCount: conv.unreadCount,
          updatedAt: conv.updatedAt,
          isTyping: conv.isTyping,
          typingUserId: conv.typingUserId,
        );
      }
    }
    conversations.refresh();
  }

  @override
  void onClose() {
    leaveCurrentConversation();
    super.onClose();
  }
}