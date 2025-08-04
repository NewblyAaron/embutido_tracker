import 'dart:typed_data';

abstract class AvatarService {
  Future<String?> getAvatarUrl(String userId);
  Future<void> uploadAvatar(String userId, Uint8List imageBytes);
  Future<void> deleteAvatar(String userId);
}
