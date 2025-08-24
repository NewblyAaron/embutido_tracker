class User {
  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;

  User({required this.id, this.email, this.name, this.avatarUrl});

  User copyWith({String? name, String? avatarUrl}) => User(
    id: id,
    email: email,
    name: name ?? this.name,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );

  @override
  String toString() => "User [$id]: $name";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          avatarUrl == other.avatarUrl;

  @override
  int get hashCode => Object.hashAll([id, email, name, avatarUrl]);
}
