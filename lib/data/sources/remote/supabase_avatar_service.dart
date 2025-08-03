import 'dart:typed_data';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_storage_source.dart';
import 'package:embutido_tracker/domain/services/avatar_cache_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachedUrl {
  final String url;
  final DateTime expiresAt;

  CachedUrl(this.url, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class SupabaseAvatarService implements AvatarService {
  final SupabaseStorageSource _storageSource;
  final BaseCacheManager _cacheManager;
  final Map<String, CachedUrl?> _avatarUrlCache;

  SupabaseAvatarService(
    this._storageSource,
    this._cacheManager, [
    Map<String, CachedUrl?>? avatarUrlCache,
  ]) : _avatarUrlCache = avatarUrlCache ?? <String, CachedUrl?>{};

  final String avatarFileName = "avatar.png";
  String _filePath(String userId) => "$userId/$avatarFileName";

  @override
  Future<String?> getAvatarUrl(String userId) async {
    LoggerAccess.logger.debug("Getting avatar URL of $userId...");
    final cached = _avatarUrlCache[userId];

    if (cached != null) {
      if (!cached.isExpired) {
        final fileInfo = await _cacheManager.getFileFromCache(cached.url);
        if (fileInfo != null) {
          LoggerAccess.logger.debug("Using cache: ${cached.url}");
          return cached.url;
        } else {
          LoggerAccess.logger.debug(
            "Cache exists but file is null; regenerating URL",
          );
        }
      } else {
        LoggerAccess.logger.debug("Cache is expired; regenerating URL");
      }
    }

    try {
      final newUrl = await _storageSource.generateUrl(_filePath(userId));

      LoggerAccess.logger.debug("Caching generated avatar URL...");
      await _cacheManager.downloadFile(newUrl);
      _avatarUrlCache[userId] = CachedUrl(
        newUrl,
        DateTime.now().add(_storageSource.fileExpiry),
      );
      LoggerAccess.logger.debug("Cached newly generated avatar URL.");
      return newUrl;
    } catch (e) {
      LoggerAccess.logger.error("Generation failed: $e");
      final fallbackUrl = cached?.url;
      if (fallbackUrl != null) {
        LoggerAccess.logger.warn("Using cached URL as fallback");
        return fallbackUrl;
      }

      return null;
    }
  }

  @override
  Future<void> uploadAvatar(String userId, Uint8List imageBytes) async {
    LoggerAccess.logger.debug("Uploading new avatar for $userId");
    await _storageSource.upload(_filePath(userId), bytes: imageBytes);
    await _invalidate(userId);
  }

  @override
  Future<void> deleteAvatar(String userId) async {
    await _storageSource.delete(_filePath(userId));
    await _invalidate(userId);
  }

  Future<void> _invalidate(String userId) async {
    LoggerAccess.logger.debug("Invalidating avatar cache for $userId");
    final cached = _avatarUrlCache.remove(userId);
    if (cached != null) {
      await _cacheManager.removeFile(cached.url);
      LoggerAccess.logger.debug("$userId's avatar cache has been invalidated");
    }
  }

  Future<void> _invalidateAll() async {
    LoggerAccess.logger.debug("Invalidating all avatar cache");
    _avatarUrlCache.clear();
    await _cacheManager.emptyCache();
    LoggerAccess.logger.debug("Invalidated all avatar cache");
  }

  void dispose() {
    _invalidateAll();
  }
}
