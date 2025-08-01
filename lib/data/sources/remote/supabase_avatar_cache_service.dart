import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_storage_source.dart';
import 'package:embutido_tracker/domain/services/avatar_cache_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class _CachedUrl {
  final String url;
  final DateTime expiresAt;

  _CachedUrl(this.url, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class SupabaseAvatarCacheService extends AvatarCacheService {
  final SupabaseStorageSource _storageSource;
  final BaseCacheManager _cacheManager;

  SupabaseAvatarCacheService(this._storageSource, this._cacheManager);

  final _avatarUrlCache = <String, _CachedUrl>{};

  @override
  Future<String?> getAvatarUrl(String userId) async {
    LoggerAccess.logger.debug("Getting avatar URL of $userId...");
    final cached = _avatarUrlCache[userId];

    if (cached != null && !cached.isExpired) {
      final fileInfo = await _cacheManager.getFileFromCache(cached.url);
      if (fileInfo != null) {
        LoggerAccess.logger.debug("Using cache: ${cached.url}");
        return cached.url;
      }
    }

    try {
      final newUrl = await _storageSource.generateAvatarUrl(userId);

      LoggerAccess.logger.debug("Caching generated avatar URL...");
      await _cacheManager.downloadFile(newUrl);
      _avatarUrlCache[userId] = _CachedUrl(
        newUrl,
        DateTime.now().add(_storageSource.fileExpiry),
      );
      LoggerAccess.logger.debug("Cached newly generated avatar URL.");
      return newUrl;
    } catch (e) {
      LoggerAccess.logger.error("Getting avatar URL error: $e");
      return cached?.url;
    }
  }

  @override
  Future<void> invalidate(String userId) async {
    LoggerAccess.logger.debug("Invalidating avatar cache for $userId");
    final cached = _avatarUrlCache.remove(userId);
    if (cached != null) {
      await _cacheManager.removeFile(cached.url);
      LoggerAccess.logger.debug("$userId's avatar cache has been invalidated");
    }
  }

  @override
  Future<void> invalidateAll() async {
    LoggerAccess.logger.debug("Invalidating all avatar cache");
    _avatarUrlCache.clear();
    await _cacheManager.emptyCache();
    LoggerAccess.logger.debug("Invalidated all avatar cache");
  }
}
