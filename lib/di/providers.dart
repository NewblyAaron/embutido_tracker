import 'package:embutido_tracker/core/services/image_service.dart';
import 'package:embutido_tracker/core/services/logger_service.dart';
import 'package:embutido_tracker/data/repositories/supabase_user_repository.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_auth_source.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_avatar_cache_service.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_storage_source.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_user_source.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/services/avatar_cache_service.dart';
import 'package:embutido_tracker/domain/sources/auth_source.dart';
import 'package:embutido_tracker/domain/sources/user_remote_source.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final coreProviders = [
  Provider<LoggerService>(create: (_) => LoggerService()),
  Provider<ImageService>(create: (_) => ImageService()),
  Provider<BaseCacheManager>(create: (_) => DefaultCacheManager()),
];

final supabaseProviders = [
  Provider<SupabaseClient>(create: (_) => Supabase.instance.client),
];

final authProviders = [
  Provider<AuthService>(
    create: (context) => SupabaseAuthSource(context.read<SupabaseClient>()),
  ),
];

final userProviders = [
  Provider<SupabaseStorageSource>(
    create: (context) => SupabaseStorageSource(context.read<SupabaseClient>()),
  ),
  Provider<AvatarCacheService>(
    create:
        (context) => SupabaseAvatarCacheService(
          context.read<SupabaseStorageSource>(),
          context.read<BaseCacheManager>(),
        ),
  ),
  Provider<UserRemoteSource>(
    create:
        (context) => SupabaseUserSource(
          context.read<SupabaseClient>(),
          context.read<SupabaseStorageSource>(),
          context.read<AvatarCacheService>(),
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
];

final globalProviders = [
  ...coreProviders,
  ...supabaseProviders,
  ...authProviders,
  ...userProviders,
];
