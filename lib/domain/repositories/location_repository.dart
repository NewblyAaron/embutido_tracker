import 'package:embutido_tracker/domain/entity/position.dart';
import 'package:embutido_tracker/domain/entity/user_location.dart';

abstract class LocationRepository {
  Stream<Position> get currentPositionStream;
  Stream<Map<String, UserLocation>> get userLocationsStream;

  Future<Position> getCurrentPosition();
  Future<void> updatePosition(Position newPosition);
  Future<void> setGroup(String groupId);
}
