class Profile {
  final String id; // UUID from auth.users
  final String? email; // Added email field (can be null)
  final String username;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.email, // New field
    required this.username,
    this.avatarUrl,
    this.isOnline = false,
    required this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map (for Supabase insert)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email, // New field
      'username': username,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
      'last_seen': lastSeen.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Supabase response
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      email: map['email'], // New field
      username: map['username'],
      avatarUrl: map['avatar_url'],
      isOnline: map['is_online'] ?? false,
      lastSeen: DateTime.parse(map['last_seen']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // CopyWith for updates
  Profile copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper to get display identifier (email or phone)
  String get displayIdentifier {
    if (email != null) return email!;
    return 'No contact info';
  }

  // Helper to check if email is verified (if using email auth)
  bool get isEmailVerified {
    // This would need to be fetched from auth.users
    // You might want to add this to your profile table
    return false; // Placeholder
  }
}