// ignore_for_file: unused_field

import 'dart:async';

import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/entity/group.dart';
import 'package:embutido_tracker/domain/entity/position.dart';
import 'package:embutido_tracker/domain/entity/user_location.dart';
import 'package:embutido_tracker/domain/repositories/group_repository.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/services/gps_service.dart';
import 'package:embutido_tracker/domain/services/permission_service.dart';
import 'package:embutido_tracker/domain/services/user_location_service.dart';
import 'package:flutter/material.dart';

class MapViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final GroupRepository _groupRepository;
  final GPSService _gpsService;
  final PermissionService _permissionService;
  final UserLocationService _locationService;
  final _errorController = StreamController<String>();

  Stream<Position>? _currentPositionStream;
  Stream<Map<String, UserLocation>>? _usersPositionStream;
  Group? currentGroup;

  MapViewModel(
    this._userRepository,
    this._groupRepository,
    this._gpsService,
    this._permissionService,
    this._locationService,
  );

  Stream<String> get errorStream => _errorController.stream;

  Stream<Position> get currentLocationStream {
    if (_currentPositionStream == null) return Stream.empty();
    return _currentPositionStream!.asyncMap((position) async {
      LoggerAccess.logger.debug("Location update:\n$position");

      return position;
    });
  }

  Stream<Map<String, UserLocation>> get usersPositionStream {
    try {
      return _locationService.userLocations;
    } catch (e) {
      LoggerAccess.logger.debug("Error getting locations of users:\n$e");

      return Stream.empty();
    }
  }

  Future<void> initialize() async {
    final hasPerms = await _ensureLocationPermission();
    if (!hasPerms) {
      _errorController.add("Location permission denied");
      return;
    }

    _currentPositionStream = _gpsService.currentPositionStream;
    notifyListeners();
  }

  Future<List<Group>> getGroups() async {
    try {
      return _groupRepository.getGroupsByUserId(_userRepository.currentUserId);
    } catch (e) {
      _errorController.add(e.toString());
      notifyListeners();

      return [];
    }
  }

  void selectGroup(Group group) {
    currentGroup = group;
    _locationService.setGroupChannel(group.id);
    notifyListeners();
  }

  Future<Group?> createGroup(String groupName) async {
    try {
      return _groupRepository.createGroup(
        groupName,
        _userRepository.currentUserId,
      );
    } catch (e) {
      _errorController.add(e.toString());
      notifyListeners();

      return null;
    }
  }

  Future<bool> joinGroup(String joinCode) async {
    try {
      return _groupRepository.joinGroup(
        _userRepository.currentUserId,
        joinCode,
      );
    } catch (e) {
      _errorController.add(e.toString());
      notifyListeners();

      return false;
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final status = await _permissionService.check(AppPermission.location);
    if (status == PermissionStatus.granted) return true;

    final result = await _permissionService.request(AppPermission.location);
    if (result == PermissionStatus.granted) return true;

    return false;
  }
}
