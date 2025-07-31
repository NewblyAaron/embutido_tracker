import 'package:embutido_tracker/domain/entity/user.dart';

abstract class UserRepository {
  Stream<User?> get userStream;

  Future<User> getCurrentUser();
  Future<User> getUserById(String userId);
  Future<void> updateUserProfile({
    required String userId,
    String? userName,
    String? avatarUrl,
  });
}
