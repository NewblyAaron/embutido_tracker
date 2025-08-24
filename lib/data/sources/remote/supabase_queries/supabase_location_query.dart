import 'dart:async';

import 'package:embutido_tracker/domain/entity/position.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class SupabaseLocationQuery {
  final supabase.SupabaseClient _client;
  final Map<String, Position> _userPositions = {};
  final StreamController<Map<String, Position>> _userLocationStream =
      StreamController.broadcast();

  String? _groupId;
  supabase.RealtimeChannel? _channel;

  SupabaseLocationQuery(this._client);

  Stream<Map<String, Position>> get dataStream {
    if (_groupId == null) throw Exception("Group ID is null");

    return _userLocationStream.stream;
  }

  set channelId(String channelId) {
    _groupId = channelId;

    _setupChannel();
  }

  void _setupChannel() {
    _channel?.unsubscribe();
    _channel = _client
        .channel(_groupId!)
        .onBroadcast(
          event: 'location',
          callback: (payload) => _locationReceived(payload),
        );
    _channel!.subscribe();
  }

  void _locationReceived(Map<String, dynamic> payload) async {
    final userId = payload['user_id'] as String;
    final position = Position(
      payload['latitude'] as double,
      payload['longitude'] as double,
    );

    _userPositions[userId] = position;

    _userLocationStream.add(Map.from(_userPositions));
  }

  void dispose() {
    _channel?.unsubscribe();
    _userLocationStream.close();
  }
}
