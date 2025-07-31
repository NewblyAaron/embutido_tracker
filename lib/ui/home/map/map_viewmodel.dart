import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class MapViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  MapViewModel(this._userRepository);
}
