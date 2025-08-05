enum AppPermission { location }

enum PermissionStatus { granted, denied, deniedForever, restricted, unknown }

abstract class PermissionService {
  Future<PermissionStatus> check(AppPermission permission);
  Future<PermissionStatus> request(AppPermission permission);
}
