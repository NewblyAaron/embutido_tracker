import 'dart:typed_data';
import 'package:embutido_tracker/domain/sources/query_interfaces.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAvatarStorageQuery implements StorageQuery {
  final SupabaseStorageClient _client;

  SupabaseAvatarStorageQuery(this._client);

  @override
  Future<String> createUrl(String filePath, int expiresIn) =>
      _client.from('avatars').createSignedUrl(filePath, expiresIn);

  @override
  Future<String> upload(String filePath, Uint8List bytes) => _client
      .from('avatars')
      .uploadBinary(filePath, bytes, fileOptions: FileOptions(upsert: true));

  @override
  Future<void> delete(String filePath) async {
    final result = await _client.from('avatars').remove([filePath]);

    if (result.isEmpty) {
      throw Exception("Nothing was deleted");
    }
  }
}
