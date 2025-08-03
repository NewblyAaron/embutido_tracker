import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/services/auth_service.dart';
import 'package:embutido_tracker/ui/home/profile/profile_viewmodel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/repository_mocks.mocks.dart';
import '../../mocks/service_mocks.mocks.dart';

late AuthService auth;
late UserRepository repository;
late ProfileViewModel viewModel;

MockAuthService get mockAuth => auth as MockAuthService;
MockUserRepository get mockRepo => repository as MockUserRepository;

void main() {
  int notifyCount = 0;

  setUp(() {
    auth = MockAuthService();
    repository = MockUserRepository();
    viewModel = ProfileViewModel(repository, auth);

    viewModel.addListener(() => notifyCount++);

    LoggerAccess.init(loggerService: MockLoggerService());
  });

  tearDown(() {
    reset(mockAuth);
    reset(mockRepo);
    notifyCount = 0;
  });

  test(
    'given valid username when updateUsername is called expect repository updates and error is null',
    () async {
      when(mockRepo.updateUsername(any)).thenAnswer((_) => Future.value());

      final newName = "Test Person";
      await viewModel.updateUsername(newName);

      verify(repository.updateUsername(newName)).called(1);
      expect(viewModel.error, isNull);
      expect(notifyCount, equals(1));
    },
  );

  test(
    'given repository throws when updateUsername is called expect error is set',
    () async {
      const errorMessage = "New username too long";
      when(
        mockRepo.updateUsername(any),
      ).thenAnswer((_) => Future.error(Exception(errorMessage)));

      final newName = "A very long name.";
      await viewModel.updateUsername(newName);

      verify(repository.updateUsername(newName)).called(1);
      expect(viewModel.error, contains(errorMessage));
      expect(notifyCount, equals(2));
    },
  );

  test(
    'given valid imageBytes when updateAvatar is called expect repository uploads and isUploading is false on completion',
    () async {
      when(mockRepo.uploadAvatar(any)).thenAnswer((_) => Future.value());
      expect(viewModel.isUploading, isFalse);

      final imageBytes = Uint8List(1);
      final update = viewModel.updateAvatar(imageBytes);
      expectLater(viewModel.isUploading, isTrue);
      await update;

      verify(repository.uploadAvatar(imageBytes)).called(1);
      expect(viewModel.error, isNull);
      expect(notifyCount, equals(2));
      expect(viewModel.isUploading, isFalse);
    },
  );

  test(
    'given repository throws when updateAvatar is called expect error is set and isUploading is false on completion',
    () async {
      const errorMessage = "Invalid image";
      when(
        mockRepo.uploadAvatar(any),
      ).thenAnswer((_) => Future.error(Exception(errorMessage)));
      expect(viewModel.isUploading, isFalse);

      final invalidImageBytes = Uint8List(1);
      final update = viewModel.updateAvatar(invalidImageBytes);
      expectLater(viewModel.isUploading, isTrue);
      await update;

      verify(repository.uploadAvatar(invalidImageBytes)).called(1);
      expect(viewModel.error, contains(errorMessage));
      expect(notifyCount, equals(2));
      expect(viewModel.isUploading, isFalse);
    },
  );

  test(
    'given viewmodel when signOut is called expect auth signs out',
    () async {
      when(mockAuth.signOut()).thenAnswer((_) => Future.value());

      await viewModel.signOut();

      verify(auth.signOut()).called(1);
    },
  );

  test('deliberate failure', () {
    print("this test case will always fail");
    expect(true, equals(false));
  });
}
