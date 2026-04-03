import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversationModel_.dart';
import '../models/messageModel_.dart';
import '../models/profile_model.dart';

class ChatService extends GetxService {
  final SupabaseClient _supabase = Get.find<SupabaseClient>();

  /// Create or get conversation between two users
  Future<String?> getOrCreateConversation(String userId1, String userId2) async {
    try {
      print('🔍 Finding conversation between $userId1 and $userId2');

      final response = await _supabase
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', userId1);

      if (response.isNotEmpty) {
        final convIds = response.map<String>((e) => e['conversation_id'] as String).toList();

        for (var convId in convIds) {
          final checkUser2 = await _supabase
              .from('conversation_participants')
              .select('user_id')
              .eq('conversation_id', convId)
              .eq('user_id', userId2)
              .maybeSingle();

          if (checkUser2 != null) {
            print('✅ Found existing conversation: $convId');
            return convId;
          }
        }
      }

      print('📝 Creating new conversation...');
      final newConv = await _supabase
          .from('conversations')
          .insert({})
          .select()
          .single();

      final newConvId = newConv['id'] as String;
      print('✅ New conversation created: $newConvId');

      await _supabase.from('conversation_participants').insert([
        {'conversation_id': newConvId, 'user_id': userId1},
        {'conversation_id': newConvId, 'user_id': userId2},
      ]);

      print('✅ Participants added successfully');
      return newConvId;

    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      return null;
    } catch (e) {
      print('❌ Unexpected error: $e');
      return null;
    }
  }

  /// Get conversation by ID
  Future<ConversationModel?> getConversationById(String conversationId, String currentUserId) async {
    try {
      print('🔍 Getting conversation by ID: $conversationId');

      final participants = await _supabase
          .from('conversation_participants')
          .select('''
          user_id,
          profiles!inner (*)
        ''')
          .eq('conversation_id', conversationId);

      if (participants.isEmpty) {
        print('⚠️ No participants found');
        return null;
      }

      Profile? otherUser;
      for (var p in participants) {
        if (p['user_id'] != currentUserId) {
          otherUser = Profile.fromMap(p['profiles']);
          break;
        }
      }

      if (otherUser == null) return null;

      final lastMessageData = await _supabase
          .from('messages')
          .select('''
          *,
          sender:profiles!sender_id (*)
        ''')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      MessageModel? lastMessage;
      if (lastMessageData != null) {
        final senderProfile = Profile.fromMap(lastMessageData['sender']);
        lastMessage = MessageModel.fromJson(lastMessageData, senderProfile);
      }

      return ConversationModel(
        id: conversationId,
        otherUser: otherUser,
        lastMessage: lastMessage,
        unreadCount: 0,
        updatedAt: lastMessage?.timestamp ?? DateTime.now(),
      );

    } catch (e) {
      print('❌ Error getting conversation by ID: $e');
      return null;
    }
  }

  /// Get all conversations for current user
  Future<List<ConversationModel>> getConversations(String userId) async {
    try {
      final participantData = await _supabase
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', userId);

      if (participantData.isEmpty) return [];

      final conversationIds = participantData
          .map<String>((e) => e['conversation_id'] as String)
          .toList();

      final conversations = <ConversationModel>[];

      for (var convId in conversationIds) {
        try {
          final otherParticipantData = await _supabase
              .from('conversation_participants')
              .select('user_id')
              .eq('conversation_id', convId)
              .neq('user_id', userId)
              .maybeSingle();

          if (otherParticipantData == null) continue;

          final otherUserId = otherParticipantData['user_id'];

          final userData = await _supabase
              .from('profiles')
              .select()
              .eq('id', otherUserId)
              .single();

          final otherUser = Profile.fromMap(userData);

          final lastMessageData = await _supabase
              .from('messages')
              .select('''
                *,
                sender:profiles!sender_id(*)
              ''')
              .eq('conversation_id', convId)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          MessageModel? lastMessage;
          if (lastMessageData != null) {
            final senderProfile = Profile.fromMap(lastMessageData['sender']);
            lastMessage = MessageModel.fromJson(lastMessageData, senderProfile);
          }

          conversations.add(ConversationModel(
            id: convId,
            otherUser: otherUser,
            lastMessage: lastMessage,
            unreadCount: 0,
            updatedAt: lastMessage?.timestamp ?? DateTime.now(),
          ));

        } catch (e) {
          print('Error processing conversation $convId: $e');
          continue;
        }
      }

      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return conversations;
    } catch (e) {
      print('Error getting conversations: $e');
      return [];
    }
  }

  /// Get messages for a conversation with full status - OPTIMIZED
  Future<List<MessageModel>> getMessages(String conversationId, String userId) async {
    try {
      // Get all messages in one query
      final data = await _supabase
          .from('messages')
          .select('''
          *,
          sender:profiles!sender_id(*),
          status:message_status!message_id(*)
        ''')
          .eq('conversation_id', conversationId)
          .eq('status.user_id', userId)  // Filter status for this user
          .order('created_at', ascending: true);

      final messages = <MessageModel>[];

      for (var msg in data) {
        try {
          final senderProfile = Profile.fromMap(msg['sender']);

          // Extract status from joined data
          DateTime? deliveredAt;
          DateTime? readAt;

          if (msg['status'] != null && msg['status'] is List) {
            for (var status in msg['status']) {
              if (status['status'] == 'delivered') {
                deliveredAt = DateTime.parse(status['updated_at']);
              } else if (status['status'] == 'read') {
                readAt = DateTime.parse(status['updated_at']);
              }
            }
          }

          messages.add(MessageModel.fromJson({
            'id': msg['id'],
            'conversation_id': msg['conversation_id'],
            'content': msg['content'],
            'type': msg['type'],
            'timestamp': msg['created_at'],
            'delivered_at': deliveredAt?.toIso8601String(),
            'read_at': readAt?.toIso8601String(),
            'file_url': msg['file_url'],
            'file_name': msg['file_name'],
            'file_size': msg['file_size'],
          }, senderProfile));

        } catch (e) {
          print('Error processing message: $e');
          continue;
        }
      }

      return messages;
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  /// Send message with proper timestamp
  Future<MessageModel?> sendMessage({
    required String conversationId,
    required Profile sender,
    required String content,
    MessageType type = MessageType.text,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) async {
    try {
      print("📤 Sending message...");
      print("   Sender: ${sender.username}");
      print("   Conversation ID: $conversationId");
      print("   Content: $content");

      final now = DateTime.now().toUtc().toIso8601String();

      final data = await _supabase
          .from('messages')
          .insert({
        'conversation_id': conversationId,
        'sender_id': sender.id,
        'content': content,
        'type': type.toString().split('.').last,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_size': fileSize,
        'created_at': now,
      })
          .select('''
            *,
            sender:profiles!sender_id(*)
          ''')
          .single();

      print("✅ Message inserted with ID: ${data['id']}");

      // Update conversation updated_at
      await _supabase
          .from('conversations')
          .update({'updated_at': now})
          .eq('id', conversationId);

      final senderProfile = Profile.fromMap(data['sender']);
      final message = MessageModel.fromJson(data, senderProfile);

      // Mark as delivered for the sender immediately
      await markAsDelivered(message.id, sender.id);

      return message;
    } catch (e) {
      print('❌ Error sending message: $e');
      return null;
    }
  }

  /// Mark message as delivered for a specific user
  Future<void> markAsDelivered(String messageId, String userId) async {
    try {
      await _supabase
          .from('message_status')
          .upsert({
        'message_id': messageId,
        'user_id': userId,
        'status': 'delivered',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      print('✅ Message $messageId marked as delivered for user $userId');
    } catch (e) {
      print('Error marking as delivered: $e');
    }
  }

  /// Mark message as read for a specific user
  Future<void> markAsRead(String messageId, String userId) async {
    try {
      await _supabase
          .from('message_status')
          .upsert({
        'message_id': messageId,
        'user_id': userId,
        'status': 'read',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      print('✅ Message $messageId marked as read for user $userId');
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  /// Alternative method without complex queries
  Future<String?> getOrCreateConversationSimple(String userId1, String userId2) async {
    try {
      print('🔍 Finding or creating conversation between $userId1 and $userId2');

      final response = await _supabase
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', userId1);

      if (response.isNotEmpty) {
        final convIds = response.map<String>((e) => e['conversation_id'] as String).toList();

        for (var convId in convIds) {
          final checkUser2 = await _supabase
              .from('conversation_participants')
              .select()
              .eq('conversation_id', convId)
              .eq('user_id', userId2)
              .maybeSingle();

          if (checkUser2 != null) {
            print('✅ Found existing conversation: $convId');
            return convId;
          }
        }
      }

      print('📝 No existing conversation found, creating new one...');

      final newConv = await _supabase
          .from('conversations')
          .insert({})
          .select()
          .single();

      final newConvId = newConv['id'] as String;
      print('✅ New conversation created with ID: $newConvId');

      await _supabase.from('conversation_participants').insert([
        {'conversation_id': newConvId, 'user_id': userId1},
        {'conversation_id': newConvId, 'user_id': userId2},
      ]);

      print('✅ New conversation created successfully: $newConvId');
      return newConvId;

    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      Get.snackbar('Error', 'Could not create conversation. Please try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    } catch (e) {
      print('❌ Unexpected error: $e');
      Get.snackbar('Error', 'Something went wrong',
          backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
  }
}