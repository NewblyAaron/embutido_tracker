import 'package:embutido_tracker/data/mappers/permission_handler_mapper.dart';
import 'package:embutido_tracker/domain/services/permission_service.dart'
    as domain;
import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionHandlerService implements domain.PermissionService {
  @override
  Future<domain.PermissionStatus> check(domain.AppPermission permission) async {
    final status =
        await PermissionHandlerMapper.toPermission(permission).status;

    return PermissionHandlerMapper.map(status);
  }

  @override
  Future<domain.PermissionStatus> request(
    domain.AppPermission permission,
  ) async {
    final result =
        await PermissionHandlerMapper.toPermission(permission).request();

    return PermissionHandlerMapper.map(result);
  }
}
