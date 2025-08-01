import 'dart:typed_data';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageSource {
  final SupabaseStorageClient _client;

  SupabaseStorageSource(SupabaseClient client) : _client = client.storage;

  String _filePath(String userId) => "$userId/avatar.png";
  final Duration fileExpiry = const Duration(hours: 1);

  Future<String> generateAvatarUrl(String userId) async {
    LoggerAccess.logger.debug("Generating new signed URL for $userId");
    final url = await _client
        .from('avatars')
        .createSignedUrl(_filePath(userId), fileExpiry.inSeconds);

    LoggerAccess.logger.debug("Generated.\nURL: $url");
    return url;
  }

  Future<String> uploadAvatar({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    LoggerAccess.logger.debug("Uploading avatar...");
    final response = await _client
        .from('avatars')
        .uploadBinary(
          _filePath(userId),
          imageBytes,
          fileOptions: FileOptions(upsert: true),
        );

    if (response.isEmpty) {
      throw Exception("Upload failed");
    }

    final url = await _client
        .from('avatars')
        .createSignedUrl(_filePath(userId), fileExpiry.inSeconds);

    LoggerAccess.logger.debug(
      "Upload complete.\nPath: $response\nSigned URL: $url",
    );
    return url;
  }

  Future<void> deleteAvatar(String userId) {
    // TODO: deleteAvatar
    throw UnimplementedError();
  }
}
