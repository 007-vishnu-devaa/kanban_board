
// coverage:ignore-file
import '../model/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> signUp(String email, String password);
}
