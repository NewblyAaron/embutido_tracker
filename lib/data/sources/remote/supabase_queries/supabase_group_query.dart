import 'package:embutido_tracker/data/mappers/supabase_entity_mapper.dart';
import 'package:embutido_tracker/domain/entity/group.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseGroupQuery {
  final SupabaseClient _client;
  final groupTableName = 'groups';
  final groupMembersTableName = 'group_members';

  SupabaseGroupQuery(this._client);

  Future<Group> selectById(String id) async {
    final groupMap =
        await _client
            .from(groupTableName)
            .select('''
              *,
              group_members(
                users(*)
              )
            ''')
            .eq('id', id)
            .single();

    final members = <String, User>{};
    for (final memberData in groupMap['group_members']) {
      final user = SupabaseUserMapper.fromMap(memberData['users']);
      members[user.id] = user;
    }

    return SupabaseGroupMapper.fromMap(groupMap, members: members);
  }

  Future<List<Group>> selectByUserId(String userId) async {
    final response = await _client
        .from('groups')
        .select('''
          *,
          group_members!inner(
            joined_at,
            users(*)
          )
        ''')
        .eq('group_members.user_id', userId);

    return response
        .map<Group>((groupMap) => SupabaseGroupMapper.fromMap(groupMap))
        .toList();
  }

  Future<Group> insert({required Map<String, dynamic> insertData}) async {
    final result = await _client
        .from(groupTableName)
        .insert(insertData)
        .select()
        .single()
        .withConverter((data) => SupabaseGroupMapper.fromMap(data));

    return result;
  }

  Future<Group> updateById(
    String id, {
    required Map<String, dynamic> updateData,
  }) async {
    // TODO: updateById implementation
    final result = await _client
        .from(groupTableName)
        .update(updateData)
        .eq('id', id)
        .select()
        .single()
        .withConverter((data) => SupabaseGroupMapper.fromMap(data));

    return result;
  }

  Future<void> deleteById(String id) =>
      _client.from(groupTableName).delete().eq('id', id);
}
