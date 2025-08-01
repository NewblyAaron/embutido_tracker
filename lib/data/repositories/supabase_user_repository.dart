import 'dart:async';
import 'dart:typed_data';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/sources/auth_source.dart';
import 'package:embutido_tracker/domain/sources/user_remote_source.dart';

class SupabaseUserRepository implements UserRepository {
  late final StreamSubscription _authSub;
  final _userStreamController = StreamController<User?>.broadcast();
  final AuthService _auth;
  final UserRemoteSource _remoteSource;

  SupabaseUserRepository(this._auth, this._remoteSource) {
    _authSub = _auth.currentUserIdStream
        .asyncMap((userId) async {
          LoggerAccess.logger.debug("Received new user ID: $userId");
          return userId != null ? await _remoteSource.getUser(userId) : null;
        })
        .listen((user) => _userStreamController.add(user));
  }

  String get currentUserId {
    final userId = _auth.currentUserId;
    if (userId == null) throw Exception("User not logged in");
    return userId;
  }

  @override
  Stream<User?> get userStream => _userStreamController.stream;

  @override
  Future<User> get currentUser {
    return _remoteSource.getUser(currentUserId);
  }

  @override
  Future<User> getUserById(String userId) => _remoteSource.getUser(userId);

  @override
  Future<void> updateUsername(String newUsername) async {
    await _remoteSource.updateUser(
      userId: currentUserId,
      userName: newUsername,
    );
    await _refreshCurrentUser();
  }

  @override
  Future<void> uploadAvatar(Uint8List imageBytes) async {
    await _remoteSource.uploadAvatar(
      userId: currentUserId,
      imageBytes: imageBytes,
    );
    await _refreshCurrentUser();
  }

  Future<void> _refreshCurrentUser() async {
    final user = await currentUser;
    _userStreamController.add(user);
  }

  void dispose() {
    _authSub.cancel();
    _userStreamController.close();
  }
}
