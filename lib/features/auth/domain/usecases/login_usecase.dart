import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/login_models.dart';
import '../repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, LoginResponseModel>> call(String email, String password) async {
    return await repository.login(LoginRequestModel(email: email, password: password));
  }
}
