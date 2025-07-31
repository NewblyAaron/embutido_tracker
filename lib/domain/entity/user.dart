class User {
  final String id;
  final String? email;
  final String? userName;
  final String? avatarUrl;

  User({required this.id, required this.email, this.userName, this.avatarUrl});

  @override
  String toString() => "$userName [$id]";
}
