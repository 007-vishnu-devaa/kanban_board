
import '../model/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
}
