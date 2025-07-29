import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/data/mappers/user_mapper.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:embutido_tracker/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseAuthSource implements AuthService {
  final SupabaseClient _client;

  SupabaseAuthSource(this._client);

  @override
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null && response.user != null) {
        return User(id: response.user!.id, email: email);
      } else {
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
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.session != null && response.user != null) {
        return User(id: response.user!.id, email: email);
      } else {
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

  @override
  Stream<User?> get onAuthStateChanged => _client.auth.onAuthStateChange.map(
    (event) =>
        event.session != null
            ? mapSupabaseUserToDomain(event.session!.user)
            : null,
  );
}
