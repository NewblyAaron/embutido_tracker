import 'package:embutido_tracker/domain/services/permission_service.dart'
    as domain;
import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionHandlerMapper {
  static ph.Permission toPermission(domain.AppPermission permission) {
    switch (permission) {
      case domain.AppPermission.location:
        return ph.Permission.location;
      // ignore: unreachable_switch_default
      default:
        throw UnimplementedError("Unsupported permission: $permission");
    }
  }

  static domain.PermissionStatus map(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
        return domain.PermissionStatus.granted;
      case ph.PermissionStatus.denied:
        return domain.PermissionStatus.denied;
      case ph.PermissionStatus.permanentlyDenied:
        return domain.PermissionStatus.deniedForever;
      case ph.PermissionStatus.restricted:
        return domain.PermissionStatus.restricted;
      case ph.PermissionStatus.limited:
        return domain.PermissionStatus.restricted;
      default:
        return domain.PermissionStatus.unknown;
    }
  }
}
