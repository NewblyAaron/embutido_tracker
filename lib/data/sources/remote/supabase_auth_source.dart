import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/sources/auth_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseAuthSource implements AuthService {
  final GoTrueClient _client;

  SupabaseAuthSource(SupabaseClient client) : _client = client.auth;

  @override
  String? get currentUserId => _client.currentUser?.id;

  @override
  Stream<String?> get currentUserIdStream =>
      _client.onAuthStateChange.map((event) {
        final userId = event.session?.user.id;
        LoggerAccess.logger.debug("AuthState changed, new ID: $userId");
        return userId;
      });

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await _client.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null || response.user == null) {
        throw AuthException("No session/user returned");
      }

      LoggerAccess.logger.debug("Logged in! ${response.user!.id}");
    } on AuthException catch (e) {
      LoggerAccess.logger.error("Auth failed: ${e.message}");
      throw Exception(e.message);
    } catch (e) {
      LoggerAccess.logger.error("Unknown login error: $e");
      throw Exception("Unexpected error: $e");
    }
  }

  @override
  Future<void> signOut() async => await _client.signOut();

  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      final response = await _client.signUp(email: email, password: password);

      if (response.session == null || response.user == null) {
        throw AuthException("No session/user returned");
      }

      LoggerAccess.logger.debug("Registered! ${response.user!.id}");
    } on AuthException catch (e) {
      LoggerAccess.logger.error("Auth failed: ${e.message}");
      throw Exception(e.message);
    } catch (e) {
      LoggerAccess.logger.error("Unknown signup error: $e");
      throw Exception("Unexpected error: $e");
    }
  }
}
