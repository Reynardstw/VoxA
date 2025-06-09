class User {
  final int id;
  final String name;
  final String email;
  final String profileUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? password;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profileUrl,
    required this.createdAt,
    required this.updatedAt,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['username'] ?? 'Guest',
      email: json['email'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': name,
      'email': email,
      'profileUrl': profileUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
