import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories_impl/auth_repositories_impl.dart';
import '../../domain/model/user_entity.dart';

final authRepositoryProvider = Provider((ref) => AuthRepositoryImpl());

final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<UserEntity?>>(
  (ref) => LoginController(ref.read(authRepositoryProvider)),
);

class LoginController extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepositoryImpl _repository;
  LoginController(this._repository) : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
