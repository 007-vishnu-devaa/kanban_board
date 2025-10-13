import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/widgets/toast.dart';
import '../../domain/model/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

class LoginNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final LoginUseCase _loginUseCase;
  final SignUpUseCase _signUpUseCase;

  LoginNotifier(this._loginUseCase, this._signUpUseCase) : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _loginUseCase.call(email, password);
      state = AsyncData(user);
      if (user == null) {
        FlutterToast(toastMsg: "Login failed: User not found").toast();
      }
    } catch (e) {
       state = AsyncError(e, StackTrace.current);
     
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _signUpUseCase.call(email, password);
      state = AsyncData(user);
      if (user == null) {
        FlutterToast(toastMsg: "Signup failed: User not created").toast();
      }
    } catch (e) {
       state = AsyncError(e, StackTrace.current);
    }
  }
}