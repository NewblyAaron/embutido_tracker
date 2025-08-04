import 'package:embutido_tracker/domain/sources/query_interfaces.dart';
import 'package:embutido_tracker/domain/entity/user.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([TableQuery<User>, StorageQuery, AuthQuery])
void main() {}
