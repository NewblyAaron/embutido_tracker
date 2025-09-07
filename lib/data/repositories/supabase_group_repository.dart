import 'package:embutido_tracker/domain/entity/group.dart';
import 'package:embutido_tracker/domain/repositories/group_repository.dart';
import 'package:embutido_tracker/domain/sources/group_remote_source.dart';

class SupabaseGroupRepository implements GroupRepository {
  final GroupRemoteSource _source;

  SupabaseGroupRepository(this._source);

  @override
  Future<Group> createGroup(String groupName, String creatorUserId) =>
      _source.createGroup(name: groupName, creatorUserId: creatorUserId);

  @override
  Future<bool> joinGroup(String userId, String joinCode) =>
      _source.joinGroup(userId, joinCode);

  @override
  Future<List<Group>> getGroupsByUserId(String userId) =>
      _source.getGroupsOfUser(userId);
}
