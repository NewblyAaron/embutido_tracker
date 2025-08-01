import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/sources/auth_source.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _auth;

  String? _error;
  String? get error => _error;

  LoginViewModel({required AuthService auth}) : _auth = auth;

  Future<void> login({required String email, required String password}) async {
    LoggerAccess.logger.debug("Logging in");

    _error = null;
    notifyListeners();

    try {
      await _auth.signIn(email: email, password: password);
      LoggerAccess.logger.debug("Successfully logged in");
    } catch (e) {
      _error = "Login failed: ${e.toString().replaceFirst("Exception: ", "")}";
      LoggerAccess.logger.error(_error!);
      notifyListeners();
    }
  }
}
