import 'package:embutido_tracker/domain/entity/user_location.dart';

abstract class UserLocationService {
  Stream<Map<String, UserLocation>> get userLocations;

  void setGroupChannel(String groupId);
}
