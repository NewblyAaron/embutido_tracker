import 'package:embutido_tracker/data/sources/remote/supabase_queries/supabase_location_query.dart';
import 'package:embutido_tracker/domain/entity/position.dart';
import 'package:embutido_tracker/domain/entity/user_location.dart';
import 'package:embutido_tracker/domain/services/user_location_service.dart';
import 'package:embutido_tracker/domain/sources/user_remote_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUserLocationSource implements UserLocationRemoteSource {
  final SupabaseLocationQuery _query;
  final UserRemoteSource _userSource;

  SupabaseUserLocationSource(SupabaseClient client, this._userSource)
    : _query = SupabaseLocationQuery(client);

  @override
  Stream<Map<String, UserLocation>> get userLocations {
    return _query.dataStream.asyncMap((positions) async {
      final userIds = positions.keys.toList();
      final users = await _userSource.getUsers(userIds);
      final usersMap = {for (final user in users) user.id: user};

      return Map.fromEntries(
        positions.entries
            .where((entry) => usersMap.containsKey(entry.key))
            .map(
              (entry) => MapEntry(
                entry.key,
                UserLocation(usersMap[entry.key]!, entry.value),
              ),
            ),
      );
    });
  }

  @override
  Future<void> setGroup(String groupId) {
    _query.channelId = groupId;
    return Future.value();
  }

  @override
  Future<void> updateUserLocation(String userId, Position newPosition) {
    _query.updateLocation(userId, newPosition);
    return Future.value();
  }

  void dispose() {
    _query.dispose();
  }
}
