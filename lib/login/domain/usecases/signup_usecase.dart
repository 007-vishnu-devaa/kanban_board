import '../../domain/repositories/auth_repositories.dart';
import '../../domain/model/user_entity.dart';

class SignUpUseCase {
  final AuthRepository _repository;
  SignUpUseCase(this._repository);

  Future<UserEntity?> call(String email, String password) async {
    return _repository.signUp(email, password);
  }
}
