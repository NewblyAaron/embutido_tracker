import 'package:embutido_tracker/domain/entity/group.dart';

abstract class GroupRemoteSource {
  Future<Group> getGroup(String groupId);
  Future<List<Group>> getGroupsOfUser(String userId);
  Future<Group> createGroup({
    required String name,
    required String creatorUserId,
  });
  Future<void> deleteGroup(String groupId);
  Future<void> addGroupMember(String groupId, String userId);
  Future<void> removeGroupMember(String groupId, String userId);
}
