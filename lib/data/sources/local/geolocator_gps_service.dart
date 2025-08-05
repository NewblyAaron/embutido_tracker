import 'package:embutido_tracker/data/mappers/geolocator_position_mapper.dart';
import 'package:embutido_tracker/domain/entity/position.dart';
import 'package:embutido_tracker/domain/services/gps_service.dart';
import 'package:geolocator/geolocator.dart' hide Position;

class GeolocatorService implements GPSService {
  const GeolocatorService();

  @override
  Stream<Position> get currentPositionStream =>
      Geolocator.getPositionStream().asyncMap(
        (position) =>
            GeolocatorPositionMapper.mapGeolocatorPositionToDomain(position),
      );

  @override
  Future<Position> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    return GeolocatorPositionMapper.mapGeolocatorPositionToDomain(position);
  }
}
