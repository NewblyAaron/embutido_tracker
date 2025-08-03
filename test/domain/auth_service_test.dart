import 'dart:async';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/service_mocks.mocks.dart';
import '../mocks/test_helpers.dart';

late StreamController<String?> authStreamController;
late AuthService auth;

MockAuthService get mockAuth => auth as MockAuthService;

void main() {
  setUp(() {
    authStreamController = StreamController<String?>.broadcast();
    auth = MockAuthService();

    when(
      mockAuth.currentUserIdStream,
    ).thenAnswer((_) => authStreamController.stream);

    LoggerAccess.init(loggerService: MockLoggerService());
  });

  tearDown(() async {
    await authStreamController.close();
  });

  test(
    'given valid credentials when login is called expect authstate emit user id',
    () async {
      when(
        mockAuth.signIn(
          email: anyNamed("email"),
          password: anyNamed("password"),
        ),
      ).thenAnswer((_) async {
        return Future.microtask(() => authStreamController.add(mockUserId));
      });

      final expectStreamEmitsUserId = expectLater(
        auth.currentUserIdStream,
        emits(mockUserId),
      );

      await auth.signIn(email: mockUserEmail, password: mockUserPassword);

      verify(auth.signIn(email: mockUserEmail, password: mockUserPassword));
      when(mockAuth.currentUserId).thenReturn(mockUserId);
      expect(auth.currentUserId, mockUserId);

      await expectStreamEmitsUserId;
    },
  );

  test('given invalid credentials when login is called expect throw', () async {
    when(
      mockAuth.signIn(email: anyNamed("email"), password: anyNamed("password")),
    ).thenAnswer((_) => Future.error(Exception("Invalid credentials")));

    await expectLater(
      auth.signIn(email: 'wrong@incorrect.no', password: '654321'),
      throwsException,
    );
  });

  test(
    'given valid credentials when signup is called expect authstate emit user id',
    () async {
      when(
        mockAuth.signUp(
          email: anyNamed("email"),
          password: anyNamed("password"),
        ),
      ).thenAnswer((_) {
        return Future.microtask(() => authStreamController.add(mockUserId));
      });

      final expectStreamEmitsUserId = expectLater(
        auth.currentUserIdStream,
        emits(mockUserId),
      );

      await auth.signUp(email: mockUserEmail, password: mockUserPassword);

      verify(auth.signUp(email: mockUserEmail, password: mockUserPassword));
      when(mockAuth.currentUserId).thenReturn(mockUserId);
      expect(auth.currentUserId, mockUserId);

      await expectStreamEmitsUserId;
    },
  );

  test(
    'given invalid credentials when signup is called expect throw',
    () async {
      when(
        mockAuth.signUp(
          email: anyNamed("email"),
          password: anyNamed("password"),
        ),
      ).thenAnswer((_) => Future.error(Exception("Invalid credentials")));

      await expectLater(
        () => auth.signUp(email: 'wrong@incorrect.no', password: '654321'),
        throwsException,
      );
    },
  );

  test(
    'given user signed in when signout is called expect authstate emit null',
    () async {
      when(mockAuth.signOut()).thenAnswer((_) async {
        return Future.microtask(() => authStreamController.add(null));
      });

      final expectStreamEmitsOrder = expectLater(
        auth.currentUserIdStream,
        emitsInOrder([mockUserId, null]),
      );

      // simulate login
      Future.microtask(() => authStreamController.add(mockUserId));

      // sign out
      await auth.signOut();

      verify(auth.signOut());
      when(mockAuth.currentUserId).thenReturn(null);
      expect(auth.currentUserId, null);

      await expectStreamEmitsOrder;
    },
  );
}
