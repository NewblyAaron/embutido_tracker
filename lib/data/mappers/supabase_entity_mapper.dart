import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:embutido_tracker/domain/entity/user.dart' as domain;
import 'package:embutido_tracker/domain/entity/group.dart';

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
    name: map['user_name'],
    avatarUrl: avatarUrl,
  );

  static Map<String, dynamic> toMap(domain.User user) => {
    'id': user.id,
    'user_name': user.name,
  };
}

class SupabaseGroupMapper {
  static Group fromMap(
    Map<String, dynamic> map, {
    Map<String, domain.User>? members,
  }) => Group(
    id: map['id'] as String,
    name: map['name'] as String,
    creatorUserId: map['creator_user_id'] as String,
    joinCode: map['join_code'] as String,
    members: members,
  );

  static Map<String, dynamic> toMap(Group group, {String? creatorUserId}) => {
    'id': group.id,
    'name': group.name,
    if (group.creatorUserId != null || creatorUserId != null)
      'creator_user_id': group.creatorUserId ?? creatorUserId,
    if (group.joinCode != null) 'join_code': group.joinCode,
    if (group.members.isNotEmpty) 'members': group.members,
  };
}
