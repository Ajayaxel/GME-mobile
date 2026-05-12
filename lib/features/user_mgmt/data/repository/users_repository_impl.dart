import '../../domain/models/user_model.dart';
import '../../domain/repository/users_repository.dart';
import '../datasource/users_remote_datasource.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<UserModel>> getUsers() async {
    return await remoteDataSource.getUsers();
  }

  @override
  Future<void> createUser(Map<String, dynamic> userData) async {
    await remoteDataSource.createUser(userData);
  }

  @override
  Future<void> deleteUser(String id) async {
    await remoteDataSource.deleteUser(id);
  }
}
