class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    // Handle different createdAt formats (Timestamp vs milliseconds)
    DateTime createdAt;
    if (map['createdAt'] is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(map['createdAt']);
    } else if (map['createdAt'] != null) {
      // Handle Firestore Timestamp by calling toDate() method
      try {
        final timestamp = map['createdAt'];
        // Check if it has a toDate method (Firestore Timestamp)
        if (timestamp.runtimeType.toString().contains('Timestamp')) {
          createdAt = timestamp.toDate();
        } else {
          createdAt = DateTime.now(); // fallback
        }
      } catch (e) {
        createdAt = DateTime.now(); // fallback
      }
    } else {
      createdAt = DateTime.now(); // fallback
    }

    // Handle lastLoginAt similarly
    DateTime? lastLoginAt;
    if (map['lastLoginAt'] is int) {
      lastLoginAt = DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt']);
    } else if (map['lastLoginAt'] != null) {
      try {
        final timestamp = map['lastLoginAt'];
        if (timestamp.runtimeType.toString().contains('Timestamp')) {
          lastLoginAt = timestamp.toDate();
        }
      } catch (e) {
        lastLoginAt = null;
      }
    }

    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? map['name'], // Handle both 'displayName' and 'name'
      photoUrl: map['photoUrl'],
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, email: $email, displayName: $displayName}';
  }
}