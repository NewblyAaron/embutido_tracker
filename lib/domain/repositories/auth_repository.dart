import 'package:embutido_tracker/domain/entity/user.dart';

abstract class AuthService {
  Stream<User?> get onAuthStateChanged;
  
  Future<User?> signIn({required String email, required String password});
  Future<User?> signUp({required String email, required String password});
  Future<void> signOut();
}