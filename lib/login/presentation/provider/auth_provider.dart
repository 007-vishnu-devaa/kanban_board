// coverage:ignore-file
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories_impl/auth_repositories_impl.dart';
import '../../domain/model/user_entity.dart';
import '../../domain/repositories/auth_repositories.dart';
import '../notifier/auth_notifier.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl());

final loginUseCaseProvider = Provider((ref) => LoginUseCase(ref.read(authRepositoryProvider)));
final signUpUseCaseProvider = Provider((ref) => SignUpUseCase(ref.read(authRepositoryProvider)));

final loginControllerProvider = StateNotifierProvider<LoginNotifier, AsyncValue<UserEntity?>>(
  (ref) {
    final loginUseCase = ref.read(loginUseCaseProvider);
    final signUpUseCase = ref.read(signUpUseCaseProvider);
    return LoginNotifier(loginUseCase, signUpUseCase);
  },
);
