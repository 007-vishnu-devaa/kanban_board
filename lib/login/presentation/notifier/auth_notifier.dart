import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/repositories/auth_repositories.dart';
import '../../domain/model/user_entity.dart';

class LoginNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repository;
  LoginNotifier(this._repository) : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _repository.signUp(email, password);
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}