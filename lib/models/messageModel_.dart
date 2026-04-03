import 'profile_model.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final Profile sender;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final bool isDeleted;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.type,
    required this.timestamp,
    this.deliveredAt,
    this.readAt,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.isDeleted = false,
  });

  // From JSON - Convert UTC to Local
  factory MessageModel.fromJson(Map<String, dynamic> json, Profile sender) {
    // Parse UTC time and convert to local
    DateTime parseAndLocalize(String? dateTimeStr) {
      if (dateTimeStr == null) return DateTime.now();
      // Parse as UTC then convert to local
      return DateTime.parse(dateTimeStr).toLocal();
    }

    return MessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversation_id'] ?? json['roomId'] ?? '',
      sender: sender,
      content: json['content'] ?? json['message'] ?? '',
      type: _parseMessageType(json['type'] ?? 'text'),
      timestamp: parseAndLocalize(json['timestamp']),
      deliveredAt: json['delivered_at'] != null
          ? parseAndLocalize(json['delivered_at'])
          : null,
      readAt: json['read_at'] != null
          ? parseAndLocalize(json['read_at'])
          : null,
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      isDeleted: json['is_deleted'] ?? false,
    );
  }

  // To JSON for Supabase - Convert Local to UTC
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': sender.id,
      'content': content,
      'type': type.toString().split('.').last,
      'created_at': timestamp.toUtc().toIso8601String(), // Convert to UTC
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
    };
  }

  // Helper to get formatted time with AM/PM
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    // If today, show time with AM/PM
    if (timestamp.day == now.day &&
        timestamp.month == now.month &&
        timestamp.year == now.year) {
      return _formatTimeOfDay(timestamp);
    }

    // If yesterday
    if (timestamp.day == now.day - 1 &&
        timestamp.month == now.month &&
        timestamp.year == now.year) {
      return 'Yesterday ${_formatTimeOfDay(timestamp)}';
    }

    // Show date and time
    return '${timestamp.day}/${timestamp.month} ${_formatTimeOfDay(timestamp)}';
  }

  String _formatTimeOfDay(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String amPm = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $amPm';
  }

  static MessageType _parseMessageType(String type) {
    switch (type) {
      case 'image': return MessageType.image;
      case 'video': return MessageType.video;
      case 'audio': return MessageType.audio;
      case 'file': return MessageType.file;
      default: return MessageType.text;
    }
  }
}

enum MessageType { text, image, video, audio, file }