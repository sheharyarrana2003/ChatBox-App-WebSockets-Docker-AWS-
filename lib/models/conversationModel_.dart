import 'messageModel_.dart';
import 'profile_model.dart';

class ConversationModel {
  final String id;
  final Profile otherUser;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final bool isTyping;
  final String? typingUserId;

  ConversationModel({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
    this.isTyping = false,
    this.typingUserId,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      otherUser: Profile.fromMap(json['other_user']),
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'], Profile.fromMap(json['last_message_sender']))
          : null,
      unreadCount: json['unread_count'] ?? 0,
      updatedAt: DateTime.parse(json['updated_at']),
      isTyping: json['is_typing'] ?? false,
      typingUserId: json['typing_user_id'],
    );
  }
}