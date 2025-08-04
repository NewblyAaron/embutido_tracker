import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/sources/query_interfaces.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_auth_query.dart';
import 'package:embutido_tracker/domain/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseAuthService implements AuthService {
  final AuthQuery _query;

  SupabaseAuthService(this._query);

  SupabaseAuthService.fromClient(SupabaseClient client)
    : _query = SupabaseAuthQueryImpl(client);

  @override
  String? get currentUserId => _query.currentUserId;

  @override
  Stream<String?> get currentUserIdStream =>
      _query.currentUserIdStream.map((event) {
        LoggerAccess.logger.debug("Authenticated User ID changed: $event");
        return event;
      });

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      LoggerAccess.logger.debug("Trying to sign in");
      final userId = await _query.signIn(email: email, password: password);
      LoggerAccess.logger.debug("Signed in as $userId");
    } catch (e) {
      LoggerAccess.logger.debug("Sign-in error: $e");
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _query.signOut();
      LoggerAccess.logger.debug("Signed out");
    } catch (e) {
      LoggerAccess.logger.debug("Sign-out error: $e");
      rethrow;
    }
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      LoggerAccess.logger.debug("Trying to sign up");
      final userId = await _query.signUp(email: email, password: password);
      LoggerAccess.logger.debug("Signed up and authenticated as $userId");
    } catch (e) {
      LoggerAccess.logger.debug("Sign-up error: $e");
      rethrow;
    }
  }
}
