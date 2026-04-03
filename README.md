# 💬 ChatBox - Real-Time Messaging App

A complete real-time chat application built with Flutter, featuring instant messaging, user profiles, and real-time status updates.

## ✨ Features

- **Real-time Messaging** - Instant message delivery using Socket.IO
- **Email Authentication** - Secure sign-up/login with email verification
- **Profile Management** - Custom avatars with image upload
- **Online/Offline Status** - Real-time user presence indicators
- **Typing Indicators** - See when someone is typing
- **Read Receipts** - Message status (Sent ✓ → Delivered ✓✓ → Read ✓✓ blue)
- **Contact Search** - Find users by name or email
- **Conversation List** - View all chats with last message preview
- **Unread Count** - Badge indicator for unread messages

## 🛠️ Tech Stack

- **Flutter** - Frontend framework
- **GetX** - State management & routing
- **Supabase** - Authentication & PostgreSQL database
- **Socket.IO** - Real-time WebSocket communication
- **SharedPreferences** - Local session storage

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/chatbox-app.git

# Install dependencies
flutter pub get

# Run the app
flutter run

# Build APK
flutter build apk --release