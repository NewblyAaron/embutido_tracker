import 'dart:typed_data';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_avatar_service.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_storage_source.dart';
import 'package:embutido_tracker/domain/services/avatar_cache_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/cache_mocks.mocks.dart';
import '../../../mocks/service_mocks.mocks.dart';
import '../../../mocks/supabase_mocks.mocks.dart';
import '../../../mocks/test_helpers.dart';

late SupabaseStorageSource source;
late BaseCacheManager cache;
late AvatarService service;
final Map<String, CachedUrl> cacheMap = {};

MockSupabaseStorageSource get mockSource => source as MockSupabaseStorageSource;
MockBaseCacheManager get mockCache => cache as MockBaseCacheManager;

void main() {
  setUp(() {
    source = MockSupabaseStorageSource();
    cache = MockBaseCacheManager();
    service = SupabaseAvatarService(source, cache, cacheMap);

    when(mockSource.fileExpiry).thenAnswer((_) => const Duration(seconds: 10));

    LoggerAccess.init(loggerService: MockLoggerService());
  });

  tearDown(() {
    cacheMap.clear();
    (service as SupabaseAvatarService).dispose();
  });

  test(
    'given cached URL not expired and file exists when getting avatar URL expect cached URL returned',
    () async {
      final url = "https://example.com/avatar.png";
      cacheMap[mockUserId] = CachedUrl(
        url,
        DateTime.now().add(source.fileExpiry),
      );

      // Mock cached file info
      when(
        mockCache.getFileFromCache(url),
      ).thenAnswer((_) async => MockFileInfo());

      // Should use cache
      await expectLater(service.getAvatarUrl(mockUserId), completion(url));
      verifyNever(mockSource.generateUrl(any));
      verify(mockCache.getFileFromCache(url)).called(1);
    },
  );

  test(
    'given cached URL not expired but file missing when getting avatar URL expect new URL generated',
    () async {
      final oldUrl = "https://example.com/avatar.png";
      final newUrl = "https://example.com/new_avatar.png";
      cacheMap[mockUserId] = CachedUrl(
        oldUrl,
        DateTime.now().add(source.fileExpiry),
      );

      when(mockSource.generateUrl(any)).thenAnswer((_) async => newUrl);
      when(mockCache.getFileFromCache(oldUrl)).thenAnswer((_) async => null);
      when(
        mockCache.downloadFile(newUrl),
      ).thenAnswer((_) async => MockFileInfo());

      // Should generate new URL
      await expectLater(service.getAvatarUrl(mockUserId), completion(newUrl));
      verifyInOrder([
        cache.getFileFromCache(oldUrl),
        mockSource.generateUrl(any),
        cache.downloadFile(newUrl),
      ]);
    },
  );

  test(
    'given cached URL expired when getting avatar URL expect new URL generated',
    () async {
      final oldUrl = "https://example.com/avatar.png";
      final newUrl = "https://example.com/new_avatar.png";
      cacheMap[mockUserId] = CachedUrl(
        oldUrl,
        DateTime.now().subtract(source.fileExpiry),
      );

      when(mockSource.generateUrl(any)).thenAnswer((_) async => newUrl);
      when(
        mockCache.downloadFile(newUrl),
      ).thenAnswer((_) async => MockFileInfo());

      // Should generate new URL
      await expectLater(service.getAvatarUrl(mockUserId), completion(newUrl));
      verifyInOrder([mockSource.generateUrl(any), cache.downloadFile(newUrl)]);
    },
  );

  test(
    'given URL generation fails when getting avatar URL expect fallback to cached URL',
    () async {
      final url = "https://example.com/avatar.png";
      cacheMap[mockUserId] = CachedUrl(
        url,
        DateTime.now().subtract(source.fileExpiry),
      );

      when(
        mockSource.generateUrl(any),
      ).thenAnswer((_) async => Future.error(Exception("Network error")));

      // Should use cache, even if it's expired
      await expectLater(service.getAvatarUrl(mockUserId), completion(url));
      verify(mockSource.generateUrl(any));
    },
  );

  test(
    'given URL generation fails and no cache when getting avatar URL expect null',
    () async {
      when(
        mockSource.generateUrl(any),
      ).thenAnswer((_) async => Future.error(Exception("Network error")));

      // Should use cache, even if it's expired
      await expectLater(service.getAvatarUrl(mockUserId), completion(null));
      verify(mockSource.generateUrl(any));
    },
  );

  test(
    'given image uploaded when uploading avatar expect cache invalidated',
    () async {
      final url = "https://example.com/avatar.png";
      final cachedUrl = CachedUrl(url, DateTime.now().add(source.fileExpiry));
      cacheMap[mockUserId] = cachedUrl;

      final uploadedFilePath = "fake/file/path/avatar.png";
      when(
        mockSource.upload(any, bytes: anyNamed('bytes')),
      ).thenAnswer((_) async => uploadedFilePath);
      when(mockCache.removeFile(any)).thenAnswer((_) async => Future.value());

      final fakeImageBytes = Uint8List(1);
      await expectLater(
        service.uploadAvatar(mockUserId, fakeImageBytes),
        completes,
      );
      verifyInOrder([
        mockSource.upload(any, bytes: fakeImageBytes),
        cache.removeFile(url),
      ]);
      expect(cacheMap, isNot(contains(cachedUrl)));
    },
  );

  test(
    'given user ID when deleting avatar expect storage delete called and cache invalidated',
    () async {
      final url = "https://example.com/avatar.png";
      final cachedUrl = CachedUrl(url, DateTime.now().add(source.fileExpiry));
      cacheMap[mockUserId] = cachedUrl;

      when(mockSource.delete(any)).thenAnswer((_) async => Future.value());
      when(mockCache.removeFile(any)).thenAnswer((_) async => Future.value());

      await expectLater(service.deleteAvatar(mockUserId), completes);
      verifyInOrder([mockSource.delete(any), cache.removeFile(url)]);
      expect(cacheMap, isNot(contains(cachedUrl)));
    },
  );

  test(
    'given cached entries exist when disposing service expect all cache invalidated',
    () {
      final url = "https://example.com/avatar.png";
      final cachedUrl = CachedUrl(url, DateTime.now().add(source.fileExpiry));
      cacheMap[mockUserId] = cachedUrl;

      when(mockCache.emptyCache()).thenAnswer((_) async => Future.value());

      (service as SupabaseAvatarService).dispose();
      verify(mockCache.emptyCache()).called(1);
      expect(cacheMap, isEmpty);
    },
  );
}
