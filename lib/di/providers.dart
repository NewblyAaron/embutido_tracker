import 'package:embutido_tracker/core/services/image_service.dart';
import 'package:embutido_tracker/core/services/logger_service.dart';
import 'package:embutido_tracker/data/repositories/supabase_user_repository.dart';
import 'package:embutido_tracker/data/sources/local/geolocator_gps_service.dart';
import 'package:embutido_tracker/data/sources/local/permission_handler_service.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_auth_service.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_avatar_service.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_storage_source.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_user_location_service.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_user_source.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/services/avatar_cache_service.dart';
import 'package:embutido_tracker/domain/services/auth_service.dart';
import 'package:embutido_tracker/domain/services/gps_service.dart';
import 'package:embutido_tracker/domain/services/permission_service.dart';
import 'package:embutido_tracker/domain/services/user_location_service.dart';
import 'package:embutido_tracker/domain/sources/user_remote_source.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

final coreProviders = [
  Provider<LoggerService>(create: (_) => LoggerService()),
  Provider<ImageService>(create: (_) => ImageService()),
  Provider<BaseCacheManager>(create: (_) => DefaultCacheManager()),
];

final permissionProviders = [
  Provider<PermissionService>(create: (_) => PermissionHandlerService()),
];

final supabaseProviders = [
  Provider<SupabaseClient>(create: (_) => Supabase.instance.client),
  Provider<SupabaseStorageSource>(
    create: (context) => SupabaseStorageSource(context.read<SupabaseClient>()),
  ),
];

final authProviders = [
  Provider<AuthService>(
    create:
        (context) =>
            SupabaseAuthService.fromClient(context.read<SupabaseClient>()),
  ),
];

final userProviders = [
  Provider<AvatarService>(
    create:
        (context) => SupabaseAvatarService(
          context.read<SupabaseStorageSource>(),
          context.read<BaseCacheManager>(),
        ),
    dispose: (context, service) {
      if (service is SupabaseAvatarService) service.dispose();
    },
  ),
  Provider<UserRemoteSource>(
    create:
        (context) => SupabaseUserSource.fromClient(
          context.read<SupabaseClient>(),
          context.read<AvatarService>(),
        ),
  ),
  Provider<UserRepository>(
    create:
        (context) => SupabaseUserRepository(
          context.read<AuthService>(),
          context.read<UserRemoteSource>(),
        ),
    dispose: (context, repository) {
      if (repository is SupabaseUserRepository) repository.dispose();
    },
  ),
  Provider<UserLocationService>(
    create:
        (context) => SupabaseUserLocationService(
          context.read<SupabaseClient>(),
          context.read<UserRemoteSource>(),
        ),
    dispose: (context, service) {
      if (service is SupabaseUserLocationService) service.dispose();
    },
  ),
];

final gpsProviders = [
  Provider<GPSService>(create: (context) => GeolocatorService()),
];

final globalProviders = [
  ...coreProviders,
  ...permissionProviders,
  ...supabaseProviders,
  ...authProviders,
  ...userProviders,
  ...gpsProviders,
];
