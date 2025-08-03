import 'dart:typed_data';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/fake_user_repository.dart';
import '../mocks/service_mocks.mocks.dart';
import '../mocks/test_helpers.dart';

late UserRepository repository;

FakeUserRepository get fakeRepository => repository as FakeUserRepository;

void main() {
  setUp(() {
    repository = FakeUserRepository();

    LoggerAccess.init(loggerService: MockLoggerService());
  });

  tearDown(() {
    fakeRepository.dispose();
  });

  test(
    'given signed-in user when userStream emits expect stream emits correct user',
    () async {
      final expectStreamEmitsUser = expectLater(
        repository.userStream,
        emits(mockUser),
      );

      // simulate sign in
      Future.microtask(() => fakeRepository.setCurrentUser(mockUser));

      await expectStreamEmitsUser;
    },
  );

  test(
    'given signed-out user when userStream emits expect stream emits null',
    () async {
      final expectStreamEmitsUserThenNull = expectLater(
        repository.userStream,
        emitsInOrder([mockUser, null]),
      );

      // simulate sign in and sign out
      // simulate sign in
      Future.microtask(() {
        fakeRepository.setCurrentUser(mockUser);
        fakeRepository.setCurrentUser(null);
      });

      await expectStreamEmitsUserThenNull;
    },
  );

  test(
    'given user is signed in when accessing currentUser expect returns correct user',
    () async {
      // simulate sign in
      fakeRepository.setCurrentUser(mockUser);

      await expectLater(repository.currentUser, completion(mockUser));
    },
  );

  test(
    'given user is not signed in when accessing currentUser expect throws exception',
    () async {
      await expectLater(repository.currentUser, throwsException);
    },
  );

  test(
    'given valid userId when getUserById is called expect returns corresponding user',
    () async {
      fakeRepository.addUser(mockUser);

      await expectLater(
        repository.getUserById(mockUserId),
        completion(mockUser),
      );
    },
  );

  test(
    'given invalid userId when getUserById is called expect throws exception',
    () async {
      final invalidUserId = "321";
      await expectLater(repository.getUserById(invalidUserId), throwsException);
    },
  );

  test(
    'given valid username when updateUsername is called expect currentUser has newName as username',
    () async {
      fakeRepository.setCurrentUser(mockUser);

      final newName = "Test Person";
      final updatedUser = mockUser.copyWith(userName: newName);
      await repository.updateUsername(newName);

      await expectLater(repository.currentUser, completion(updatedUser));
    },
  );

  test(
    'given invalid username when updateUsername is called expect throws exception',
    () async {
      final badName =
          "Name that is probably too long as a username, so this would fail";
      await expectLater(repository.updateUsername(badName), throwsException);
    },
  );

  test(
    'given valid imageBytes when uploadAvatar is called expect current user has uploaded avatar',
    () async {
      fakeRepository.setCurrentUser(mockUser);

      final fakeImageBytes = Uint8List(16);
      final updatedUser = mockUser.copyWith(avatarUrl: 'fake/avatar.png');
      await repository.uploadAvatar(fakeImageBytes);

      await expectLater(repository.currentUser, completion(updatedUser));
    },
  );

  test(
    'given invalid imageBytes when uploadAvatar is called expect throws exception',
    () async {
      final fakeCorruptImageBytes = Uint8List(14);
      await expectLater(
        repository.uploadAvatar(fakeCorruptImageBytes),
        throwsException,
      );
    },
  );
}
