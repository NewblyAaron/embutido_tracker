import 'package:embutido_tracker/data/mappers/supabase_user_mapper.dart';
import 'package:embutido_tracker/domain/sources/query_interfaces.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseUserTableQuery implements TableQuery<User> {
  final SupabaseClient _client;

  SupabaseUserTableQuery(this._client);

  @override
  Future<User> selectById(String id) => _client
      .from('users')
      .select()
      .eq('id', id)
      .single()
      .withConverter((data) => SupabaseUserMapper.fromMap(data));

  @override
  Future<void> updateById(
    String id, {
    required Map<String, dynamic> updateData,
  }) => _client.from('users').update(updateData).eq('id', id).select().single();

  @override
  Future<void> deleteById(String id) {
    // Not needed yet
    throw UnimplementedError("deleteByID is not implemented.");
  }
}
