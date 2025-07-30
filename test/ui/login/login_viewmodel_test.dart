import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/ui/login/login_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mocks.mocks.dart';

void main() {
  late MockAuthService mockAuth;
  late MockLoggerService mockLogger;
  late LoginViewModel viewModel;

  setUp(() {
    mockAuth = MockAuthService();
    mockLogger = MockLoggerService();

    LoggerAccess.overrideLogger(mockLogger);
    viewModel = LoginViewModel(auth: mockAuth);
  });

  test(
    'given valid credentials when login is successful expect error is null',
    () async {
      final fakeUser = User(id: "123", email: "test@example.com");

      when(
        mockAuth.signIn(
          email: anyNamed("email"),
          password: anyNamed("password"),
        ),
      ).thenAnswer((_) async {
        return fakeUser;
      });

      await viewModel.login(email: "test@example.com", password: "123456");

      expect(viewModel.error, isNull);
    },
  );

  test('given valid credentials when login failure expect error', () async {
    when(
      mockAuth.signIn(email: anyNamed("email"), password: anyNamed("password")),
    ).thenThrow(Exception("Invalid login credentials"));

    await viewModel.login(email: "wrong@incorrect.no", password: "654321");

    expect(viewModel.error, isNotNull);
    expect(
      viewModel.error,
      contains("Login failed: Invalid login credentials"),
    );
  });
}
