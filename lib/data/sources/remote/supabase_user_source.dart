import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/data/mappers/supabase_user_mapper.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/domain/sources/user_remote_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseUserSource extends UserRemoteSource {
  final SupabaseClient _client;

  SupabaseUserSource(this._client);

  @override
  Future<User> getUser(String userId) async {
    try {
      LoggerAccess.logger.debug("Trying to get data of user $userId");
      final user = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single()
          .withConverter((data) => SupabaseUserMapper.fromMap(data));

      LoggerAccess.logger.debug("Data found! $user");
      return user;
    } catch (e) {
      LoggerAccess.logger.error("Supabase select error: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateUser({
    required String userId,
    String? userName,
    String? avatarUrl,
  }) async {
    if (userName == null && avatarUrl == null) {
      throw ArgumentError("No given arguments");
    }

    final newData = <String, dynamic>{
      if (userName != null) 'user_name': userName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };

    try {
      await _client
          .from('users')
          .update(newData)
          .eq('id', userId)
          .select()
          .single();
    } catch (e) {
      LoggerAccess.logger.error("Supabase update error: $e");
      rethrow;
    }
  }
}
