import '../../domain/repositories/auth_repositories.dart';
import '../../domain/model/user_entity.dart';

class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<UserEntity?> call(String email, String password) async {
    return _repository.login(email, password);
  }
}
