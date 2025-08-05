// ignore_for_file: unused_field

import 'dart:async';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/entity/position.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/services/gps_service.dart';
import 'package:embutido_tracker/domain/services/permission_service.dart';
import 'package:flutter/material.dart';

class MapViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final GPSService _gpsService;
  final PermissionService _permissionService;

  Stream<Position>? _positionStream;
  final _errorController = StreamController<String>();

  Stream<String> get errorStream => _errorController.stream;

  MapViewModel(this._userRepository, this._gpsService, this._permissionService);

  Stream<Position> get currentLocationStream {
    if (_positionStream == null) return Stream.empty();
    return _positionStream!.asyncMap((position) async {
      LoggerAccess.logger.debug("Location update:\n$position");

      return position;
    });
  }

  Future<void> initialize() async {
    final hasPerms = await _ensureLocationPermission();
    if (!hasPerms) {
      _errorController.add("Location permission denied");
      return;
    }

    _positionStream = _gpsService.currentPositionStream;
    notifyListeners();
  }

  Future<bool> _ensureLocationPermission() async {
    final status = await _permissionService.check(AppPermission.location);
    if (status == PermissionStatus.granted) return true;

    final result = await _permissionService.request(AppPermission.location);
    if (result == PermissionStatus.granted) return true;

    return false;
  }
}
