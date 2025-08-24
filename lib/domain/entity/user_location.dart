import 'package:embutido_tracker/domain/entity/position.dart';
import 'package:embutido_tracker/domain/entity/user.dart';

class UserLocation {
  final User user;
  final Position position;

  const UserLocation(this.user, this.position);

  UserLocation copyWith({Position? position}) =>
      UserLocation(user, position ?? this.position);

  @override
  String toString() => "$user's location: $position";
}
