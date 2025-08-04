import 'dart:typed_data';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_storage_source.dart';
import 'package:embutido_tracker/domain/sources/query_interfaces.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/query_mocks.mocks.dart';
import '../../../mocks/service_mocks.mocks.dart';

late StorageQuery query;
late SupabaseStorageSource source;

MockStorageQuery get mockQuery => query as MockStorageQuery;

void main() {
  const url = "https://www.example.com/uploadedFile";
  const filePath = 'fake-files/fake-file.txt';

  setUp(() {
    query = MockStorageQuery();
    source = SupabaseStorageSource(query);

    LoggerAccess.init(loggerService: MockLoggerService());
  });

  test('given valid input when generating URL expect URL returned', () async {
    when(
      mockQuery.createUrl(filePath, source.fileExpiry.inSeconds),
    ).thenAnswer((_) => Future.value(url));

    await expectLater(source.generateUrl(filePath), completion(url));
    verify(query.createUrl(filePath, source.fileExpiry.inSeconds)).called(1);
  });

  test(
    'given custom expiry when generating URL expect expiry respected',
    () async {
      final fileExpiry = const Duration(minutes: 5);

      when(
        mockQuery.createUrl(filePath, any),
      ).thenAnswer((_) => Future.value(url));

      await expectLater(
        source.generateUrl(filePath, fileExpiry: fileExpiry),
        completion(url),
      );
      verify(query.createUrl(filePath, fileExpiry.inSeconds)).called(1);
    },
  );

  test(
    'given error from query when generating URL expect exception thrown',
    () async {
      when(
        mockQuery.createUrl(any, any),
      ).thenAnswer((_) => Future.error(Exception("URL creation failed")));

      await expectLater(source.generateUrl(filePath), throwsException);
      verify(query.createUrl(filePath, source.fileExpiry.inSeconds)).called(1);
    },
  );

  test(
    'given valid input when uploading file expect upload path returned',
    () async {
      final fakeBytes = Uint8List(1);

      when(
        mockQuery.upload(filePath, fakeBytes),
      ).thenAnswer((_) => Future.value(filePath));

      await expectLater(
        source.upload(filePath, bytes: fakeBytes),
        completion(filePath),
      );
      verify(query.upload(filePath, fakeBytes)).called(1);
    },
  );

  test(
    'given empty response from query when uploading file expect exception thrown',
    () async {
      final fakeBytes = Uint8List(1);

      when(
        mockQuery.upload(filePath, fakeBytes),
      ).thenAnswer((_) => Future.value(""));

      await expectLater(
        source.upload(filePath, bytes: fakeBytes),
        throwsException,
      );
      verify(query.upload(filePath, fakeBytes)).called(1);
    },
  );

  test(
    'given error from query when uploading file expect exception thrown',
    () async {
      final fakeBytes = Uint8List(1);

      when(
        mockQuery.upload(filePath, fakeBytes),
      ).thenAnswer((_) => Future.error(Exception("Connection failure")));

      await expectLater(
        source.upload(filePath, bytes: fakeBytes),
        throwsException,
      );
      verify(query.upload(filePath, fakeBytes)).called(1);
    },
  );

  test(
    'given valid input when deleting file expect delete called on query',
    () async {
      when(mockQuery.delete(filePath)).thenAnswer((_) => Future.value());

      await expectLater(source.delete(filePath), completes);
      verify(query.delete(filePath)).called(1);
    },
  );

  test(
    'given error from query when deleting file expect exception thrown',
    () async {
      when(
        mockQuery.delete(filePath),
      ).thenAnswer((_) => Future.error(Exception("Permission denied")));

      await expectLater(source.delete(filePath), throwsException);
      verify(query.delete(filePath)).called(1);
    },
  );
}
