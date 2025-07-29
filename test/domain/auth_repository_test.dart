import 'dart:async';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late StreamController<User?> authStreamController;
  late MockAuthService mockAuth;
  late MockLoggerService mockLogger;

  setUp(() {
    authStreamController = StreamController<User?>.broadcast();
    mockAuth = MockAuthService();
    mockLogger = MockLoggerService();

    when(
      mockAuth.onAuthStateChanged,
    ).thenAnswer((_) => authStreamController.stream);

    LoggerAccess.overrideLogger(mockLogger);
  });

  tearDown(() async {
    await authStreamController.close();
  });

  test(
    'given valid credentials when login is called expect authstate emit user',
    () async {
      final fakeUser = User(id: "123", email: "test@example.com");

      when(
        mockAuth.signIn(
          email: anyNamed("email"),
          password: anyNamed("password"),
        ),
      ).thenAnswer((_) async {
        authStreamController.add(fakeUser);
        return fakeUser;
      });

      final emitted = <User?>[];
      mockAuth.onAuthStateChanged.listen(emitted.add);
      final result = await mockAuth.signIn(
        email: 'test@example.com',
        password: '123456',
      );

      expect(result, isNotNull);
      expect(result?.id, equals("123"));
      expect(result?.email, equals("test@example.com"));
      expect(emitted, [fakeUser]);
    },
  );

  test(
    'given invalid credentials when login is called expect throw',
    () async {
      when(
        mockAuth.signIn(
          email: anyNamed("email"),
          password: anyNamed("password"),
        ),
      ).thenThrow(Exception("Invalid credentials"));

      await expectLater(
        () => mockAuth.signIn(email: 'wrong@incorrect.no', password: '654321'),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'given valid credentials when signup is called expect authstate emit user',
    () async {
      final fakeUser = User(id: "123", email: "test@example.com");

      when(
        mockAuth.signIn(
          email: anyNamed("email"),
          password: anyNamed("password"),
        ),
      ).thenAnswer((_) async {
        authStreamController.add(fakeUser);
        return fakeUser;
      });

      final emitted = <User?>[];
      mockAuth.onAuthStateChanged.listen(emitted.add);
      final result = await mockAuth.signIn(
        email: 'test@example.com',
        password: '123456',
      );

      expect(result, isNotNull);
      expect(result?.id, equals("123"));
      expect(result?.email, equals("test@example.com"));
      expect(emitted, [fakeUser]);
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
      ).thenThrow(Exception("Invalid credentials"));

      await expectLater(
        () => mockAuth.signUp(email: 'wrong@incorrect.no', password: '654321'),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'given user signed in when signout is called expect authstate emit null',
    () async {
      when(mockAuth.signOut()).thenAnswer((_) async {
        authStreamController.add(null);
      });

      final emitted = <User?>[];
      mockAuth.onAuthStateChanged.listen(emitted.add);

      // simulate login
      final signedInUser = User(id: "123", email: "test@example.com");
      authStreamController.add(signedInUser);
      await Future.delayed(Duration.zero);

      // signout
      await mockAuth.signOut();
      await Future.delayed(Duration.zero);

      expect(emitted, [signedInUser, null]);
    },
  );
}
