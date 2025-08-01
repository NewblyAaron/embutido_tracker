import 'dart:async';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/service_mocks.mocks.dart';

void main() {
  late StreamController<String?> authStreamController;
  late MockAuthService mockAuth;
  late MockLoggerService mockLogger;

  setUp(() {
    authStreamController = StreamController<String?>.broadcast();
    mockAuth = MockAuthService();
    mockLogger = MockLoggerService();

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
      final fakeUserId = "123";

      when(
        mockAuth.signIn(
          email: anyNamed("email"),
          password: anyNamed("password"),
        ),
      ).thenAnswer((_) async {
        authStreamController.add(fakeUserId);
      });

      final emitted = <String?>[];
      mockAuth.currentUserIdStream.listen(emitted.add);

      await mockAuth.signIn(email: 'test@example.com', password: '123456');
      await Future.delayed(Duration.zero);

      verify(mockAuth.signIn(email: 'test@example.com', password: '123456'));
      expect(emitted, [fakeUserId]);
    },
  );

  test('given invalid credentials when login is called expect throw', () async {
    when(
      mockAuth.signIn(email: anyNamed("email"), password: anyNamed("password")),
    ).thenThrow(Exception("Invalid credentials"));

    await expectLater(
      () => mockAuth.signIn(email: 'wrong@incorrect.no', password: '654321'),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'given valid credentials when signup is called expect authstate emit user',
    () async {
      final fakeUserId = "123";

      when(
        mockAuth.signUp(
          email: anyNamed("email"),
          password: anyNamed("password"),
        ),
      ).thenAnswer((_) {
        authStreamController.add(fakeUserId);
        return Future.value();
      });

      final emitted = <String?>[];
      mockAuth.currentUserIdStream.listen(emitted.add);

      await mockAuth.signUp(email: 'test@example.com', password: '123456');
      await Future.delayed(Duration.zero);

      verify(mockAuth.signUp(email: 'test@example.com', password: '123456'));
      expect(emitted, [fakeUserId]);
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
      final fakeUserId = "123";

      when(mockAuth.signOut()).thenAnswer((_) async {
        authStreamController.add(null);
      });

      final emitted = <String?>[];
      mockAuth.currentUserIdStream.listen(emitted.add);

      // simulate login
      authStreamController.add(fakeUserId);
      await Future.delayed(Duration.zero);

      // signout
      await mockAuth.signOut();
      await Future.delayed(Duration.zero);

      verify(mockAuth.signOut());
      expect(emitted, [fakeUserId, null]);
    },
  );
}
