import 'package:embutido_tracker/domain/entity/position.dart';
import 'package:embutido_tracker/domain/entity/user_location.dart';

abstract class UserLocationRemoteSource {
  Stream<Map<String, UserLocation>> get userLocations;

  Future<void> setGroup(String groupId);
  Future<void> updateUserLocation(String userId, Position newPosition);
}
