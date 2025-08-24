import 'dart:typed_data';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_queries/supabase_avatar_query.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageSource {
  final SupabaseAvatarQuery _query;

  SupabaseStorageSource(SupabaseClient client)
    : _query = SupabaseAvatarQuery(client.storage);

  final Duration fileExpiry = const Duration(hours: 1);

  Future<String> generateUrl(String filePath, {Duration? fileExpiry}) async {
    try {
      LoggerAccess.logger.debug("Generating new signed URL for $filePath");

      final url = await _query.createUrl(
        filePath,
        fileExpiry?.inSeconds ?? this.fileExpiry.inSeconds,
      );

      LoggerAccess.logger.debug("Generated.\nURL: $url");
      return url;
    } catch (e) {
      LoggerAccess.logger.error("URL generation failure: $e");
      rethrow;
    }
  }

  Future<String> upload(String filePath, {required Uint8List bytes}) async {
    try {
      LoggerAccess.logger.debug("Uploading file...");
      final response = await _query.upload(filePath, bytes);

      if (response.isEmpty) {
        throw Exception("Nothing was uploaded");
      }

      LoggerAccess.logger.debug("Upload complete.\nPath: $response");
      return response;
    } catch (e) {
      LoggerAccess.logger.error("Upload failure: $e");
      rethrow;
    }
  }

  Future<void> delete(String filePath) async {
    try {
      LoggerAccess.logger.debug("Deleting file...");
      await _query.delete(filePath);
      LoggerAccess.logger.debug("Deleted file.");
    } catch (e) {
      LoggerAccess.logger.error("Deletion failure: $e");
      rethrow;
    }
  }
}
