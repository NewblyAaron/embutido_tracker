import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/sources/auth_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseAuthSource implements AuthService {
  final SupabaseClient _client;

  SupabaseAuthSource(this._client);

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Stream<String?> get currentUserIdStream =>
      _client.auth.onAuthStateChange.map((event) => event.session?.user.id);

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null || response.user == null) {
        throw AuthException("No session/user returned");
      }
    } on AuthException catch (e) {
      LoggerAccess.logger.error("Auth failed: ${e.message}");
      throw Exception(e.message);
    } catch (e) {
      LoggerAccess.logger.error("Unknown login error: $e");
      throw Exception("Unexpected error: $e");
    }
  }

  @override
  Future<void> signOut() async => await _client.auth.signOut();

  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.session == null || response.user == null) {
        throw AuthException("No session/user returned");
      }
    } on AuthException catch (e) {
      LoggerAccess.logger.error("Auth failed: ${e.message}");
      throw Exception(e.message);
    } catch (e) {
      LoggerAccess.logger.error("Unknown signup error: $e");
      throw Exception("Unexpected error: $e");
    }
  }
}
