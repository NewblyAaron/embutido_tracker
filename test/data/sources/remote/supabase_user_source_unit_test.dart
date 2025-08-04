import 'dart:typed_data';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/sources/query_interfaces.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_user_source.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/domain/services/avatar_cache_service.dart';
import 'package:embutido_tracker/domain/sources/user_remote_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/query_mocks.mocks.dart';
import '../../../mocks/service_mocks.mocks.dart';
import '../../../mocks/test_helpers.dart';

late TableQuery<User> query;
late AvatarService avatarService;
late UserRemoteSource source;

MockTableQuery<User> get mockQuery => query as MockTableQuery<User>;
MockAvatarService get mockAvatar => avatarService as MockAvatarService;

void main() {
  setUp(() {
    query = MockTableQuery<User>();
    avatarService = MockAvatarService();
    source = SupabaseUserSource(query, avatarService);

    LoggerAccess.init(loggerService: MockLoggerService());
  });

  test(
    'given valid userId when getUser called expect user with avatarUrl returned',
    () async {
      when(
        mockQuery.selectById(mockUserId),
      ).thenAnswer((_) => Future.value(mockUser));
      when(
        mockAvatar.getAvatarUrl(mockUserId),
      ).thenAnswer((_) => Future.value('fake/avatar.png'));

      final expectedUser = mockUser.copyWith(avatarUrl: 'fake/avatar.png');
      await expectLater(source.getUser(mockUserId), completion(expectedUser));

      verifyInOrder([
        query.selectById(mockUserId),
        avatarService.getAvatarUrl(mockUserId),
      ]);
    },
  );

  test('given query throws when getUser called expect error', () async {
    when(
      mockQuery.selectById(any),
    ).thenAnswer((_) => Future.error(Exception("User not found")));

    await expectLater(source.getUser(mockUserId), throwsException);
    verify(query.selectById(mockUserId)).called(1);
  });

  test(
    'given avatar service throws when getUser called expect error',
    () async {
      when(
        mockQuery.selectById(mockUserId),
      ).thenAnswer((_) => Future.value(mockUser));
      when(
        mockAvatar.getAvatarUrl(mockUserId),
      ).thenAnswer((_) => Future.error(Exception("Fetch avatar failure")));

      await expectLater(source.getUser(mockUserId), throwsException);
      verifyInOrder([
        query.selectById(mockUserId),
        avatarService.getAvatarUrl(mockUserId),
      ]);
    },
  );

  test(
    'given imageBytes provided when uploadAvatar called expect avatar uploaded',
    () async {
      when(
        mockAvatar.uploadAvatar(mockUserId, any),
      ).thenAnswer((_) => Future.value());

      final fakeImageBytes = Uint8List(1);
      await expectLater(
        source.uploadAvatar(userId: mockUserId, imageBytes: fakeImageBytes),
        completes,
      );
      verify(avatarService.uploadAvatar(mockUserId, fakeImageBytes)).called(1);
    },
  );

  test(
    'given imageBytes is null when uploadAvatar called expect avatar deleted',
    () async {
      when(
        mockAvatar.deleteAvatar(mockUserId),
      ).thenAnswer((_) => Future.value());

      await expectLater(source.uploadAvatar(userId: mockUserId), completes);
      verify(avatarService.deleteAvatar(mockUserId)).called(1);
    },
  );

  test(
    'given invalid imageBytes provided when uploadAvatar called expect error',
    () async {
      when(
        mockAvatar.uploadAvatar(any, any),
      ).thenAnswer((_) => Future.error(Exception("Invalid image")));

      final invalidImageBytes = Uint8List(2);
      await expectLater(
        source.uploadAvatar(userId: mockUserId, imageBytes: invalidImageBytes),
        throwsException,
      );
      verify(
        avatarService.uploadAvatar(mockUserId, invalidImageBytes),
      ).called(1);
    },
  );

  test(
    'given valid userName when updateUser called expect user data updated in query',
    () async {
      when(
        mockQuery.updateById(mockUserId, updateData: anyNamed('updateData')),
      ).thenAnswer((_) => Future.value());

      final newName = "Test Person";
      await expectLater(
        source.updateUser(userId: mockUserId, userName: newName),
        completes,
      );
      verify(
        query.updateById(
          mockUserId,
          updateData: <String, dynamic>{'user_name': newName},
        ),
      ).called(1);
    },
  );

  test(
    'given userName is null when updateUser called expect ArgumentError thrown',
    () async {
      await expectLater(
        source.updateUser(userId: mockUserId),
        throwsA(isA<ArgumentError>()),
      );
    },
  );

  test(
    'given query throws when updateUser called expect error rethrown',
    () async {
      when(
        mockQuery.updateById(any, updateData: anyNamed('updateData')),
      ).thenAnswer((_) => Future.error(Exception("Update failure")));

      final newName = "Some User";
      await expectLater(
        source.updateUser(userId: mockUserId, userName: newName),
        throwsException,
      );
      verify(
        query.updateById(
          mockUserId,
          updateData: <String, dynamic>{'user_name': newName},
        ),
      ).called(1);
    },
  );
}
