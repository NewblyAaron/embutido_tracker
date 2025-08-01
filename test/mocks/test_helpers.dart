import 'package:embutido_tracker/domain/entity/user.dart';

final mockUserId = "123";
final mockUserEmail = "test@example.com";
final mockUserPassword = "123456";
final mockUserName = "Test User";
final mockAvatarUrl = "http://www.example.com/avatar.png";

final mockUser = User(
  id: mockUserId,
  email: mockUserEmail,
  userName: mockUserName,
  avatarUrl: mockAvatarUrl,
);
