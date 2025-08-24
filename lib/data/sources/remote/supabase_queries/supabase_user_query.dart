import 'package:embutido_tracker/data/mappers/supabase_entity_mapper.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseUserQuery {
  final SupabaseClient _client;
  final usersTableName = 'users';

  SupabaseUserQuery(this._client);

  Future<User> selectById(String id) => _client
      .from(usersTableName)
      .select()
      .eq('id', id)
      .single()
      .withConverter((data) => SupabaseUserMapper.fromMap(data));

  Future<void> updateById(
    String id, {
    required Map<String, dynamic> updateData,
  }) =>
      _client
          .from(usersTableName)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();
}
