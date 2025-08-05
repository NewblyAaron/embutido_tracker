class Position {
  Position(this.latitude, this.longitude, [DateTime? timestamp])
    : timestamp = timestamp ?? DateTime.now();

  final double latitude;
  final double longitude;
  final DateTime timestamp;

  @override
  String toString() {
    return 'Latitude: $latitude, Longitude: $longitude, Timestamp: ${timestamp.toLocal()}';
  }
}
