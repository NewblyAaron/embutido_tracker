import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAvatarQuery {
  final SupabaseStorageClient _client;

  SupabaseAvatarQuery(this._client);

  Future<String> createUrl(String filePath, int expiresIn) =>
      _client.from('avatars').createSignedUrl(filePath, expiresIn);

  Future<String> upload(String filePath, Uint8List bytes) => _client
      .from('avatars')
      .uploadBinary(filePath, bytes, fileOptions: FileOptions(upsert: true));

  Future<void> delete(String filePath) async {
    final result = await _client.from('avatars').remove([filePath]);

    if (result.isEmpty) {
      throw Exception("Nothing was deleted");
    }
  }
}
