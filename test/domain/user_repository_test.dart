import 'dart:async';
import 'dart:typed_data';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/repository_mocks.mocks.dart';
import '../mocks/service_mocks.mocks.dart';
import '../mocks/test_helpers.dart';

late StreamController<User?> userStreamController;
late UserRepository repository;

MockUserRepository get mockRepository => repository as MockUserRepository;

void main() {
  setUp(() {
    userStreamController = StreamController<User?>.broadcast();
    repository = MockUserRepository();

    when(
      mockRepository.userStream,
    ).thenAnswer((_) => userStreamController.stream);

    LoggerAccess.init(loggerService: MockLoggerService());
  });

  tearDown(() {
    userStreamController.close();
  });

  test(
    'given signed-in user when userStream emits expect stream emits correct user',
    () async {
      // simulate sign in
      Future.microtask(() => userStreamController.add(mockUser));

      await expectLater(repository.userStream, emits(mockUser));
    },
  );

  test(
    'given signed-out user when userStream emits expect stream emits null',
    () async {
      // simulate sign in and sign out
      Future.microtask(() {
        userStreamController.add(mockUser);
        userStreamController.add(null);
      });

      await expectLater(repository.userStream, emitsInOrder([mockUser, null]));
    },
  );

  test(
    'given user is signed in when accessing currentUser expect returns correct user',
    () async {
      when(
        mockRepository.currentUser,
      ).thenAnswer((_) => Future.value(mockUser));

      await expectLater(repository.currentUser, completion(mockUser));
    },
  );

  test(
    'given user is not signed in when accessing currentUser expect throws exception',
    () async {
      when(
        mockRepository.currentUser,
      ).thenAnswer((_) => Future.error(Exception("User not logged in")));

      await expectLater(repository.currentUser, throwsException);
    },
  );

  test(
    'given valid userId when getUserById is called expect returns corresponding user',
    () async {
      when(
        mockRepository.getUserById(any),
      ).thenAnswer((_) => Future.value(mockUser));

      await expectLater(
        repository.getUserById(mockUserId),
        completion(mockUser),
      );
    },
  );

  test(
    'given invalid userId when getUserById is called expect throws exception',
    () async {
      when(
        mockRepository.getUserById(any),
      ).thenAnswer((_) => Future.error(Exception("User not logged in")));

      final invalidUserId = "321";
      await expectLater(repository.getUserById(invalidUserId), throwsException);
    },
  );

  test(
    'given valid username when updateUsername is called expect method is called with new username',
    () async {
      when(
        mockRepository.updateUsername(any),
      ).thenAnswer((_) => Future.value());

      final newName = "Test Person";
      await repository.updateUsername(newName);

      verify(repository.updateUsername(newName));
    },
  );

  test(
    'given invalid username when updateUsername is called expect throws exception',
    () async {
      when(
        mockRepository.updateUsername(any),
      ).thenAnswer((_) => Future.error(Exception("Invalid username")));

      final badName =
          "Name that is probably too long as a username, so this would fail";
      await expectLater(repository.updateUsername(badName), throwsException);
    },
  );

  test(
    'given valid imageBytes when uploadAvatar is called expect method is called with given imageBytes',
    () async {
      when(mockRepository.uploadAvatar(any)).thenAnswer((_) => Future.value());

      final fakeImageBytes = Uint8List(16);
      await repository.uploadAvatar(fakeImageBytes);

      verify(repository.uploadAvatar(fakeImageBytes));
    },
  );

  test(
    'given corrupted imageBytes when uploadAvatar is called expect throws exception',
    () async {
      when(
        mockRepository.uploadAvatar(any),
      ).thenAnswer((_) => Future.error(Exception("Corrupted image")));

      final fakeImageBytes = Uint8List(16);
      await expectLater(
        repository.uploadAvatar(fakeImageBytes),
        throwsException,
      );
    },
  );
}
