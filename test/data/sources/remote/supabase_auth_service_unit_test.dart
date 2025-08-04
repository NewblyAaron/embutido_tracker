import 'dart:async';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_auth_service.dart';
import 'package:embutido_tracker/domain/sources/query_interfaces.dart';
import 'package:embutido_tracker/domain/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/query_mocks.mocks.dart';
import '../../../mocks/service_mocks.mocks.dart';
import '../../../mocks/test_helpers.dart';

late AuthQuery query;
late AuthService auth;
late StreamController<String?> authStreamController;

MockAuthQuery get mockQuery => query as MockAuthQuery;

void main() {
  setUp(() {
    authStreamController = StreamController<String?>();
    query = MockAuthQuery();

    when(
      mockQuery.currentUserIdStream,
    ).thenAnswer((_) => authStreamController.stream);

    auth = SupabaseAuthService(query);

    LoggerAccess.init(loggerService: MockLoggerService());
  });

  tearDown(() {
    authStreamController.close();
  });

  test(
    'given userId from query when getting currentUserId expect same value',
    () async {
      when(mockQuery.currentUserId).thenAnswer((_) => mockUserId);

      expect(auth.currentUserId, equals(mockUserId));
      verify(query.currentUserId).called(1);
    },
  );

  test(
    'given userId stream from query when listening to currentUserIdStream expect same values emitted',
    () async {
      final expectStreamEmitsUserId = expectLater(
        auth.currentUserIdStream,
        emits(mockUserId),
      );

      // simulate log in
      Future.microtask(() => authStreamController.add(mockUserId));

      await expectStreamEmitsUserId;
      verify(query.currentUserIdStream).called(1);
    },
  );

  test(
    'given valid credentials when signIn expect query.signIn called',
    () async {
      when(
        mockQuery.signIn(email: mockUserEmail, password: mockUserPassword),
      ).thenAnswer((_) => Future.value(mockUserId));

      await expectLater(
        auth.signIn(email: mockUserEmail, password: mockUserPassword),
        completes,
      );
      verify(
        query.signIn(email: mockUserEmail, password: mockUserPassword),
      ).called(1);
    },
  );

  test(
    'given query.signIn throws when signIn expect exception thrown',
    () async {
      when(
        mockQuery.signIn(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) => Future.error(Exception("Sign-in error")));

      await expectLater(
        auth.signIn(email: mockUserEmail, password: mockUserPassword),
        throwsException,
      );
      verify(
        query.signIn(email: mockUserEmail, password: mockUserPassword),
      ).called(1);
    },
  );

  test(
    'given valid credentials when signUp expect query.signUp called',
    () async {
      when(
        mockQuery.signUp(email: mockUserEmail, password: mockUserPassword),
      ).thenAnswer((_) => Future.value(mockUserId));

      await expectLater(
        auth.signUp(email: mockUserEmail, password: mockUserPassword),
        completes,
      );
      verify(
        query.signUp(email: mockUserEmail, password: mockUserPassword),
      ).called(1);
    },
  );

  test(
    'given query.signUp throws when signUp expect exception thrown',
    () async {
      when(
        mockQuery.signUp(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) => Future.error(Exception("Sign-up error")));

      await expectLater(
        auth.signUp(email: mockUserEmail, password: mockUserPassword),
        throwsException,
      );
      verify(
        query.signUp(email: mockUserEmail, password: mockUserPassword),
      ).called(1);
    },
  );

  test('when signOut expect query.signOut called', () async {
    when(mockQuery.signOut()).thenAnswer((_) => Future.value());

    await expectLater(auth.signOut(), completes);
    verify(query.signOut()).called(1);
  });

  test(
    'given query.signOut throws when signOut expect exception thrown',
    () async {
      when(
        mockQuery.signOut(),
      ).thenAnswer((_) => Future.error(Exception("Sign-out error")));

      await expectLater(auth.signOut(), throwsException);
      verify(query.signOut()).called(1);
    },
  );
}
