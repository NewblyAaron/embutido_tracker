import 'package:embutido_tracker/domain/entity/position.dart';

abstract class GPSService {
  Stream<Position> get currentPositionStream;

  Future<Position> getCurrentLocation();
}
