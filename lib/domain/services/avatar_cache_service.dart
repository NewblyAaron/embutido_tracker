abstract class AvatarCacheService {
  Future<String?> getAvatarUrl(String userId);
  Future<void> invalidate(String userId);
  Future<void> invalidateAll();
}