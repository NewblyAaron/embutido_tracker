import 'package:embutido_tracker/data/sources/remote/supabase_queries/supabase_location_query.dart';
import 'package:embutido_tracker/domain/entity/user_location.dart';
import 'package:embutido_tracker/domain/services/user_location_service.dart';
import 'package:embutido_tracker/domain/sources/user_remote_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUserLocationService implements UserLocationService {
  final SupabaseLocationQuery _query;
  final UserRemoteSource _userSource;

  SupabaseUserLocationService(SupabaseClient client, this._userSource)
    : _query = SupabaseLocationQuery(client);

  @override
  Stream<Map<String, UserLocation>> get userLocations {
    return _query.dataStream.asyncMap((positions) async {
      final futures = positions.entries.map((entry) async {
        final user = await _userSource.getUser(entry.key);
        return MapEntry(entry.key, UserLocation(user, entry.value));
      });

      final results = await Future.wait(futures);

      return Map.fromEntries(results);
    });
  }

  @override
  void setGroupChannel(String groupId) => _query.channelId = groupId;

  void dispose() {
    _query.dispose();
  }
}
