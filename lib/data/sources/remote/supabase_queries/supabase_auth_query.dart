import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthQuery {
  final GoTrueClient _client;

  SupabaseAuthQuery(SupabaseClient client) : _client = client.auth;

  String? get currentUserId => _client.currentUser?.id;

  Stream<String?> get currentUserIdStream =>
      _client.onAuthStateChange.map((event) => event.session?.user.id);

  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null || response.user == null) {
        throw AuthException("No session/user returned");
      }

      final userId = response.user!.id;
      return userId;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.signUp(email: email, password: password);

      if (response.session == null || response.user == null) {
        throw AuthException("No session/user returned");
      }

      final userId = response.user!.id;
      return userId;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<void> signOut() async => await _client.signOut();
}
