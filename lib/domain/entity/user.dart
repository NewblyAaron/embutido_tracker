class User {
  final String id;
  final String? email;
  final String? userName;
  final String? avatarUrl;

  User({required this.id, required this.email, this.userName, this.avatarUrl});

  User copyWith({String? userName, String? avatarUrl}) => User(
    id: id,
    email: email,
    userName: userName ?? this.userName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );

  @override
  String toString() => "$userName [$id]";
}
