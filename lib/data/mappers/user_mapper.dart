import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:embutido_tracker/domain/entity/user.dart' as domain;

domain.User mapSupabaseUserToDomain(supabase.User user) => domain.User(id: user.id, email: user.email!);