import 'package:embutido_tracker/data/sources/remote/supabase_queries/supabase_group_query.dart';
import 'package:embutido_tracker/domain/entity/group.dart';
import 'package:embutido_tracker/domain/sources/group_remote_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseGroupSource implements GroupRemoteSource {
  final SupabaseGroupQuery _query;

  SupabaseGroupSource(this._query);

  SupabaseGroupSource.fromClient(SupabaseClient client)
    : _query = SupabaseGroupQuery(client);

  @override
  Future<Group> getGroup(String groupId) => _query.selectById(groupId);

  @override
  Future<List<Group>> getGroupsOfUser(String userId) =>
      _query.selectByUserId(userId);

  @override
  Future<Group> createGroup({
    required String name,
    required String creatorUserId,
  }) {
    final newGroupData = <String, dynamic>{
      'name': name,
      'creator_user_id': creatorUserId,
    };

    return _query.insert(insertData: newGroupData);
  }

  @override
  Future<bool> joinGroup(String userId, String joinCode) =>
      _query.joinGroup(userId, joinCode);

  @override
  Future<void> removeGroupMember(String groupId, String userId) {
    // TODO: implement removeGroupMember
    throw UnimplementedError();
  }

  @override
  Future<void> deleteGroup(String groupId) {
    // TODO: implement deleteGroup
    throw UnimplementedError();
  }
}
