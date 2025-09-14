import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/domain/entity/position.dart';
import 'package:embutido_tracker/domain/entity/user_location.dart';
import 'package:embutido_tracker/domain/repositories/location_repository.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/services/gps_service.dart';
import 'package:embutido_tracker/domain/services/user_location_service.dart';

class SupabaseLocationRepository implements LocationRepository {
  final UserRepository _userRepository;
  final GPSService _gpsService;
  final UserLocationRemoteSource _userLocationSource;

  SupabaseLocationRepository(
    this._userRepository,
    this._gpsService,
    this._userLocationSource,
  );

  @override
  Stream<Position> get currentPositionStream =>
      _gpsService.currentPositionStream;

  @override
  Stream<Map<String, UserLocation>> get userLocationsStream =>
      _userLocationSource.userLocations;

  @override
  Future<Position> getCurrentPosition() => _gpsService.getCurrentLocation();

  @override
  Future<void> updatePosition(Position newPosition) => _userLocationSource
      .updateUserLocation(_userRepository.currentUserId, newPosition);

  @override
  Future<void> setGroup(String groupId) {
    try {
      _userLocationSource.setGroup(groupId);
      LoggerAccess.logger.info("Set group ID to $groupId");
      return Future.value();
    } catch (e) {
      return Future.error(e);
    }
  }
}
