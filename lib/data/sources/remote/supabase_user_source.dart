import 'dart:typed_data';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/sources/query_interfaces.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_user_table_query.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/domain/services/avatar_cache_service.dart';
import 'package:embutido_tracker/domain/sources/user_remote_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseUserSource implements UserRemoteSource {
  final TableQuery<User> _query;
  final AvatarService _avatarService;

  SupabaseUserSource(this._query, this._avatarService);

  SupabaseUserSource.fromClient(SupabaseClient client, this._avatarService)
    : _query = SupabaseUserTableQuery(client);

  @override
  Future<User> getUser(String userId) async {
    try {
      LoggerAccess.logger.debug("Getting data of user $userId");

      final user = await _query.selectById(userId);
      final avatarUrl = await _avatarService.getAvatarUrl(userId);

      LoggerAccess.logger.debug(
        "Data found!\nUser data: $user\nAvatar URL: $avatarUrl",
      );

      return user.copyWith(avatarUrl: avatarUrl);
    } catch (e) {
      LoggerAccess.logger.error("Supabase select error: $e");
      rethrow;
    }
  }

  @override
  Future<void> uploadAvatar({required String userId, Uint8List? imageBytes}) =>
      imageBytes != null
          ? _avatarService.uploadAvatar(userId, imageBytes)
          : _avatarService.deleteAvatar(userId);

  @override
  Future<void> updateUser({required String userId, String? userName}) async {
    if (userName == null) {
      LoggerAccess.logger.debug("Called updateUser but nothing to update");
      return Future.error(ArgumentError("No given arguments"));
    }

    try {
      LoggerAccess.logger.debug("Updating $userId's username to $userName");

      final newData = <String, dynamic>{'user_name': userName};
      await _query.updateById(userId, updateData: newData);

      LoggerAccess.logger.debug("Updated $userId's username to $userName");
    } catch (e) {
      LoggerAccess.logger.error("Supabase update error: $e");
      rethrow;
    }
  }
}
