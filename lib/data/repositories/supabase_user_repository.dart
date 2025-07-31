import 'dart:async';

import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/sources/auth_source.dart';
import 'package:embutido_tracker/domain/sources/user_remote_source.dart';

class SupabaseUserRepository implements UserRepository {
  final _userStreamController = StreamController<User?>.broadcast();
  final AuthService _auth;
  final UserRemoteSource _remoteSource;

  SupabaseUserRepository(this._auth, this._remoteSource) {
    _auth.currentUserIdStream.asyncMap((userId) async {
      _userStreamController.add(
        userId != null ? await _remoteSource.getUser(userId) : null,
      );
    });
  }

  @override
  Stream<User?> get userStream => _userStreamController.stream;

  @override
  Future<User> getCurrentUser() async {
    final userId = _auth.currentUserId;
    if (userId == null) throw Exception("User not logged in");
    return _remoteSource.getUser(userId);
  }

  @override
  Future<User> getUserById(String userId) => _remoteSource.getUser(userId);

  @override
  Future<void> updateUserProfile({
    required String userId,
    String? userName,
    String? avatarUrl,
  }) async {
    await _remoteSource.updateUser(
      userId: userId,
      userName: userName,
      avatarUrl: avatarUrl,
    );
    await refreshCurrentUser();
  }

  Future<void> refreshCurrentUser() async {
    final user = await getCurrentUser();
    _userStreamController.add(user);
  }
}
