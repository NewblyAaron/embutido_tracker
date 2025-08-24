import 'package:embutido_tracker/domain/entity/user.dart';

class Group {
  final String id;
  final String name;
  final String? creatorUserId;
  final String? joinCode;
  final Map<String, User> members;

  Group({
    required this.id,
    required this.name,
    this.creatorUserId,
    this.joinCode,
    Map<String, User>? members,
  }) : members = members ?? {};

  @override
  String toString() => "Group [$id]: $name";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          creatorUserId == other.creatorUserId &&
          joinCode == other.joinCode &&
          _membersEqual(other.members);

  @override
  int get hashCode => Object.hashAll([id, name, creatorUserId, joinCode]);

  bool _membersEqual(Map<String, User> other) {
    if (members.length != other.length) return false;
    return members.keys.toSet().containsAll(other.keys);
  }
}
