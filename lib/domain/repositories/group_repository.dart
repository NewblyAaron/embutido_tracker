import 'package:embutido_tracker/domain/entity/group.dart';

abstract class GroupRepository {
  Future<List<Group>> getGroupsByUserId(String userId);
  Future<Group> createGroup(String groupName, String creatorUserId);
  Future<bool> joinGroup(String userId, String joinCode);
}
