// lib/models/user.dart
class User {
  final int id;
  final String email;
  final String role; // user, creator, admin
  final String displayName;
  final String provider;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.displayName = '',
    this.provider = 'local',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'displayName': displayName,
      'provider': provider,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? 0,
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      displayName: map['displayName'] ?? '',
      provider: map['provider'] ?? 'local',
    );
  }
}