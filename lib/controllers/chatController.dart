import 'package:get/get.dart';
import '../models/chatModels.dart';

class ChatController extends GetxController {
  var chatList = <ChatModel>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDummyChats();
  }

  List<ChatModel> get filteredChats {
    if (searchQuery.isEmpty) {
      return chatList;
    }
    return chatList.where((chat) =>
    chat.userName.toLowerCase().contains(searchQuery.toLowerCase()) ||
        chat.lastMessage.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  // Search functionality
  void searchChats(String query) {
    searchQuery.value = query;
  }

  // Load dummy data (replace with Supabase later)
  void loadDummyChats() {
    chatList.value = List.generate(15, (index) {
      return ChatModel(
        id: 'chat_$index',
        userName: _generateUserName(index),
        lastMessage: _generateLastMessage(index),
        timestamp: _generateTimestamp(index),
        profileImageUrl: "https://randomuser.me/api/portraits/${index % 2 == 0 ? 'women' : 'men'}/${20 + index}.jpg",
        unreadCount: index % 4 == 0 ? 0 : (index % 3) + 1,
        isOnline: index % 3 == 0,
        lastSeen: DateTime.now().subtract(Duration(minutes: index * 5)),
      );
    });
  }

  // Future method for Supabase integration
  Future<void> loadChatsFromSupabase() async {
    try {
      isLoading.value = true;
      // TODO: Implement Supabase query
      // final response = await supabaseClient.from('chats').select();
      // chatList.value = response.map((json) => ChatModel.fromJson(json)).toList();

      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      loadDummyChats(); // Remove this when implementing Supabase
    } catch (e) {
      Get.snackbar('Error', 'Failed to load chats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update unread count (for real-time updates)
  void updateUnreadCount(String chatId, int count) {
    final chatIndex = chatList.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      chatList[chatIndex] = chatList[chatIndex].copyWith(unreadCount: count);
    }
  }

  // Mark chat as read
  void markAsRead(String chatId) {
    updateUnreadCount(chatId, 0);
  }

  // Update last message (for real-time updates)
  void updateLastMessage(String chatId, String message, String timestamp) {
    final chatIndex = chatList.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      chatList[chatIndex] = chatList[chatIndex].copyWith(
        lastMessage: message,
        timestamp: timestamp,
      );
      // Move to top
      final updatedChat = chatList.removeAt(chatIndex);
      chatList.insert(0, updatedChat);
    }
  }

  // Helper methods for dummy data
  String _generateUserName(int index) {
    final names = [
      'Alice Johnson', 'Bob Smith', 'Carol Davis', 'David Wilson',
      'Emma Brown', 'Frank Miller', 'Grace Taylor', 'Henry Clark',
      'Ivy Martinez', 'Jack Anderson', 'Kate Thompson', 'Liam Garcia',
      'Maya Rodriguez', 'Noah Lewis', 'Olivia Walker'
    ];
    return names[index % names.length];
  }

  String _generateLastMessage(int index) {
    final messages = [
      'Hey! How are you doing?', 'Thanks for your help today!',
      'See you tomorrow at the meeting', 'Can you send me the file?',
      'Great work on the project!', 'Let\'s grab coffee sometime',
      'Happy birthday! 🎉', 'Did you see the news?',
      'I\'ll call you later', 'Perfect timing!',
      'Check out this link', 'Sounds good to me',
      'Take care!', 'Looking forward to it', 'Nice job! 👏'
    ];
    return messages[index % messages.length];
  }

  String _generateTimestamp(int index) {
    final now = DateTime.now();
    if (index < 3) return 'now';
    if (index < 6) return '${index + 1} min ago';
    if (index < 10) return '${index - 5} hr ago';
    return '${index - 9} days ago';
  }
}