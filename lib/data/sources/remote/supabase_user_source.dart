import 'dart:typed_data';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_queries/supabase_user_query.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/domain/services/avatar_cache_service.dart';
import 'package:embutido_tracker/domain/sources/user_remote_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseUserSource implements UserRemoteSource {
  final SupabaseUserQuery _userQuery;
  final AvatarService _avatarService;

  SupabaseUserSource(this._userQuery, this._avatarService);

  SupabaseUserSource.fromClient(SupabaseClient client, this._avatarService)
    : _userQuery = SupabaseUserQuery(client);

  @override
  Future<User> getUser(String userId) async {
    try {
      LoggerAccess.logger.debug("Getting data of user $userId");

      final user = await _userQuery.selectById(userId);
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
  Future<List<User>> getUsers(List<String> userIds) async {
    try {
      final usersMap = Map.fromEntries(
        (await _userQuery.selectByIds(
          userIds,
        )).map((user) => MapEntry(user.id, user)),
      );

      final futures = userIds.map((id) async {
        final url = await _avatarService.getAvatarUrl(id);
        return MapEntry(id, url);
      });
      final avatarUrlsMap = Map.fromEntries(await Future.wait(futures));

      for (final entry in avatarUrlsMap.entries) {
        final userId = entry.key;
        final url = entry.value;

        final user = usersMap[userId];
        usersMap[userId] = user!.copyWith(avatarUrl: url);
      }

      return usersMap.values.toList();
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
      await _userQuery.updateById(userId, updateData: newData);

      LoggerAccess.logger.debug("Updated $userId's username to $userName");
    } catch (e) {
      LoggerAccess.logger.error("Supabase update error: $e");
      rethrow;
    }
  }
}
