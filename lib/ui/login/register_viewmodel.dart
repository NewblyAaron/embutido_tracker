import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _auth;

  String? _error;
  String? get error => _error;

  RegisterViewModel({required AuthService auth}) : _auth = auth;

  Future<bool> signUp({required String email, required String password}) async {
    LoggerAccess.logger.debug("Signing up");

    _error = null;
    notifyListeners();

    try {
      final response = await _auth.signUp(email: email, password: password);

      if (response != null) {
        LoggerAccess.logger.debug("Successfully signed up");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _error = "Signup failed: ${e.toString().replaceFirst("Exception: ", "")}";
      LoggerAccess.logger.error(_error!);
      notifyListeners();
      return false;
    }
  }
}
