import 'dart:typed_data';

import 'package:embutido_tracker/domain/entity/group.dart';
import 'package:embutido_tracker/domain/entity/user.dart';

abstract class UserRepository {
  Stream<User?> get userStream;
  Future<User> get currentUser;

  Future<User> getUserById(String userId);
  Future<List<Group>> getGroupsByUserId(String userId);
  Future<void> updateUsername(String newUsername);
  Future<void> uploadAvatar(Uint8List imageBytes);
}
