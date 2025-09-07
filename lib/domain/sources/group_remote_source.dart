import 'package:embutido_tracker/domain/entity/group.dart';

abstract class GroupRemoteSource {
  Future<Group> getGroup(String groupId);
  Future<List<Group>> getGroupsOfUser(String userId);
  Future<Group> createGroup({
    required String name,
    required String creatorUserId,
  });
  Future<bool> joinGroup(String userId, String joinCode);
  Future<void> deleteGroup(String groupId);
  Future<void> removeGroupMember(String groupId, String userId);
}
