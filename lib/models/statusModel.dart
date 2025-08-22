class StatusModel {
  final String id;
  final String userName;
  final String profileImageUrl;
  final DateTime timestamp;
  final bool isViewed;
  final bool isMyStatus;
  final int statusCount;
  final String statusType; // 'image', 'video', 'text'

  StatusModel({
    required this.id,
    required this.userName,
    required this.profileImageUrl,
    required this.timestamp,
    this.isViewed = false,
    this.isMyStatus = false,
    this.statusCount = 1,
    this.statusType = 'image',
  });

  // Factory constructor for creating StatusModel from JSON (for Supabase)
  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'] ?? '',
      userName: json['user_name'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isViewed: json['is_viewed'] ?? false,
      isMyStatus: json['is_my_status'] ?? false,
      statusCount: json['status_count'] ?? 1,
      statusType: json['status_type'] ?? 'image',
    );
  }

  // Convert StatusModel to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'profile_image_url': profileImageUrl,
      'timestamp': timestamp.toIso8601String(),
      'is_viewed': isViewed,
      'is_my_status': isMyStatus,
      'status_count': statusCount,
      'status_type': statusType,
    };
  }

  // Copy with method for updating specific fields
  StatusModel copyWith({
    String? id,
    String? userName,
    String? profileImageUrl,
    DateTime? timestamp,
    bool? isViewed,
    bool? isMyStatus,
    int? statusCount,
    String? statusType,
  }) {
    return StatusModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      timestamp: timestamp ?? this.timestamp,
      isViewed: isViewed ?? this.isViewed,
      isMyStatus: isMyStatus ?? this.isMyStatus,
      statusCount: statusCount ?? this.statusCount,
      statusType: statusType ?? this.statusType,
    );
  }

  // Get formatted time
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  // Check if status is recent (within 24 hours)
  bool get isRecent {
    return DateTime.now().difference(timestamp).inHours < 24;
  }
}