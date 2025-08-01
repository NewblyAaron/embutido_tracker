import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:embutido_tracker/domain/entity/user.dart' as domain;

class SupabaseUserMapper {
  static domain.User mapSupabaseUserToDomain(supabase.User user) =>
      domain.User(id: user.id, email: user.email!);

  static domain.User fromMap(
    Map<String, dynamic> map, {
    String? email,
    String? avatarUrl,
  }) => domain.User(
    id: map['id'] as String,
    email: email,
    userName: map['user_name'],
    avatarUrl: avatarUrl,
  );

  static Map<String, dynamic> toMap(domain.User user) => {
    'id': user.id,
    'user_name': user.userName,
  };
}
