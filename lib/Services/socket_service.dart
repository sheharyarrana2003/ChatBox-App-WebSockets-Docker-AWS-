import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import 'dart:io';
import 'dart:developer' as developer;
import '../controllers/chatController.dart';
import '../models/profile_model.dart';

class SocketService extends GetxService {
  static SocketService get instance => Get.find<SocketService>();

  // Observable states
  var isConnected = false.obs;
  var connectionError = ''.obs;
  var onlineUsers = <String, bool>{}.obs;

  late IO.Socket socket;
  Profile? currentUser;

  static const String prodSocketUrl = 'https://chat-socket-server-a0gm.onrender.com';
  static const String devSocketUrl = 'http://192.168.56.1:3000';

  String get socketUrl {
    if (kReleaseMode) {
      developer.log('🏭 Using Production server: $prodSocketUrl', name: 'Socket');
      return prodSocketUrl;
    } else {
      if (Platform.isAndroid) {
        developer.log("📱 Android Emulator: Using 10.0.2.2", name: 'Socket');
        return 'http://10.0.2.2:3000';
      } else if (Platform.isIOS) {
        developer.log('🍎 iOS Simulator: Using localhost', name: 'Socket');
        return 'http://localhost:3000';
      } else {
        developer.log('💻 Development: Using local server', name: 'Socket');
        return devSocketUrl;
      }
    }
  }

  Future<void> connect(Profile user) async {
    currentUser = user;

    try {
      developer.log('🔌 Connecting socket for user: ${user.username}', name: 'Socket');
      developer.log('📍 URL: $socketUrl', name: 'Socket');

      socket = IO.io(
          socketUrl,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .enableForceNew()
              .setQuery({'userId': user.id, 'username': user.username})
              .enableReconnection()
              .setReconnectionAttempts(5)
              .setReconnectionDelay(1000)
              .setTimeout(10000)
              .build()
      );

      _setupListeners();
      socket.connect();

      Future.delayed(Duration(seconds: 5), () {
        if (!isConnected.value) {
          developer.log('⚠️ Connection timeout after 5 seconds', name: 'Socket');
          connectionError.value = 'Connection timeout';
        }
      });

    } catch (e) {
      developer.log('❌ Connection error: $e', name: 'Socket');
      connectionError.value = e.toString();
    }
  }

  void _setupListeners() {
    socket.onConnect((_) {
      developer.log('✅ Socket connected! ID: ${socket.id}', name: 'Socket');
      isConnected.value = true;
      connectionError.value = '';
      joinRoom('user_${currentUser!.id}');
      socket.emit('user_online', {
        'userId': currentUser!.id,
        'username': currentUser!.username,
        'avatarUrl': currentUser!.avatarUrl,
      });
    });

    socket.onConnectError((data) {
      developer.log('❌ Connection error: $data', name: 'Socket');
      isConnected.value = false;
      connectionError.value = data.toString();
    });

    socket.onDisconnect((_) {
      developer.log('🔴 Socket disconnected', name: 'Socket');
      isConnected.value = false;
    });

    socket.on('new_message', (data) {
      developer.log('📨 New message: ${data['content']}', name: 'Socket');
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().handleIncomingMessage(data);
      }
    });

    // ✅ Add delivery receipt handler
    socket.on('message_delivered', (data) {
      developer.log('✅ Message delivered: ${data['messageId']}', name: 'Socket');
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().handleMessageDelivered(data);
      }
    });

    // ✅ Add read receipt handler
    socket.on('message_read', (data) {
      developer.log('👁️ Message read: ${data['messageId']}', name: 'Socket');
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().handleMessageRead(data);
      }
    });

    socket.on('user_online', (data) {
      onlineUsers[data['userId']] = true;
      onlineUsers.refresh();
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().handleUserOnline(data);
      }
    });

    socket.on('user_offline', (data) {
      onlineUsers[data['userId']] = false;
      onlineUsers.refresh();
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().handleUserOffline(data);
      }
    });

    socket.on('user_typing', (data) {
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().handleTypingIndicator(data);
      }
    });
  }

  void joinRoom(String roomId) {
    if (!isConnected.value) return;
    socket.emit('join_room', {'roomId': roomId, 'userId': currentUser!.id});
  }

  void leaveRoom(String roomId) {
    if (!isConnected.value) return;
    socket.emit('leave_room', {'roomId': roomId});
  }

  void sendMessage(String roomId, String content, {String messageType = 'text'}) {
    if (!isConnected.value) return;

    socket.emit('send_message', {
      'roomId': roomId,
      'message': content,
      'messageType': messageType,
      'senderId': currentUser!.id,
      'senderName': currentUser!.username,
      'senderAvatar': currentUser!.avatarUrl,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void sendTyping(String roomId, bool isTyping) {
    if (!isConnected.value) return;
    socket.emit('typing', {
      'roomId': roomId,
      'isTyping': isTyping,
      'userId': currentUser!.id,
    });
  }

  void markMessageRead(String roomId, String messageId) {
    if (!isConnected.value) return;
    socket.emit('mark_read', {
      'roomId': roomId,
      'messageId': messageId,
    });
  }

  void disconnect() {
    if (isConnected.value && currentUser != null) {
      socket.emit('user_offline', {'userId': currentUser!.id});
    }
    socket.disconnect();
    socket.close();
    isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}