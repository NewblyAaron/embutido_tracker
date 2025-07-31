import 'package:embutido_tracker/domain/entity/user.dart';

abstract class UserRemoteSource {
  Future<User> getUser(String userId);
  Future<void> updateUser({
    required String userId,
    String? userName,
    String? avatarUrl,
  });
}