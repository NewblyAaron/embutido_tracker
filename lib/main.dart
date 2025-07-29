import 'package:embutido_tracker/core/logging/logger_access.dart';
import 'package:embutido_tracker/di/providers.dart';
import 'package:embutido_tracker/domain/repositories/auth_repository.dart';
import 'package:embutido_tracker/ui/login/login_screen.dart';
import 'package:embutido_tracker/ui/map/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://rpavxekozyvipkjucnwy.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwYXZ4ZWtvenl2aXBranVjbnd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM3OTUwMzksImV4cCI6MjA2OTM3MTAzOX0.40qb7zIto24wgx0O6RK4tJ7uz-GE5Mr350-4NHh-mHQ",
  );

  runApp(
    MultiProvider(
      providers: globalProviders,
      child: Builder(
        builder: (context) {
          LoggerAccess.init(context);
          return const EmbutidoApp();
        },
      ),
    ),
  );
}

class EmbutidoApp extends StatelessWidget {
  const EmbutidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: context.read<AuthService>().onAuthStateChanged,
        builder:
            (context, snapshot) =>
                snapshot.data != null ? MapScreen() : LoginScreen(),
      ),
    );
  }
}
