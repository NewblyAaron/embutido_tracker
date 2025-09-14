// ignore_for_file: unused_field

import 'dart:async';

import 'package:embutido_tracker/domain/entity/group.dart';
import 'package:embutido_tracker/domain/entity/position.dart';
import 'package:embutido_tracker/domain/entity/user_location.dart';
import 'package:embutido_tracker/domain/repositories/group_repository.dart';
import 'package:embutido_tracker/domain/repositories/location_repository.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/services/permission_service.dart';
import 'package:flutter/material.dart';

class MapViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final GroupRepository _groupRepository;
  final LocationRepository _locationRepository;
  final PermissionService _permissionService;
  final _errorController = StreamController<String>();

  Group? currentGroup;

  MapViewModel(
    this._userRepository,
    this._groupRepository,
    this._locationRepository,
    this._permissionService,
  );

  Stream<String> get errorStream => _errorController.stream;
  Stream<Position> get currentPositionStream =>
      _locationRepository.currentPositionStream;
  Stream<Map<String, UserLocation>> get userLocationsStream =>
      _locationRepository.userLocationsStream;

  Future<void> initialize() async {
    final hasPerms = await _ensureLocationPermission();
    if (!hasPerms) {
      _errorController.add("Location permission denied");
      return;
    }

    // debug for now; will change duration
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      _locationRepository.updatePosition(
        await _locationRepository.getCurrentPosition(),
      );
    });

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
    _locationRepository.setGroup(group.id);
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
