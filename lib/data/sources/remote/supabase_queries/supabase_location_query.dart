import 'dart:async';

import 'package:embutido_tracker/core/logging/logger_access.dart';
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
    if (_groupId == null) {
      LoggerAccess.logger.warn("No group ID set");
      return Stream.value({});
    }

    return _userLocationStream.stream;
  }

  set channelId(String channelId) {
    _groupId = channelId;

    _setupChannel();
  }

  void _setupChannel() {
    _userPositions.clear();

    _channel?.untrack();
    _channel?.unsubscribe();

    _channel = _client
        .channel(_groupId!, opts: supabase.RealtimeChannelConfig(private: true))
        .onPresenceSync((_) {
          final presenceStates = _channel!.presenceState();
          final presences =
              presenceStates.map((e) => e.presences.first).toList();
          final payloads = presences.map((e) => e.payload).toList();

          LoggerAccess.logger.debug(presenceStates.toString());
          LoggerAccess.logger.debug(presences.toString());
          LoggerAccess.logger.debug(payloads.toString());

          for (final payload in payloads) {
            final userId = payload['user_id'] as String;
            final position = Position(
              payload['latitude'] as double,
              payload['longitude'] as double,
              DateTime.parse(payload['timestamp'] as String),
            );

            _userPositions[userId] = position;
          }

          _userLocationStream.add(_userPositions);
        })
        .onPresenceJoin((payload) {
          final userId = payload.newPresences.first.payload['user_id'];

          LoggerAccess.logger.debug("$userId has joined");
        })
        .onPresenceLeave((payload) {
          final userId = payload.leftPresences.first.payload['user_id'];
          _userPositions.remove(userId);
          _userLocationStream.add(_userPositions);

          LoggerAccess.logger.debug("$userId has left");
        });

    _channel!.subscribe();
  }

  void updateLocation(String userId, Position newPosition) => _channel?.track({
    'user_id': userId,
    'latitude': newPosition.latitude,
    'longitude': newPosition.longitude,
    'timestamp': newPosition.timestamp.toIso8601String(),
  });

  void dispose() {
    _userPositions.clear();
    _channel?.unsubscribe();
    _userLocationStream.close();
  }
}
