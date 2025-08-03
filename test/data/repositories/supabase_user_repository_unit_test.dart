import 'dart:async';
import 'dart:typed_data';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/data/repositories/supabase_user_repository.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/services/auth_service.dart';
import 'package:embutido_tracker/domain/sources/user_remote_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/data_source_mocks.mocks.dart';
import '../../mocks/service_mocks.mocks.dart';
import '../../mocks/test_helpers.dart';

late AuthService auth;
late UserRemoteSource remoteSource;
late UserRepository repository;
late StreamController<String?> authStreamController;

MockAuthService get mockAuth => auth as MockAuthService;
MockUserRemoteSource get mockRemote => remoteSource as MockUserRemoteSource;

void main() {
  setUp(() {
    auth = MockAuthService();
    authStreamController = StreamController<String?>();
    remoteSource = MockUserRemoteSource();

    when(
      mockAuth.currentUserIdStream,
    ).thenAnswer((_) => authStreamController.stream);

    repository = SupabaseUserRepository(auth, remoteSource);

    LoggerAccess.init(loggerService: MockLoggerService());
  });

  tearDown(() {
    // clean up stream subscriptions
    (repository as SupabaseUserRepository).dispose();
    authStreamController.close();
  });

  test(
    'given user signs in when userStream emits expect correct user',
    () async {
      when(
        mockRemote.getUser(mockUserId),
      ).thenAnswer((_) => Future.value(mockUser));

      final expectStreamEmitsUser = expectLater(
        repository.userStream,
        emits(mockUser),
      );

      // simulate sign-in
      Future.microtask(() => authStreamController.add(mockUserId));

      await expectStreamEmitsUser;
      verify(auth.currentUserIdStream).called(1);
      verify(remoteSource.getUser(mockUserId)).called(1);
    },
  );

  test(
    'given user signs in then out when userStream emits expect correct user then null',
    () async {
      // return signed-in user
      when(
        mockRemote.getUser(mockUserId),
      ).thenAnswer((_) => Future.value(mockUser));

      final expectStreamEmitsUserThenNull = expectLater(
        repository.userStream,
        emitsInOrder([mockUser, null]),
      );

      // simulate sign in and sign out
      Future.microtask(() {
        authStreamController.add(mockUserId);
        authStreamController.add(null);
      });

      await expectStreamEmitsUserThenNull;
      verify(auth.currentUserIdStream).called(1);
      verify(remoteSource.getUser(mockUserId)).called(1);
    },
  );

  test(
    'given user is signed in when accessing currentUser expect returns correct user',
    () async {
      when(mockAuth.currentUserId).thenAnswer((_) => mockUserId);
      when(
        mockRemote.getUser(mockUserId),
      ).thenAnswer((_) => Future.value(mockUser));

      await expectLater(repository.currentUser, completion(mockUser));
      verify(auth.currentUserId).called(1);
      verify(remoteSource.getUser(mockUserId)).called(1);
    },
  );

  test(
    'given user is not signed in when accessing currentUser expect throws exception',
    () async {
      when(mockAuth.currentUserId).thenAnswer((_) => null);
      await expectLater(() => repository.currentUser, throwsException);
      verify(auth.currentUserId).called(1);
      verifyNever(mockRemote.getUser(any));
    },
  );

  test(
    'given valid userId when getUserById is called expect returns corresponding user',
    () async {
      final user1 = User(id: "1", userName: "User 1");
      final user2 = User(id: "2", userName: "User 2");

      when(mockRemote.getUser("1")).thenAnswer((_) => Future.value(user1));
      when(mockRemote.getUser("2")).thenAnswer((_) => Future.value(user2));

      await expectLater(repository.getUserById("1"), completion(user1));
      await expectLater(repository.getUserById("2"), completion(user2));
      verifyInOrder([remoteSource.getUser("1"), remoteSource.getUser("2")]);
    },
  );

  test(
    'given invalid userId when getUserById is called expect throws exception',
    () async {
      when(
        mockRemote.getUser(any),
      ).thenAnswer((_) => Future.error(Exception("User not found")));

      final invalidUserId = "321";
      await expectLater(repository.getUserById(invalidUserId), throwsException);
      verify(remoteSource.getUser(invalidUserId)).called(1);
    },
  );

  test(
    'given valid username when updateUsername is called then currentUser should reflect updated username',
    () async {
      final newName = "Test Person";
      final updatedUser = mockUser.copyWith(userName: newName);

      when(mockAuth.currentUserId).thenAnswer((_) => mockUserId);
      when(
        mockRemote.updateUser(
          userId: mockUserId,
          userName: anyNamed('userName'),
        ),
      ).thenAnswer((_) => Future.value());
      when(
        mockRemote.getUser(mockUserId),
      ).thenAnswer((_) => Future.value(updatedUser));

      await repository.updateUsername(newName);

      await expectLater(repository.currentUser, completion(updatedUser));
      verifyInOrder([
        remoteSource.updateUser(userId: mockUserId, userName: newName),
        remoteSource.getUser(mockUserId),
        remoteSource.getUser(mockUserId),
      ]);
    },
  );

  test(
    'given invalid username when updateUsername is called expect throws exception',
    () async {
      when(mockAuth.currentUserId).thenAnswer((_) => mockUserId);
      when(
        mockRemote.updateUser(
          userId: anyNamed('userId'),
          userName: anyNamed('userName'),
        ),
      ).thenAnswer((_) => Future.error(Exception("New username too long")));

      final badName =
          "Name that is probably too long as a username, so this would fail";
      await expectLater(repository.updateUsername(badName), throwsException);
      verify(
        remoteSource.updateUser(userId: mockUserId, userName: badName),
      ).called(1);
    },
  );

  test(
    'given valid imageBytes when uploadAvatar is called expect current user has uploaded avatar',
    () async {
      final newAvatar = "fake/avatar.png";
      final updatedUser = mockUser.copyWith(avatarUrl: newAvatar);

      when(mockAuth.currentUserId).thenAnswer((_) => mockUserId);
      when(
        mockRemote.uploadAvatar(
          userId: mockUserId,
          imageBytes: anyNamed('imageBytes'),
        ),
      ).thenAnswer((_) => Future.value());
      when(
        mockRemote.getUser(mockUserId),
      ).thenAnswer((_) => Future.value(updatedUser));

      final fakeImageBytes = Uint8List(16);
      await repository.uploadAvatar(fakeImageBytes);

      await expectLater(repository.currentUser, completion(updatedUser));
      verifyInOrder([
        remoteSource.uploadAvatar(
          userId: mockUserId,
          imageBytes: fakeImageBytes,
        ),
        remoteSource.getUser(mockUserId),
        remoteSource.getUser(mockUserId),
      ]);
    },
  );

  test(
    'given invalid imageBytes when uploadAvatar is called expect throws exception',
    () async {
      when(mockAuth.currentUserId).thenAnswer((_) => mockUserId);
      when(
        mockRemote.uploadAvatar(
          userId: anyNamed('userId'),
          imageBytes: anyNamed('imageBytes'),
        ),
      ).thenAnswer((_) => Future.error(Exception("Invalid image")));

      final fakeCorruptImageBytes = Uint8List(14);
      await expectLater(
        repository.uploadAvatar(fakeCorruptImageBytes),
        throwsException,
      );
      verify(
        remoteSource.uploadAvatar(
          userId: mockUserId,
          imageBytes: fakeCorruptImageBytes,
        ),
      ).called(1);
    },
  );
}
