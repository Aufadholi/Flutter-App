class UserModel {
  final int id;
  final String name;
  final String email;
  final String password;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      avatarUrl: _normalizeAvatarUrl((json['avatar'] ?? '').toString()),
    );
  }

  static String? _normalizeAvatarUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    // Some API records contain .jp instead of .jpg.
    if (trimmed.endsWith('.jp')) {
      return '${trimmed}g';
    }

    return trimmed;
  }
}
