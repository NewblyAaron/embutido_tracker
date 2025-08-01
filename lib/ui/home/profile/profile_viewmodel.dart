import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _repository;
  final AuthService _auth;

  String? _error;
  String? get error => _error;

  bool isUploading = false;

  ProfileViewModel(this._repository, this._auth);

  Future<void> signOut() async => await _auth.signOut();

  Future<void> updateUsername(String userName) async {
    LoggerAccess.logger.debug("Updating username");

    try {
      await _repository.updateUsername(userName);
    } catch (e) {
      _error =
          "Updating username failed: ${e.toString().replaceFirst("Exception: ", "")}";
      LoggerAccess.logger.error("Error in updating username: $_error");
      notifyListeners();
    }
  }

  Future<void> updateAvatar(Uint8List imageBytes) async {
    try {
      isUploading = true;
      notifyListeners();

      await _repository.uploadAvatar(imageBytes);
    } catch (e) {
      _error =
          "Updating avatar failed: ${e.toString().replaceFirst("Exception: ", "")}";
      LoggerAccess.logger.error("Error in updating avatar: $_error");
      notifyListeners();
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }
}
