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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          userName == other.userName &&
          avatarUrl == other.avatarUrl;

  @override
  int get hashCode => Object.hashAll([id, email, userName, avatarUrl]);
}
