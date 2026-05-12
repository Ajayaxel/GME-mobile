import '../models/user_model.dart';

abstract class UsersRepository {
  Future<List<UserModel>> getUsers();
  Future<void> createUser(Map<String, dynamic> userData);
  Future<void> deleteUser(String id);
}
