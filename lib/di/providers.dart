import 'package:embutido_tracker/core/services/logger_service.dart';
import 'package:embutido_tracker/data/repositories/supabase_user_repository.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_auth_source.dart';
import 'package:embutido_tracker/data/sources/remote/supabase_user_source.dart';
import 'package:embutido_tracker/domain/repositories/user_repository.dart';
import 'package:embutido_tracker/domain/sources/auth_source.dart';
import 'package:embutido_tracker/domain/sources/user_remote_source.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<InheritedProvider> globalProviders = [
  Provider<LoggerService>(create: (_) => LoggerService()),
  Provider<SupabaseClient>(create: (_) => Supabase.instance.client),
  Provider<AuthService>(
    create: (context) => SupabaseAuthSource(context.read<SupabaseClient>()),
  ),
  Provider<UserRemoteSource>(
    create: (context) => SupabaseUserSource(context.read<SupabaseClient>()),
  ),
  Provider<UserRepository>(
    create:
        (context) => SupabaseUserRepository(
          context.read<AuthService>(),
          context.read<UserRemoteSource>(),
        ),
  ),
];
