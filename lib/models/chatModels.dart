class ChatModel {
  final String id;
  final String userName;
  final String lastMessage;
  final String timestamp;
  final String profileImageUrl;
  final int unreadCount;
  final bool isOnline;
  final DateTime lastSeen;

  ChatModel({
    required this.id,
    required this.userName,
    required this.lastMessage,
    required this.timestamp,
    required this.profileImageUrl,
    this.unreadCount = 0,
    this.isOnline = false,
    required this.lastSeen,
  });

  // Factory constructor for creating ChatModel from JSON (for Supabase)
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      userName: json['user_name'] ?? '',
      lastMessage: json['last_message'] ?? '',
      timestamp: json['timestamp'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
      isOnline: json['is_online'] ?? false,
      lastSeen: DateTime.parse(json['last_seen'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert ChatModel to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'last_message': lastMessage,
      'timestamp': timestamp,
      'profile_image_url': profileImageUrl,
      'unread_count': unreadCount,
      'is_online': isOnline,
      'last_seen': lastSeen.toIso8601String(),
    };
  }

  // Copy with method for updating specific fields
  ChatModel copyWith({
    String? id,
    String? userName,
    String? lastMessage,
    String? timestamp,
    String? profileImageUrl,
    int? unreadCount,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return ChatModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}