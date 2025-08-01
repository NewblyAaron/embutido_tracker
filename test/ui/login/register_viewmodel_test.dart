import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/ui/login/register_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/service_mocks.mocks.dart';

void main() {
  late MockAuthService mockAuth;
  late MockLoggerService mockLogger;
  late RegisterViewModel viewModel;

  setUp(() {
    mockAuth = MockAuthService();

    LoggerAccess.init(loggerService: MockLoggerService());
    viewModel = RegisterViewModel(auth: mockAuth);
  });

  test(
    'given valid credentials when signup is successful expect error is null',
    () async {
      final fakeUserId = "123";

      when(
        mockAuth.signUp(
          email: anyNamed("email"),
          password: anyNamed("password"),
        ),
      ).thenAnswer((_) async {
        // success
      });

      await viewModel.signUp(email: "test@example.com", password: "123456");

      expect(viewModel.error, isNull);
    },
  );

  test('given invalid credentials when signup failure expect error', () async {
    when(
      mockAuth.signUp(email: anyNamed("email"), password: anyNamed("password")),
    ).thenThrow(Exception("Invalid signup credentials"));

    await viewModel.signUp(email: "wrong@incorrect.no", password: "654321");

    expect(viewModel.error, isNotNull);
    expect(
      viewModel.error,
      contains("Signup failed: Invalid signup credentials"),
    );
  });
}
