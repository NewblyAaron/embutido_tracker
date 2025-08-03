import 'dart:typed_data';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/data/mappers/supabase_user_mapper.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_storage_source.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/domain/services/avatar_cache_service.dart';
import 'package:embutido_tracker/domain/sources/user_remote_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseUserSource extends UserRemoteSource {
  final SupabaseClient _client;
  final SupabaseStorageSource _storageSource;
  final AvatarCacheService _avatarCacheService;

  SupabaseUserSource(
    this._client,
    this._storageSource,
    this._avatarCacheService,
  );

  @override
  Future<User> getUser(String userId) async {
    try {
      LoggerAccess.logger.debug("Getting data of user $userId");
      final userMap =
          await _client.from('users').select().eq('id', userId).single();
      final avatarUrl = await _avatarCacheService.getAvatarUrl(userId);

      LoggerAccess.logger.debug(
        "Data found!\nUser data: $userMap\nAvatar URL: $avatarUrl",
      );
      return SupabaseUserMapper.fromMap(userMap, avatarUrl: avatarUrl);
    } catch (e) {
      LoggerAccess.logger.error("Supabase select error: $e");
      rethrow;
    }
  }

  @override
  Future<void> uploadAvatar({
    required String userId,
    Uint8List? imageBytes,
  }) async {
    if (imageBytes != null) {
      await _avatarCacheService.invalidate(userId);
      await _storageSource.uploadAvatar(userId: userId, imageBytes: imageBytes);
    } else {
      return _storageSource.deleteAvatar(userId);
    }
  }

  @override
  Future<void> updateUser({required String userId, String? userName}) async {
    if (userName == null) {
      throw ArgumentError("No given arguments");
    }

    LoggerAccess.logger.debug("Updating $userId's username to $userName");

    final newData = <String, dynamic>{'user_name': userName};

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
