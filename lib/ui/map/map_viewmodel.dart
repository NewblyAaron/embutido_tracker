import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class MapViewModel extends ChangeNotifier {
  final AuthService _auth;

  MapViewModel({required AuthService auth}) : _auth = auth;

  Future<void> signOut() async {
    LoggerAccess.logger.debug("Signing out");
    await _auth.signOut();
  }
}
