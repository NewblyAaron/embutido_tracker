import 'dart:async';
import 'dart:typed_data';

import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';

class FakeUserRepository extends UserRepository {
  final Map<String, User> _users = {};
  final _controller = StreamController<User?>.broadcast();
  User? _currentUser;

  @override
  Stream<User?> get userStream => _controller.stream;

  @override
  Future<User> get currentUser async =>
      _currentUser == null
          ? Future.error(Exception("User not logged in"))
          : _currentUser!;

  void setCurrentUser(User? user) {
    _currentUser = user;
    if (user != null) addUser(user);
    _controller.add(user);

    print("Current user is now $user");
  }

  void addUser(User user) {
    _users[user.id] = user;

    print("Added $user");
  }

  @override
  Future<User> getUserById(String userId) {
    return _users[userId] != null
        ? Future.value(_users[userId]!)
        : Future.error(Exception("User not found"));
  }

  @override
  Future<void> updateUsername(String newUsername) async {
    if (newUsername.length > 20) {
      return Future.error(Exception("New username too long"));
    }

    _currentUser = (await currentUser).copyWith(userName: newUsername);
  }

  @override
  Future<void> uploadAvatar(Uint8List imageBytes) async {
    if (imageBytes.length != 16) {
      return Future.error(Exception("Invalid image"));
    }

    final updated = (await currentUser).copyWith(avatarUrl: 'fake/avatar.png');

    _users[updated.id] = updated;
    _currentUser = updated;
    _controller.add(updated);
  }

  void dispose() {
    _controller.close();
  }
}
