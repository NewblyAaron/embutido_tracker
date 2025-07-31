abstract class AuthService {
  String? get currentUserId;
  Stream<String?> get currentUserIdStream;

  Future<void> signIn({required String email, required String password});
  Future<void> signUp({required String email, required String password});
  Future<void> signOut();
}
