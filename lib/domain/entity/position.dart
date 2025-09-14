class Position {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  Position(this.latitude, this.longitude, [DateTime? timestamp])
    : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'Latitude: $latitude, Longitude: $longitude, Timestamp: ${timestamp.toLocal()}';
  }
}
