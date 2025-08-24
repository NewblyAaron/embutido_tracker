import 'package:embutido_tracker/domain/entity/group.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:flutter/services.dart';

abstract class UserRemoteSource {
  Future<User> getUser(String userId);
  Future<List<Group>> getGroups(String userId);
  Future<void> uploadAvatar({required String userId, Uint8List? imageBytes});
  Future<void> updateUser({required String userId, String? userName});
}
