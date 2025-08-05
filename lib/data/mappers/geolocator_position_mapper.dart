import 'package:embutido_tracker/domain/entity/position.dart' as domain;

import 'package:geolocator/geolocator.dart' as geolocator;

class GeolocatorPositionMapper {
  static domain.Position mapGeolocatorPositionToDomain(
    geolocator.Position position,
  ) => domain.Position(
    position.latitude,
    position.longitude,
    position.timestamp,
  );
}
