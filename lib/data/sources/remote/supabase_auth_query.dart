import 'package:embutido_tracker/domain/sources/query_interfaces.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthQueryImpl implements AuthQuery {
  final GoTrueClient _client;

  SupabaseAuthQueryImpl(SupabaseClient client) : _client = client.auth;

  @override
  String? get currentUserId => _client.currentUser?.id;

  @override
  Stream<String?> get currentUserIdStream =>
      _client.onAuthStateChange.map((event) => event.session?.user.id);

  @override
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

  @override
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

  @override
  Future<void> signOut() async => await _client.signOut();
}
