import 'dart:typed_data';

abstract class TableQuery<T> {
  Future<T> selectById(String id);
  Future<void> updateById(
    String id, {
    required Map<String, dynamic> updateData,
  });
  Future<void> deleteById(String id);
}

abstract class StorageQuery {
  Future<String> createUrl(String filePath, int expiresIn);
  Future<String> upload(String filePath, Uint8List bytes);
  Future<void> delete(String filePath);
}

abstract class AuthQuery {
  String? get currentUserId;
  Stream<String?> get currentUserIdStream;

  Future<String> signIn({required String email, required String password});
  Future<String> signUp({required String email, required String password});
  Future<void> signOut();
}
