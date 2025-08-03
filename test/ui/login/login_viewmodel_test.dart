import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/services/auth_service.dart';
import 'package:embutido_tracker/ui/login/login_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/service_mocks.mocks.dart';

void main() {
  late AuthService mockAuth;
  late LoginViewModel viewModel;

  setUp(() {
    mockAuth = MockAuthService();

    LoggerAccess.init(loggerService: MockLoggerService());
    viewModel = LoginViewModel(auth: mockAuth);
  });

  test(
    'given valid credentials when login is successful expect error is null',
    () async {
      when(
        (mockAuth as MockAuthService).signIn(
          email: anyNamed("email"),
          password: anyNamed("password"),
        ),
      ).thenAnswer((_) async {
        // success
      });

      await viewModel.login(email: "test@example.com", password: "123456");

      expect(viewModel.error, isNull);
    },
  );

  test('given valid credentials when login failure expect error', () async {
    when(
      (mockAuth as MockAuthService).signIn(
        email: anyNamed("email"),
        password: anyNamed("password"),
      ),
    ).thenThrow(Exception("Invalid login credentials"));

    await viewModel.login(email: "wrong@incorrect.no", password: "654321");

    expect(viewModel.error, isNotNull);
    expect(
      viewModel.error,
      contains("Login failed: Invalid login credentials"),
    );
  });
}
